import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/permission_service.dart';
import 'notification_service.dart';

class FileDownloadService {
  final Dio _dio = Dio();
  final NotificationService _notificationService = NotificationService();
  final PermissionService _permissionService = PermissionService();

  FileDownloadService() {
    _notificationService.init();
  }

  /// Request necessary storage permissions (delegates to PermissionService).
  Future<bool> requestPermissions() =>
      _permissionService.hasStoragePermission();

  /// Download a file from URL with chunked resume & retry support.
  /// Saves to [customDirectory] if specified, otherwise to the dedicated
  /// 'file_transfer' folder in system downloads.
  Future<String> downloadFile(
    String url, {
    String? fileName,
    String? customDirectory,
    Function(int received, int total)? onProgress,
  }) async {
    // Prevent device sleeping during large downloads
    await WakelockPlus.enable();

    // Request permissions first
    await requestPermissions();

    try {
      // 1. Get destination directory
      final Directory? downloadsDir =
          await _getDownloadsDirectory(customDirectory: customDirectory);
      if (downloadsDir == null) {
        throw Exception('Could not access downloads directory');
      }

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // 2. Prepare paths (.part temporary file prevents incomplete corruption)
      final String finalFileName = fileName ?? _getFileNameFromUrl(url);
      final String savePath =
          '${downloadsDir.path}${Platform.pathSeparator}$finalFileName';
      final String partPath = '$savePath.part';
      final partFile = File(partPath);

      final int notificationId =
          DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // 3. Resumable transfer loop with automatic retries on connection drops
      int attempt = 0;
      const int maxAttempts = 4;
      bool downloadSuccess = false;
      dynamic lastError;

      while (attempt < maxAttempts && !downloadSuccess) {
        attempt++;
        int existingBytes = 0;
        if (await partFile.exists()) {
          existingBytes = await partFile.length();
        }

        try {
          final options = Options(
            responseType: ResponseType.stream,
            receiveTimeout: const Duration(minutes: 60),
            sendTimeout: const Duration(minutes: 60),
            headers: existingBytes > 0
                ? {'Range': 'bytes=$existingBytes-'}
                : null,
          );

          final response = await _dio.get<ResponseBody>(
            url,
            options: options,
          );

          final responseBody = response.data;
          if (responseBody == null) {
            throw Exception('Empty response body received from server');
          }

          final statusCode = response.statusCode ?? 200;
          final isPartial = statusCode == 206;

          // If server didn't accept partial content (sent 200), start from zero
          final IOSink sink = partFile.openWrite(
            mode: (isPartial && existingBytes > 0)
                ? FileMode.append
                : FileMode.write,
          );

          int totalBytes = -1;
          final contentRange = response.headers.value('content-range');
          final contentLength = response.headers.value('content-length');

          if (contentRange != null) {
            final match = RegExp(r'/(\d+)').firstMatch(contentRange);
            if (match != null) {
              totalBytes = int.tryParse(match.group(1)!) ?? -1;
            }
          } else if (contentLength != null) {
            final len = int.tryParse(contentLength) ?? -1;
            totalBytes = (isPartial && existingBytes > 0 && len > 0)
                ? existingBytes + len
                : len;
          }

          int receivedBytes =
              (isPartial && existingBytes > 0) ? existingBytes : 0;
          DateTime lastUpdate = DateTime.now();

          await for (final chunk in responseBody.stream) {
            sink.add(chunk);
            receivedBytes += chunk.length;

            final now = DateTime.now();
            if (now.difference(lastUpdate).inMilliseconds >= 250) {
              lastUpdate = now;
              if (totalBytes > 0) {
                final int progress =
                    ((receivedBytes / totalBytes) * 100).toInt().clamp(0, 100);
                if (progress % 10 == 0) {
                  _notificationService.showProgressNotification(
                      notificationId, finalFileName, progress);
                }
              }
              onProgress?.call(receivedBytes, totalBytes);
            }
          }

          await sink.flush();
          await sink.close();

          onProgress?.call(receivedBytes, totalBytes);
          downloadSuccess = true;
        } catch (e) {
          lastError = e;
          print('⚠️ Download attempt $attempt failed ($e). Retrying...');
          if (attempt >= maxAttempts) {
            rethrow;
          }
          // Backoff before resuming
          await Future.delayed(Duration(milliseconds: 1000 * attempt));
        }
      }

      if (!downloadSuccess) {
        throw lastError ?? Exception('Download failed after $maxAttempts attempts');
      }

      // 4. Safely rename .part file to final destination
      final targetFile = File(savePath);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await partFile.rename(savePath);

      print('✅ File downloaded to: $savePath');

      // 5. Completion notification
      await _notificationService.cancelNotification(notificationId);
      await _notificationService.showDownloadCompleteNotification(
          finalFileName, savePath);

      return savePath;
    } catch (e) {
      print('❌ Download error: $e');
      rethrow;
    } finally {
      await WakelockPlus.disable();
    }
  }

  /// Download multiple files
  Future<List<String>> downloadMultipleFiles(
    List<String> urls, {
    String? customDirectory,
    Function(int fileIndex, int received, int total)? onProgress,
  }) async {
    final List<String> downloadedPaths = [];

    for (int i = 0; i < urls.length; i++) {
      final url = urls[i];
      try {
        final path = await downloadFile(
          url,
          customDirectory: customDirectory,
          onProgress: (received, total) {
            onProgress?.call(i, received, total);
          },
        );
        downloadedPaths.add(path);
      } catch (e) {
        print('Failed to download file $i: $e');
      }
    }

    return downloadedPaths;
  }

  /// Returns user-selected custom folder or defaults to 'file_transfer' in Downloads
  Future<Directory?> _getDownloadsDirectory({String? customDirectory}) async {
    // 1. User selected directory takes highest priority
    if (customDirectory != null && customDirectory.isNotEmpty) {
      final dir = Directory(customDirectory);
      try {
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        return dir;
      } catch (e) {
        print('Could not use custom directory "$customDirectory": $e');
      }
    }

    // 2. Default application folder 'file_transfer' under standard downloads
    if (Platform.isAndroid) {
      final appDir = Directory(
          '/storage/emulated/0/Download/${AppConstants.appFolderName}');
      try {
        if (!await appDir.exists()) {
          await appDir.create(recursive: true);
        }
        return appDir;
      } catch (e) {
        final fallback = Directory('/storage/emulated/0/Download');
        if (await fallback.exists()) return fallback;
        final doc = await getApplicationDocumentsDirectory();
        final fallbackApp =
            Directory('${doc.path}/${AppConstants.appFolderName}');
        if (!await fallbackApp.exists()) await fallbackApp.create(recursive: true);
        return fallbackApp;
      }
    } else if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        final dir =
            Directory('$userProfile\\Downloads\\${AppConstants.appFolderName}');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        return dir;
      }
    } else if (Platform.isLinux || Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final dir = Directory('$home/Downloads/${AppConstants.appFolderName}');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        return dir;
      }
    } else if (Platform.isIOS) {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/${AppConstants.appFolderName}');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }

    final fallback = await getApplicationDocumentsDirectory();
    final dir = Directory('${fallback.path}/${AppConstants.appFolderName}');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  String _getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      return segments.last;
    }
    return 'downloaded_file_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get download progress as percentage
  double getProgressPercentage(int received, int total) {
    if (total <= 0) return 0.0;
    return (received / total * 100).clamp(0.0, 100.0);
  }

  /// Cancel ongoing downloads
  void cancelDownloads() {}
}
