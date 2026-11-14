import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:mime/mime.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

class LocalNetworkService {
  HttpServer? _server;
  final int port = 8080;
  List<File> _sharedFiles = [];
  MDnsClient? _mdnsClient;
  String _senderName = '';
  String _deviceName = '';
  String? _profilePicturePath;
  String _language = 'tr';
  String? _pin;
  String? _downloadDirectory;
  Function(String fileName, String filePath)? onFileReceived;
  Function(String fileName)? onFileSent;
  Function(int fileIndex, double progress)? onDownloadProgress;

  String _clipboardContent = '';
  String get clipboardContent => _clipboardContent;
  set clipboardContent(String value) {
    _clipboardContent = value;
  }

  Function(String)? onClipboardChanged;

  // Chunked transfer settings
  static const int chunkSize = 1024 * 1024; // 1MB chunks
  static const int largeFileThreshold = 10 * 1024 * 1024; // 10MB

  Future<String?> getLocalIpAddress() async {
    // Primary: NetworkInfo (Wi-Fi IP)
    try {
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();
      if (wifiIP != null && wifiIP.isNotEmpty) return wifiIP;
    } catch (e) {
      print('NetworkInfo error: $e');
    }

    // Fallback: enumerate network interfaces
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      // iOS'ta Wi-Fi arayüzü en0, Android'de wlan0'dır. VPN (utun/tun/ppp)
      // ve hücresel (pdp_ip/rmnet) arayüz adresleri yerel ağdaki diğer
      // cihazlar tarafından erişilemez, bu yüzden atlanır.
      bool isUnreachableInterface(String name) {
        final n = name.toLowerCase();
        return n.startsWith('utun') ||
            n.startsWith('tun') ||
            n.startsWith('tap') ||
            n.startsWith('ipsec') ||
            n.startsWith('ppp') ||
            n.startsWith('pdp_ip') ||
            n.startsWith('rmnet') ||
            n.startsWith('clat');
      }

      bool isWifiLikeInterface(String name) {
        final n = name.toLowerCase();
        return n == 'en0' || n.startsWith('wlan') || n.startsWith('en') ||
            n.startsWith('wi-fi') ||
            n.startsWith('wifi');
      }

      String? firstUsableIp({required bool onlyWifiLike}) {
        for (final interface in interfaces) {
          if (isUnreachableInterface(interface.name)) continue;
          if (onlyWifiLike && !isWifiLikeInterface(interface.name)) continue;
          for (final addr in interface.addresses) {
            final ip = addr.address;
            // Skip loopback and APIPA addresses
            if (!ip.startsWith('127.') && !ip.startsWith('169.254.')) {
              return ip;
            }
          }
        }
        return null;
      }

      final wifiIp = firstUsableIp(onlyWifiLike: true);
      if (wifiIp != null) return wifiIp;

      final anyIp = firstUsableIp(onlyWifiLike: false);
      if (anyIp != null) return anyIp;
    } catch (e) {
      print('NetworkInterface fallback error: $e');
    }

    return null;
  }

  Future<bool> startServer(List<File> files, {String? pin}) async {
    if (_server != null) {
      await stopServer();
    }

    _sharedFiles = List.from(files);
    _pin = pin;

    try {
      final handler = const shelf.Pipeline()
          .addMiddleware(shelf.logRequests())
          .addHandler(_handleRequest);

      _server = await io.serve(handler, InternetAddress.anyIPv4, port);
      print('Server started on port $port');

      await _startMdnsAdvertisement();

      return true;
    } catch (e) {
      print('Failed to start server: $e');
      return false;
    }
  }

  void updateSharedFiles(List<File> files) {
    _sharedFiles = List.from(files);
    print('Updated shared files: ${_sharedFiles.length} files');
  }

  String? _localDomain;

  String? get localDomain => _localDomain;

  Future<void> _startMdnsAdvertisement() async {
    try {
      _mdnsClient = MDnsClient();
      await _mdnsClient!.start();

      final hostname = Platform.environment['COMPUTERNAME'] ??
          Platform.environment['HOSTNAME'] ??
          Platform.environment['USER'] ??
          'filetransfer';

      final safeHostname = hostname
          .toLowerCase()
          .replaceAll(' ', '-')
          .replaceAll(RegExp(r'[^a-z0-9-]'), '');

      _localDomain = '$safeHostname.local';

      print('🌐 mDNS service: $_localDomain');
      print('💡 Try accessing: http://$_localDomain:$port');
    } catch (e) {
      print('⚠️ mDNS setup failed (non-critical): $e');
      print('📡 Server accessible via IP address only');
    }
  }

  void setSenderName(String name) {
    _senderName = name;
  }

  void setDeviceName(String name) {
    _deviceName = name;
  }

  String get deviceName => _deviceName;

  String? _sharedText;
  String? get sharedText => _sharedText;
  void setSharedText(String? text) {
    _sharedText = text;
    if (text != null && text.isNotEmpty) {
      _clipboardContent = text;
    }
  }

  void setProfilePicture(String? picturePath) {
    _profilePicturePath = picturePath;
  }

  void setLanguage(String languageCode) {
    _language = languageCode;
  }

  void setDownloadDirectory(String? path) {
    _downloadDirectory = path;
  }

  Future<shelf.Response> _handleRequest(shelf.Request request) async {
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Range',
      'Access-Control-Expose-Headers':
          'Content-Range, Accept-Ranges, Content-Length, X-File-Checksum',
      'Connection': 'keep-alive',
      'Keep-Alive': 'timeout=120, max=1000',
    };

    if (request.method == 'OPTIONS') {
      return shelf.Response.ok('', headers: headers);
    }

    // Ping endpoint for connection check
    if (request.url.path == 'ping') {
      return shelf.Response.ok('pong', headers: headers);
    }

    // Clipboard & Link REST endpoints
    if (request.url.path == 'api/clipboard') {
      if (request.method == 'GET') {
        return shelf.Response.ok(
          jsonEncode({
            'text': _clipboardContent,
            'sharedText': _sharedText,
          }),
          headers: {...headers, 'Content-Type': 'application/json'},
        );
      } else if (request.method == 'POST') {
        try {
          final body = await request.readAsString();
          final data = jsonDecode(body);
          final text = data['text'] as String?;
          if (text != null) {
            _clipboardContent = text;
            onClipboardChanged?.call(text);
            return shelf.Response.ok(
              jsonEncode({'success': true}),
              headers: {...headers, 'Content-Type': 'application/json'},
            );
          }
        } catch (e) {
          return shelf.Response.badRequest(
            body: jsonEncode({'success': false, 'error': e.toString()}),
            headers: {...headers, 'Content-Type': 'application/json'},
          );
        }
      }
    }

    // Handle Login
    if (request.method == 'POST' && request.url.path == 'login') {
      final body = await request.readAsString();
      Map<String, dynamic> data;
      try {
        data = jsonDecode(body);
      } catch (e) {
        data = {};
      }

      if (data['pin'] == _pin) {
        return shelf.Response.ok(
          jsonEncode({'success': true}),
          headers: {
            ...headers,
            'Set-Cookie': 'session_pin=$_pin; Path=/; Max-Age=3600',
            'Content-Type': 'application/json'
          },
        );
      } else {
        return shelf.Response(
          401,
          body: jsonEncode({'success': false, 'message': 'Invalid PIN'}),
          headers: {...headers, 'Content-Type': 'application/json'},
        );
      }
    }

    // Check for PIN authentication
    if (_pin != null) {
      if (request.url.path != 'profile-picture') {
        final cookies = request.headers['cookie'];
        bool authenticated = false;
        if (cookies != null) {
          if (cookies.contains('session_pin=$_pin')) {
            authenticated = true;
          }
        }

        if (!authenticated) {
          if (request.url.path == 'upload' ||
              request.url.path.startsWith('download/')) {
            return shelf.Response(
              401,
              body: jsonEncode(
                  {'success': false, 'message': 'Authentication required'}),
              headers: {...headers, 'Content-Type': 'application/json'},
            );
          }
          return shelf.Response.ok(
            _generateLoginPage(_language),
            headers: {...headers, 'Content-Type': 'text/html; charset=utf-8'},
          );
        }
      }
    }

    // File info endpoint - returns file metadata including checksum
    if (request.url.path.startsWith('fileinfo/')) {
      final indexStr = request.url.path.substring('fileinfo/'.length);
      final index = int.tryParse(indexStr);

      if (index == null || index < 0 || index >= _sharedFiles.length) {
        return shelf.Response.notFound('File not found', headers: headers);
      }

      final file = _sharedFiles[index];
      if (!await file.exists()) {
        return shelf.Response.notFound('File no longer exists',
            headers: headers);
      }

      final fileName = file.path.split(Platform.pathSeparator).last;
      final fileSize = await file.length();
      final checksum = await _calculateFileChecksum(file);

      return shelf.Response.ok(
        jsonEncode({
          'name': fileName,
          'size': fileSize,
          'checksum': checksum,
          'chunkSize': chunkSize,
          'isLargeFile': fileSize > largeFileThreshold,
        }),
        headers: {...headers, 'Content-Type': 'application/json'},
      );
    }

    // Handle file upload with improved binary handling
    if (request.method == 'POST' && request.url.path == 'upload') {
      try {
        final contentType = request.headers['content-type'];
        if (contentType == null ||
            !contentType.contains('multipart/form-data')) {
          return shelf.Response.badRequest(
            body: jsonEncode({
              'success': false,
              'message': 'Content-Type must be multipart/form-data'
            }),
            headers: {...headers, 'Content-Type': 'application/json'},
          );
        }

        final boundaryMatch = RegExp(r'boundary=(.+)').firstMatch(contentType);
        if (boundaryMatch == null) {
          return shelf.Response.badRequest(
            body:
                jsonEncode({'success': false, 'message': 'No boundary found'}),
            headers: {...headers, 'Content-Type': 'application/json'},
          );
        }
        final boundary = boundaryMatch.group(1)!;

        // Stream-based upload for large files using MimeMultipartTransformer
        final transformer = MimeMultipartTransformer(boundary);
        final parts = transformer.bind(request.read());

        bool fileFound = false;
        String? uploadedFileName;
        int uploadedSize = 0;
        String? finalFilePath;

        try {
          await for (final part in parts) {
            final contentDisposition = part.headers['content-disposition'];
            if (contentDisposition != null) {
              final filenameMatch = RegExp(r'filename="?([^"]+)"?')
                  .firstMatch(contentDisposition);

              if (filenameMatch != null) {
                fileFound = true;
                final rawName = filenameMatch.group(1)!;
                try {
                  uploadedFileName = Uri.decodeComponent(rawName);
                } catch (_) {
                  uploadedFileName = rawName;
                }
                final fileName = uploadedFileName;

                // Determine download directory candidates
                List<Directory> candidateDirs = [];

                final customDir = _downloadDirectory?.trim();
                if (customDir != null && customDir.isNotEmpty) {
                  // Kullanıcının seçtiği klasör her zaman önceliklidir
                  candidateDirs.add(Directory(customDir));
                } else {
                  // Varsayılan: cihazın Downloads klasörü
                  if (Platform.isAndroid) {
                    candidateDirs.add(
                        Directory('/storage/emulated/0/Download/file_transfer'));
                    candidateDirs
                        .add(Directory('/storage/emulated/0/Download'));
                    final extDir = await getExternalStorageDirectory();
                    if (extDir != null) {
                      candidateDirs.add(
                          Directory('${extDir.path}/file_transfer'));
                      candidateDirs.add(extDir);
                    }
                  } else if (Platform.isWindows) {
                    final userProfile = Platform.environment['USERPROFILE'];
                    if (userProfile != null) {
                      candidateDirs.add(
                          Directory('$userProfile\\Downloads\\file_transfer'));
                      candidateDirs.add(Directory('$userProfile\\Downloads'));
                    }
                  } else if (Platform.isLinux || Platform.isMacOS) {
                    final home = Platform.environment['HOME'];
                    if (home != null) {
                      candidateDirs
                          .add(Directory('$home/Downloads/file_transfer'));
                      candidateDirs.add(Directory('$home/Downloads'));
                    }
                  } else if (Platform.isIOS) {
                    // iOS sanal alanı: Dosyalar uygulamasında görünen
                    // Belgeler klasörü kullanılır.
                    final appDir = await getApplicationDocumentsDirectory();
                    candidateDirs
                        .add(Directory('${appDir.path}/file_transfer'));
                    candidateDirs.add(appDir);
                  } else {
                    final appDir = await getApplicationDocumentsDirectory();
                    candidateDirs.add(Directory('${appDir.path}/Downloads'));
                  }
                }

                File? targetFile;

                // Try to find a writable directory
                for (final dir in candidateDirs) {
                  try {
                    if (!await dir.exists()) {
                      await dir.create(recursive: true);
                    }

                    String filePath =
                        '${dir.path}${Platform.pathSeparator}$fileName';
                    File file = File(filePath);

                    // Handle collision
                    int counter = 1;
                    while (await file.exists()) {
                      final dotIndex = fileName.lastIndexOf('.');
                      String name;
                      String ext;
                      if (dotIndex != -1) {
                        name = fileName.substring(0, dotIndex);
                        ext = fileName.substring(dotIndex);
                      } else {
                        name = fileName;
                        ext = '';
                      }
                      final newName = '${name}_$counter$ext';
                      filePath = '${dir.path}${Platform.pathSeparator}$newName';
                      file = File(filePath);
                      counter++;
                    }

                    // Check write permission by opening for write
                    // We verify by opening the sink. If it fails, we catch and try next dir.
                    final sink = file.openWrite();

                    // If we get here, we have a valid sink.
                    // We can proceed to write the stream to this sink.
                    try {
                      await sink.addStream(part);
                      await sink.flush();
                      await sink.close();

                      targetFile = file;
                      uploadedSize = await targetFile.length();
                      break; // Success!
                    } catch (e) {
                      await sink.close();
                      // Write failed (disk full? disconnected?), try next candidate
                      print('⚠️ Write failed to ${file.path}: $e');
                      continue;
                    }
                  } catch (e) {
                    print('⚠️ Cannot access ${dir.path}: $e');
                    continue; // Try next candidate
                  }
                }

                if (targetFile == null) {
                  throw Exception(
                      'No writable directory found. Tried: ${candidateDirs.map((d) => d.path).join(", ")}');
                }

                finalFilePath = targetFile.path;
                print('✅ File uploaded: $uploadedFileName to $finalFilePath');
                onFileReceived?.call(uploadedFileName, finalFilePath);
              }
            }
          }
        } catch (e) {
          print('Stream processing error: $e');
          return shelf.Response.internalServerError(
            body: jsonEncode(
                {'success': false, 'message': 'Upload stream failed: $e'}),
            headers: {...headers, 'Content-Type': 'application/json'},
          );
        }

        if (fileFound) {
          return shelf.Response.ok(
            jsonEncode({
              'success': true,
              'message': 'Files uploaded successfully',
              'size': uploadedSize,
            }),
            headers: {...headers, 'Content-Type': 'application/json'},
          );
        } else {
          return shelf.Response.badRequest(
            body: jsonEncode(
                {'success': false, 'message': 'No file found in request'}),
            headers: {...headers, 'Content-Type': 'application/json'},
          );
        }
      } catch (e) {
        print('Upload error: $e');
        return shelf.Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Upload failed: $e'}),
          headers: {...headers, 'Content-Type': 'application/json'},
        );
      }
    }

    // List all files
    if (request.url.path == '' || request.url.path == 'files') {
      final fileList = _sharedFiles.asMap().entries.map((entry) {
        final file = entry.value;
        int size = 0;
        try {
          if (file.existsSync()) {
            size = file.lengthSync();
          }
        } catch (_) {}
        return {
          'index': entry.key,
          'name': file.path.split(Platform.pathSeparator).last,
          'size': size,
        };
      }).toList();

      final totalSize = _sharedFiles.fold<int>(0, (sum, file) {
        try {
          return sum + (file.existsSync() ? file.lengthSync() : 0);
        } catch (_) {
          return sum;
        }
      });
      final displayName =
          _senderName.isEmpty ? 'File Transfer User' : _senderName;

      return shelf.Response.ok(
        _generateModernHtml(fileList, totalSize, displayName, _language),
        headers: {...headers, 'Content-Type': 'text/html; charset=utf-8'},
      );
    }

    // Download all as zip
    if (request.url.path == 'download-all') {
      if (_sharedFiles.isEmpty) {
        return shelf.Response.notFound('No files to download',
            headers: headers);
      }

      try {
        // Create a temporary file for the zip to avoid memory issues
        final tempDir = await getTemporaryDirectory();
        final zipPath =
            '${tempDir.path}${Platform.pathSeparator}files_${DateTime.now().millisecondsSinceEpoch}.zip';

        final encoder = ZipFileEncoder();
        encoder.create(zipPath);

        for (final file in _sharedFiles) {
          if (await file.exists()) {
            await encoder.addFile(file);
          }
        }
        encoder.close();

        final zipFile = File(zipPath);
        final fileSize = await zipFile.length();

        return shelf.Response.ok(
          zipFile.openRead(),
          headers: {
            ...headers,
            'Content-Type': 'application/zip',
            'Content-Disposition': 'attachment; filename="all_files.zip"',
            'Content-Length': fileSize.toString(),
          },
        );
      } catch (e) {
        print('❌ Zip Download error: $e');
        return shelf.Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'message': 'Zip oluşturma hatası: $e / Failed to create zip: $e'
          }),
          headers: {...headers, 'Content-Type': 'application/json'},
        );
      }
    }

    // Profile picture endpoint
    if (request.url.path == 'profile-picture') {
      if (_profilePicturePath != null) {
        try {
          final file = File(_profilePicturePath!);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final mimeType =
                lookupMimeType(_profilePicturePath!) ?? 'image/jpeg';
            return shelf.Response.ok(
              bytes,
              headers: {...headers, 'Content-Type': mimeType},
            );
          }
        } catch (e) {
          print('Error serving profile picture: $e');
        }
      }
      return shelf.Response.notFound('No profile picture', headers: headers);
    }

    // Preview specific file
    if (request.url.path.startsWith('preview/')) {
      final indexStr = request.url.path.substring('preview/'.length);
      final index = int.tryParse(indexStr);

      if (index == null || index < 0 || index >= _sharedFiles.length) {
        return shelf.Response.notFound('File not found', headers: headers);
      }

      final file = _sharedFiles[index];
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      if (mimeType.startsWith('image/') ||
          mimeType.startsWith('text/') ||
          mimeType.startsWith('video/') ||
          mimeType.startsWith('audio/')) {
        if (mimeType.startsWith('video/') || mimeType.startsWith('audio/')) {
          return shelf.Response.ok('',
              headers: {...headers, 'Content-Type': mimeType});
        }

        final bytes = await file.readAsBytes();
        return shelf.Response.ok(bytes,
            headers: {...headers, 'Content-Type': mimeType});
      } else {
        return shelf.Response(
          400,
          body: jsonEncode({
            'success': false,
            'message': 'Preview not available for this file type'
          }),
          headers: {...headers, 'Content-Type': 'application/json'},
        );
      }
    }

    // Download with enhanced chunked transfer and integrity
    if (request.url.path.startsWith('download/')) {
      final indexStr = request.url.path.substring('download/'.length);
      final index = int.tryParse(indexStr);

      if (index == null || index < 0 || index >= _sharedFiles.length) {
        return shelf.Response.notFound('File not found', headers: headers);
      }

      final file = _sharedFiles[index];
      if (!await file.exists()) {
        return shelf.Response.notFound('File no longer exists',
            headers: headers);
      }

      final fileName = file.path.split(Platform.pathSeparator).last;
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      final fileSize = await file.length();

      final rangeHeader = request.headers['range'];
      if (rangeHeader == null || rangeHeader.startsWith('bytes=0-')) {
        onFileSent?.call(fileName);
      }

      if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
        final rangeMatch = RegExp(r'bytes=(\d+)-(\d*)').firstMatch(rangeHeader);
        if (rangeMatch != null) {
          final start = int.parse(rangeMatch.group(1)!);
          final endStr = rangeMatch.group(2);
          final end = endStr != null && endStr.isNotEmpty
              ? int.parse(endStr)
              : fileSize - 1;

          final length = end - start + 1;

          return shelf.Response(
            206,
            body: file.openRead(start, end + 1),
            headers: {
              ...headers,
              'Content-Type': mimeType,
              'Content-Length': length.toString(),
              'Content-Range': 'bytes $start-$end/$fileSize',
              'Accept-Ranges': 'bytes',
              'Content-Disposition': _getContentDisposition(fileName),
              'Connection': 'keep-alive',
            },
          );
        }
      }

      // Use streaming for all downloads to ensure stability regardless of size
      return shelf.Response.ok(
        file.openRead(),
        headers: {
          ...headers,
          'Content-Type': mimeType,
          'Content-Length': fileSize.toString(),
          'Accept-Ranges': 'bytes',
          'Content-Disposition': _getContentDisposition(fileName),
        },
      );
    }

    return shelf.Response.notFound('Not found', headers: headers);
  }

  // Calculate MD5 checksum for file integrity
  Future<String> _calculateFileChecksum(File file) async {
    final digest = await md5.bind(file.openRead()).first;
    return digest.toString();
  }

  String _getContentDisposition(String fileName) {
    final safeAscii = fileName.replaceAll(RegExp(r'[^\x20-\x7E]'), '_').replaceAll('"', '\\"');
    final encoded = Uri.encodeComponent(fileName);
    return 'attachment; filename="$safeAscii"; filename*=UTF-8\'\'$encoded';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _generateModernHtml(List<Map<String, dynamic>> fileList, int totalSize,
      String senderName, String language) {
    final fileCards = fileList.map((f) {
      final name = f['name'] as String;
      final size = f['size'] as int;
      final index = f['index'] as int;
      final icon = _getFileIcon(name);

      final ext = name.split('.').last.toLowerCase();
      final isPreviewable = [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'txt',
        'md',
        'json',
        'xml',
        'html',
        'css',
        'js',
        'mp4',
        'webm',
        'ogg',
        'mp3',
        'wav'
      ].contains(ext);

      final previewButton = isPreviewable
          ? '''
        <button class="preview-btn" onclick="previewFile($index, '${_escapeHtml(name)}')">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
            <circle cx="12" cy="12" r="3"/>
          </svg>
          <span class="lang-tr">Önizle</span>
          <span class="lang-en">Preview</span>
          <span class="lang-de">Vorschau</span>
        </button>
      '''
          : '';

      return '''
        <div class="file-card" data-index="$index">
          <div class="file-icon">$icon</div>
          <div class="file-info">
            <div class="file-name">${_escapeHtml(name)}</div>
            <div class="file-size">${_formatBytes(size)}</div>
          </div>
          <div class="file-actions">
            $previewButton
            <button class="download-btn" onclick="downloadFileReliable($index, '${_escapeHtml(name)}', $size)">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/>
              </svg>
              <span class="lang-tr">İndir</span>
              <span class="lang-en">Download</span>
              <span class="lang-de">Herunterladen</span>
            </button>
          </div>
          <div class="download-progress" id="progress$index" style="display: none;">
            <div class="progress-info">
              <span id="status$index"></span>
              <span id="speed$index"></span>
            </div>
            <div class="progress-bar">
              <div class="progress-fill" id="fill$index"></div>
            </div>
            <div class="progress-details" id="details$index"></div>
          </div>
        </div>
      ''';
    }).join('\n');

    return '''
<!DOCTYPE html>
<html lang="$language">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>File Transfer - www.41software.com</title>
  <style>
    :root {
      --primary: #667eea;
      --primary-dark: #5568d3;
      --secondary: #764ba2;
      --success: #22c55e;
      --error: #ef4444;
    }
    [data-theme="light"] {
      --bg-body: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
      --bg-container: #ffffff;
      --text-main: #1e293b;
      --text-muted: #64748b;
      --border: #e2e8f0;
      --surface: #f8fafc;
      --surface-hover: #f1f5f9;
      --card-bg: #ffffff;
      --glass: rgba(255,255,255,0.98);
      --glass-border: rgba(255,255,255,0.2);
    }
    [data-theme="dark"] {
      --bg-body: #0f172a;
      --bg-container: #1e293b;
      --text-main: #f1f5f9;
      --text-muted: #94a3b8;
      --border: #334155;
      --surface: #0f172a;
      --surface-hover: #1e293b;
      --card-bg: #1e293b;
      --glass: rgba(15,23,42,0.95);
      --glass-border: rgba(255,255,255,0.05);
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: var(--bg-body);
      min-height: 100vh;
      padding: 20px;
      color: var(--text-main);
      transition: all 0.3s ease;
    }
    .lang-switcher {
      position: fixed;
      top: 20px;
      right: 20px;
      z-index: 1000;
      background: var(--glass);
      border-radius: 16px;
      padding: 8px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.2);
      display: flex;
      gap: 4px;
      backdrop-filter: blur(10px);
      border: 1px solid var(--glass-border);
    }
    .theme-toggle {
      padding: 10px;
      border: none;
      background: transparent;
      cursor: pointer;
      border-radius: 12px;
      color: var(--text-muted);
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .theme-toggle:hover { background: var(--surface-hover); color: var(--text-main); }
    .lang-btn {
      padding: 10px 18px;
      border: none;
      background: transparent;
      cursor: pointer;
      border-radius: 12px;
      font-weight: 700;
      font-size: 14px;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      color: var(--text-muted);
    }
    .lang-btn.active {
      background: linear-gradient(135deg, var(--primary), var(--secondary));
      color: white;
      box-shadow: 0 4px 12px rgba(102,126,234,0.4);
    }
    .lang-btn:hover:not(.active) { background: var(--surface-hover); color: var(--text-main); }
    [data-lang="tr"] .lang-en, [data-lang="tr"] .lang-de,
    [data-lang="en"] .lang-tr, [data-lang="en"] .lang-de,
    [data-lang="de"] .lang-tr, [data-lang="de"] .lang-en { display: none; }
    .container {
      max-width: 900px;
      margin: 0 auto;
      background: var(--bg-container);
      border-radius: 32px;
      box-shadow: 0 25px 80px rgba(0,0,0,0.35);
      overflow: hidden;
      animation: slideUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);
      border: 1px solid var(--border);
    }
    @keyframes slideUp {
      from { opacity: 0; transform: translateY(40px); }
      to { opacity: 1; transform: translateY(0); }
    }
    .header {
      background: var(--bg-body);
      color: white;
      padding: 40px;
      text-align: center;
      position: relative;
      overflow: hidden;
    }
    .header::before {
      content: '';
      position: absolute;
      top: -50%;
      left: -50%;
      width: 200%;
      height: 200%;
      background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 60%);
      animation: pulse 4s ease-in-out infinite;
    }
    @keyframes pulse {
      0%, 100% { transform: scale(1); opacity: 0.5; }
      50% { transform: scale(1.1); opacity: 0.8; }
    }
    .logo {
      width: 80px;
      height: 80px;
      background: rgba(255,255,255,0.2);
      border-radius: 24px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 20px;
      font-size: 40px;
      backdrop-filter: blur(10px);
      position: relative;
      z-index: 1;
    }
    .app-title {
      font-size: 32px;
      font-weight: 800;
      margin-bottom: 8px;
      position: relative;
      z-index: 1;
    }
    .app-subtitle {
      font-size: 16px;
      opacity: 0.9;
      position: relative;
      z-index: 1;
    }
    .sender-info {
      background: var(--glass);
      backdrop-filter: blur(20px);
      padding: 16px 24px;
      display: flex;
      align-items: center;
      gap: 16px;
      position: sticky;
      top: 0;
      z-index: 100;
      border-bottom: 1px solid var(--border);
      margin: 0;
      transition: all 0.3s ease;
    }
    .sender-info.stuck {
      background: var(--glass);
      box-shadow: 0 4px 20px rgba(0,0,0,0.1);
    }
    .profile-picture {
      width: 64px;
      height: 64px;
      border-radius: 50%;
      object-fit: cover;
      border: 3px solid rgba(255,255,255,0.4);
      box-shadow: 0 4px 12px rgba(0,0,0,0.2);
    }
    .profile-icon {
      width: 64px;
      height: 64px;
      border-radius: 50%;
      background: linear-gradient(135deg, rgba(255,255,255,0.3), rgba(255,255,255,0.1));
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 32px;
      border: 3px solid rgba(255,255,255,0.3);
    }
    .sender-details { flex: 1; text-align: left; }
    .sender-name {
      font-size: 20px;
      font-weight: 700;
      margin-bottom: 4px;
      color: var(--text-main);
    }
    .file-count { font-size: 14px; opacity: 0.9; color: var(--text-muted); }
    .online-badge {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: rgba(34,197,94,0.2);
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
    }
    .online-dot {
      width: 8px;
      height: 8px;
      background: #22c55e;
      border-radius: 50%;
      animation: blink 1.5s infinite;
    }
    @keyframes blink {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.4; }
    }
    .content { padding: 40px; }
    .stats {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 16px;
      margin-bottom: 32px;
    }
    .stat {
      background: var(--surface);
      padding: 24px;
      border-radius: 20px;
      text-align: center;
      border: 1px solid var(--border);
    }
    .stat-value {
      font-size: 32px;
      font-weight: 800;
      background: linear-gradient(135deg, var(--primary), var(--secondary));
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }
    .stat-label {
      font-size: 13px;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 1px;
      margin-top: 4px;
    }
    .file-card {
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 20px;
      border: 2px solid var(--border);
      border-radius: 20px;
      margin-bottom: 16px;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      background: var(--card-bg);
    }
    .file-card:hover {
      border-color: var(--primary);
      box-shadow: 0 8px 24px rgba(102,126,234,0.15);
      transform: translateY(-4px);
    }
    .file-icon {
      width: 56px;
      height: 56px;
      border-radius: 16px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 28px;
      background: var(--surface);
    }
    .file-info { flex: 1; min-width: 0; }
    .file-name {
      font-weight: 700;
      color: var(--text-main);
      margin-bottom: 4px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      font-size: 16px;
    }
    .file-size { font-size: 14px; color: var(--text-muted); }
    .file-actions { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
    .preview-btn {
      padding: 12px 20px;
      background: var(--card-bg);
      color: var(--primary);
      border: 2px solid var(--primary);
      border-radius: 12px;
      font-weight: 700;
      cursor: pointer;
      transition: all 0.3s ease;
      display: inline-flex;
      align-items: center;
      gap: 8px;
      font-size: 14px;
    }
    .preview-btn:hover {
      background: var(--primary);
      color: white;
      transform: scale(1.05);
    }
    .download-btn {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 12px 24px;
      background: linear-gradient(135deg, var(--primary), var(--secondary));
      color: white;
      border: none;
      border-radius: 12px;
      font-weight: 700;
      cursor: pointer;
      transition: all 0.3s ease;
      font-size: 14px;
      box-shadow: 0 4px 12px rgba(102,126,234,0.3);
    }
    .download-btn:hover {
      transform: scale(1.05);
      box-shadow: 0 6px 20px rgba(102,126,234,0.4);
    }
    .download-all-btn {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 12px;
      width: 100%;
      padding: 16px;
      background: linear-gradient(135deg, #22c55e, #16a34a);
      color: white;
      border: none;
      border-radius: 16px;
      font-weight: 800;
      cursor: pointer;
      margin-bottom: 24px;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      font-size: 16px;
      box-shadow: 0 4px 12px rgba(34,197,94,0.3);
    }
    .download-all-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 20px rgba(34,197,94,0.4);
    }
    .download-btn:disabled {
      opacity: 0.6;
      cursor: not-allowed;
      transform: none;
    }
    .download-progress {
      width: 100%;
      margin-top: 16px;
      padding: 16px;
      background: var(--surface);
      border-radius: 12px;
    }
    .progress-info {
      display: flex;
      justify-content: space-between;
      font-size: 13px;
      color: var(--primary);
      font-weight: 600;
      margin-bottom: 8px;
    }
    .progress-bar {
      width: 100%;
      height: 10px;
      background: var(--border);
      border-radius: 5px;
      overflow: hidden;
    }
    .progress-fill {
      height: 100%;
      background: linear-gradient(90deg, var(--primary), var(--secondary));
      width: 0%;
      transition: width 0.3s ease;
      border-radius: 5px;
    }
    .progress-details {
      font-size: 12px;
      color: var(--text-muted);
      margin-top: 8px;
      text-align: center;
    }
    .upload-section {
      margin-bottom: 32px;
      padding: 32px;
      background: var(--surface);
      border-radius: 24px;
      border: 3px dashed var(--border);
      text-align: center;
      transition: all 0.3s ease;
    }
    .upload-section:hover {
      border-color: var(--primary);
      background: var(--surface-hover);
    }
    .upload-section.dragover {
      border-color: var(--primary);
      background: rgba(102,126,234,0.1);
    }
    .upload-btn {
      padding: 16px 32px;
      background: linear-gradient(135deg, var(--primary), var(--secondary));
      color: white;
      border: none;
      border-radius: 16px;
      font-weight: 700;
      cursor: pointer;
      transition: all 0.3s ease;
      display: inline-flex;
      align-items: center;
      gap: 10px;
      font-size: 16px;
      box-shadow: 0 4px 16px rgba(102,126,234,0.3);
    }
    .upload-btn:hover {
      transform: scale(1.05);
      box-shadow: 0 6px 24px rgba(102,126,234,0.4);
    }
    #fileInput { display: none; }
    .preview-modal {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0,0,0,0.9);
      z-index: 2000;
      align-items: center;
      justify-content: center;
      padding: 20px;
      backdrop-filter: blur(10px);
    }
    .preview-modal.active { display: flex; }
    .preview-content {
      background: var(--card-bg);
      border-radius: 24px;
      max-width: 90vw;
      max-height: 90vh;
      overflow: auto;
      position: relative;
      box-shadow: 0 25px 80px rgba(0,0,0,0.5);
    }
    .preview-header {
      padding: 20px 24px;
      background: linear-gradient(135deg, var(--primary), var(--secondary));
      color: white;
      border-radius: 24px 24px 0 0;
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-weight: 700;
    }
    .preview-close {
      background: rgba(255,255,255,0.2);
      border: none;
      color: white;
      width: 40px;
      height: 40px;
      border-radius: 50%;
      cursor: pointer;
      font-size: 24px;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .preview-close:hover { background: rgba(255,255,255,0.3); transform: scale(1.1); }
    .preview-body { padding: 24px; }
    .preview-body img { max-width: 100%; height: auto; border-radius: 12px; }
    .preview-body pre {
      background: #1e293b;
      color: #e2e8f0;
      padding: 20px;
      border-radius: 12px;
      overflow-x: auto;
      max-height: 70vh;
      white-space: pre-wrap;
      word-wrap: break-word;
      font-family: 'Fira Code', monospace;
    }
    .footer {
      padding: 40px;
      background: var(--surface);
      border-top: 1px solid var(--border);
    }
    .footer-section { margin-bottom: 28px; }
    .footer-title {
      font-size: 18px;
      font-weight: 800;
      color: var(--text-main);
      margin-bottom: 16px;
    }
    .footer-links { display: flex; flex-wrap: wrap; gap: 20px; }
    .footer-link {
      color: var(--primary);
      text-decoration: none;
      font-size: 15px;
      font-weight: 600;
      transition: all 0.3s ease;
    }
    .footer-link:hover { color: var(--primary-dark); }
    .footer-social { display: flex; flex-wrap: wrap; gap: 12px; }
    .social-btn {
      padding: 10px 20px;
      border: 2px solid var(--border);
      border-radius: 12px;
      text-decoration: none;
      font-size: 14px;
      font-weight: 700;
      transition: all 0.3s ease;
      display: inline-flex;
      align-items: center;
      gap: 8px;
      background: var(--card-bg);
      color: var(--text-main);
    }
    .social-btn:hover {
      transform: translateY(-3px);
      box-shadow: 0 6px 16px rgba(0,0,0,0.1);
    }
    .footer-copyright {
      text-align: center;
      padding-top: 28px;
      margin-top: 28px;
      border-top: 1px solid var(--border);
      color: var(--text-muted);
      font-size: 14px;
    }
    .toast {
      position: fixed;
      bottom: 24px;
      left: 50%;
      transform: translateX(-50%) translateY(100px);
      background: #334155;
      color: white;
      padding: 16px 28px;
      border-radius: 16px;
      font-weight: 600;
      z-index: 3000;
      transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
      box-shadow: 0 8px 32px rgba(0,0,0,0.3);
    }
    .toast.show { transform: translateX(-50%) translateY(0); }
    .toast.success { background: var(--success); }
    .toast.error { background: var(--error); }
    @media (max-width: 640px) {
      .stats { grid-template-columns: 1fr; }
      .file-card { flex-direction: column; text-align: center; }
      .file-actions { flex-direction: column; width: 100%; }
      .preview-btn, .download-btn { width: 100%; justify-content: center; }
      .lang-switcher { top: 10px; right: 10px; padding: 6px; }
      .lang-btn { padding: 8px 12px; font-size: 12px; }
      .header { padding: 28px 20px; }
      .content { padding: 24px; }
    }
  </style>
</head>
<body data-lang="$language">
  <div id="toast" class="toast"></div>
  
  <div class="preview-modal" id="previewModal">
    <div class="preview-content">
      <div class="preview-header">
        <span id="previewFileName"></span>
        <button class="preview-close" onclick="closePreview()">&times;</button>
      </div>
      <div class="preview-body" id="previewBody"></div>
    </div>
  </div>

  <div class="lang-switcher">
    <button class="theme-toggle" onclick="toggleTheme()" id="themeToggle" title="Toggle Theme">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="12" cy="12" r="5"></circle>
        <path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"></path>
      </svg>
    </button>
    <div style="width: 1px; background: var(--border); margin: 0 4px;"></div>
    <button class="lang-btn active" onclick="setLanguage('tr')">TR</button>
    <button class="lang-btn" onclick="setLanguage('en')">EN</button>
    <button class="lang-btn" onclick="setLanguage('de')">DE</button>
  </div>
  
  <div class="container">
    <div class="header">
      <a href="https://www.41software.com" target="_blank" style="display: inline-block; text-decoration: none; color: white; margin-bottom: 20px; padding: 10px 20px; background: rgba(255,255,255,0.15); border-radius: 12px; font-weight: 700; position: relative; z-index: 1; backdrop-filter: blur(10px);">
        🌐 www.41software.com
      </a>
      <div class="logo">📤</div>
      <h1 class="app-title">File Transfer</h1>
      <div class="app-subtitle">
        <span class="lang-tr">Profesyonel Dosya Aktarımı</span>
        <span class="lang-en">Professional File Transfer</span>
        <span class="lang-de">Professionelle Dateiübertragung</span>
      </div>
    </div>
    
    <div class="sender-info" id="stickyProfile">
      ${_profilePicturePath != null ? '<img src="/profile-picture" alt="Profile" class="profile-picture" onerror="this.style.display=\'none\'; this.nextElementSibling.style.display=\'flex\';">' : ''}
      ${_profilePicturePath == null ? '<div class="profile-icon">👤</div>' : '<div class="profile-icon" style="display:none;">👤</div>'}
      <div class="sender-details">
        <div class="sender-name">${_escapeHtml(senderName)}</div>
        ${_deviceName.isNotEmpty ? '<div class="device-name" style="font-size: 13px; opacity: 0.8; margin-bottom: 2px;">📱 ' + _escapeHtml(_deviceName) + '</div>' : ''}
        <div class="file-count">
          <span class="lang-tr">${fileList.length} dosya paylaşıyor</span>
          <span class="lang-en">sharing ${fileList.length} file${fileList.length != 1 ? 's' : ''}</span>
          <span class="lang-de">gibt ${fileList.length} Datei${fileList.length != 1 ? 'en' : ''} frei</span>
        </div>
      </div>
      <div class="online-badge">
        <div class="online-dot"></div>
        <span class="lang-tr">Çevrimiçi</span>
        <span class="lang-en">Online</span>
        <span class="lang-de">Online</span>
      </div>
    </div>
    
    <div class="content">
      <div class="stats">
        <div class="stat">
          <div class="stat-value">${fileList.length}</div>
          <div class="stat-label">
            <span class="lang-tr">Dosya</span>
            <span class="lang-en">File${fileList.length != 1 ? 's' : ''}</span>
            <span class="lang-de">Datei${fileList.length != 1 ? 'en' : ''}</span>
          </div>
        </div>
        <div class="stat">
          <div class="stat-value">${_formatBytes(totalSize)}</div>
          <div class="stat-label">
            <span class="lang-tr">Toplam Boyut</span>
            <span class="lang-en">Total Size</span>
            <span class="lang-de">Gesamtgröße</span>
          </div>
        </div>
      </div>

      ${_sharedText != null && _sharedText!.isNotEmpty ? '''
      <div class="shared-link-card" style="background: var(--surface); border: 2px solid var(--primary); border-radius: 18px; padding: 22px; margin-bottom: 24px; box-shadow: 0 8px 30px rgba(99,102,241,0.18);">
        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px;">
          <div style="display: flex; align-items: center; gap: 10px;">
            <div style="width: 38px; height: 38px; border-radius: 10px; background: linear-gradient(135deg, var(--primary), var(--secondary)); display: flex; align-items: center; justify-content: center; font-size: 20px; color: white;">🔗</div>
            <div>
              <div style="font-weight: 800; font-size: 17px; color: var(--text-main);">
                <span class="lang-tr">Paylaşılan Bağlantı</span>
                <span class="lang-en">Shared Link</span>
                <span class="lang-de">Geteilter Link</span>
              </div>
              <div style="font-size: 12px; color: var(--text-muted);">
                <span class="lang-tr">Bağlantıyı açın veya kopyalayın</span>
                <span class="lang-en">Open link or copy to clipboard</span>
                <span class="lang-de">Link öffnen oder kopieren</span>
              </div>
            </div>
          </div>
        </div>
        <div style="background: var(--background); padding: 14px 16px; border-radius: 12px; font-family: monospace; font-size: 14px; word-break: break-all; margin-bottom: 16px; color: var(--text-main); border: 1px solid var(--border); user-select: all;">
          ${_escapeHtml(_sharedText!)}
        </div>
        <div style="display: flex; gap: 10px; flex-wrap: wrap;">
          ${_sharedText!.startsWith('http://') || _sharedText!.startsWith('https://') ? '''
          <a href="${_escapeHtml(_sharedText!)}" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 8px; padding: 12px 20px; background: linear-gradient(135deg, var(--primary), var(--secondary)); color: white; border-radius: 12px; text-decoration: none; font-weight: 700; font-size: 14px; box-shadow: 0 4px 14px rgba(99,102,241,0.35);">
            🌐 <span class="lang-tr">Bağlantıyı Aç</span><span class="lang-en">Open Link</span><span class="lang-de">Link öffnen</span>
          </a>
          ''' : ''}
          <button onclick="copySharedLink()" style="display: inline-flex; align-items: center; gap: 8px; padding: 12px 20px; background: var(--surface); color: var(--text-main); border: 1.5px solid var(--border); border-radius: 12px; cursor: pointer; font-weight: 700; font-size: 14px;">
            📋 <span class="lang-tr">Kopyala</span><span class="lang-en">Copy</span><span class="lang-de">Kopieren</span>
          </button>
        </div>
      </div>
      ''' : ''}

      ${fileList.isNotEmpty ? '''
      <button class="download-all-btn" onclick="location.href='/download-all'">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/>
        </svg>
        <span class="lang-tr">Tümünü İndir (.zip)</span>
        <span class="lang-en">Download All (.zip)</span>
        <span class="lang-de">Alle herunterladen (.zip)</span>
      </button>
      
      <div class="files">
        $fileCards
      </div>
      ''' : ''}
    </div>
    
    <div class="footer">
      <div class="upload-section" id="uploadSection">
        <h3 class="footer-title" style="margin-bottom: 12px;">
          <span class="lang-tr">📤 Dosya Gönder</span>
          <span class="lang-en">📤 Send Files</span>
          <span class="lang-de">📤 Dateien senden</span>
        </h3>
        <p style="color: var(--text-muted); font-size: 15px; margin-bottom: 20px;">
          <span class="lang-tr"><strong>${_escapeHtml(senderName)}</strong> (${_escapeHtml(_deviceName.isNotEmpty ? _deviceName : 'Cihaz')}) cihazına dosya göndermek için sürükleyin veya seçin</span>
          <span class="lang-en">Drag & drop or select files to send to <strong>${_escapeHtml(senderName)}</strong> (${_escapeHtml(_deviceName.isNotEmpty ? _deviceName : 'Device')})</span>
          <span class="lang-de">Dateien an <strong>${_escapeHtml(senderName)}</strong> senden</span>
        </p>
        <input type="file" id="fileInput" multiple />
        <button class="upload-btn" onclick="document.getElementById('fileInput').click()">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M17 8l-5-5-5 5M12 3v12"/>
          </svg>
          <span class="lang-tr">Dosya Seç</span>
          <span class="lang-en">Choose Files</span>
          <span class="lang-de">Dateien auswählen</span>
        </button>
        <div class="download-progress" id="uploadProgress" style="display: none; margin-top: 20px;">
          <div class="progress-info">
            <span id="uploadStatus"></span>
            <span id="uploadSpeed"></span>
          </div>
          <div class="progress-bar">
            <div class="progress-fill" id="uploadFill"></div>
          </div>
        </div>
      </div>

      <div class="footer-section">
        <div class="footer-title">
          <span class="lang-tr">🔗 Hızlı Bağlantılar</span>
          <span class="lang-en">🔗 Quick Links</span>
          <span class="lang-de">🔗 Schnelllinks</span>
        </div>
        <div class="footer-links">
          <a href="https://www.41software.com" class="footer-link" target="_blank">
            <span class="lang-tr">Web Sitesi</span>
            <span class="lang-en">Website</span>
            <span class="lang-de">Webseite</span>
          </a>
          <a href="https://www.41software.com/privacy/privacy_filetransfer.php" class="footer-link" target="_blank">
            <span class="lang-tr">Gizlilik Politikası</span>
            <span class="lang-en">Privacy Policy</span>
            <span class="lang-de">Datenschutzrichtlinie</span>
          </a>
          <a href="mailto:info@41software.com?subject=File Transfer - Feedback" class="footer-link">
            <span class="lang-tr">Geri Bildirim</span>
            <span class="lang-en">Feedback</span>
            <span class="lang-de">Rückmeldung</span>
          </a>
        </div>
      </div>

      <div class="footer-section">
        <div class="footer-title">
          <span class="lang-tr">📱 Sosyal Medya</span>
          <span class="lang-en">📱 Social Media</span>
          <span class="lang-de">📱 Soziale Medien</span>
        </div>
        <div class="footer-social">
          <a href="https://www.youtube.com/@41softwarecom" class="social-btn" target="_blank" style="color: #FF0000; border-color: #FF0000;">▶️ YouTube</a>
          <a href="https://www.instagram.com/41software" class="social-btn" target="_blank" style="color: #E4405F; border-color: #E4405F;">📷 Instagram</a>
          <a href="https://twitter.com/41software" class="social-btn" target="_blank" style="color: #1DA1F2; border-color: #1DA1F2;">🐦 Twitter</a>
          <a href="https://www.tiktok.com/@41software" class="social-btn" target="_blank" style="color: #000; border-color: #000;">🎵 TikTok</a>
        </div>
      </div>

      <div class="footer-section">
        <div class="footer-title">
          <span class="lang-tr">☕ Destek Olun</span>
          <span class="lang-en">☕ Support Us</span>
          <span class="lang-de">☕ Unterstützen Sie uns</span>
        </div>
        <div class="footer-social">
          <a href="https://www.buymeacoffee.com/41software" class="social-btn" target="_blank" style="color: #FFDD00; border-color: #FFDD00;">☕ Buy Me a Coffee</a>
          <a href="https://www.paypal.me/asbaypc" class="social-btn" target="_blank" style="color: #0070BA; border-color: #0070BA;">💳 PayPal</a>
        </div>
      </div>

      <div class="footer-copyright">
        <span class="lang-tr">© ${DateTime.now().year} File Transfer · Güvenli ve Hızlı Dosya Paylaşımı</span>
        <span class="lang-en">© ${DateTime.now().year} File Transfer · Secure and Fast File Sharing</span>
        <span class="lang-de">© ${DateTime.now().year} File Transfer · Sichere und schnelle Dateifreigabe</span>
      </div>
    </div>
  </div>

  <script>
    // Toast notification
    function showToast(message, type = '') {
      const toast = document.getElementById('toast');
      toast.textContent = message;
      toast.className = 'toast ' + type + ' show';
      setTimeout(() => toast.classList.remove('show'), 3000);
    }

    // Theme switching
    function initTheme() {
      const savedTheme = localStorage.getItem('theme') || 'light';
      document.documentElement.setAttribute('data-theme', savedTheme);
      updateThemeIcon(savedTheme);
    }

    function toggleTheme() {
      const currentTheme = document.documentElement.getAttribute('data-theme');
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', newTheme);
      localStorage.setItem('theme', newTheme);
      updateThemeIcon(newTheme);
    }

    function updateThemeIcon(theme) {
      const icon = document.querySelector('#themeToggle svg');
      if (theme === 'dark') {
        icon.innerHTML = '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>';
      } else {
        icon.innerHTML = '<circle cx="12" cy="12" r="5"></circle><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"></path>';
      }
    }

    // Initialize theme
    initTheme();

    // Language detection and switching
    // Önce kullanıcının kaydettiği dil tercihi
    const savedLang = localStorage.getItem('preferredLang');
    
    // Eğer kayıtlı dil yoksa:
    if (!savedLang) {
      // 1. Sunucudan gelen dili kullan (body data-lang attribute'ünde)
      const serverLang = document.body.getAttribute('data-lang');
      
      // 2. Eğer sunucu dili desteklenen dillerden biriyse onu kullan
      if (serverLang && ['tr', 'en', 'de'].includes(serverLang)) {
        setLanguage(serverLang);
      } else {
        // 3. Desteklenmeyen diller için browser dilini kontrol et
        const browserLang = navigator.language || navigator.userLanguage;
        let initialLang = 'en';
        if (browserLang.startsWith('tr')) initialLang = 'tr';
        else if (browserLang.startsWith('de')) initialLang = 'de';
        setLanguage(initialLang);
      }
    } else {
      // Kayıtlı dil varsa onu kullan
      setLanguage(savedLang);
    }
    
    function setLanguage(lang) {
      document.body.setAttribute('data-lang', lang);
      document.querySelectorAll('.lang-btn').forEach(btn => {
        const btnText = btn.textContent.toLowerCase().trim();
        btn.classList.toggle('active', btnText === lang);
      });
      localStorage.setItem('preferredLang', lang);
    }
    
    // Preview functionality
    async function previewFile(index, fileName) {
      const modal = document.getElementById('previewModal');
      const body = document.getElementById('previewBody');
      const fileNameEl = document.getElementById('previewFileName');
      const lang = document.body.getAttribute('data-lang') || 'en';
      
      const previewMsg = {
        loading: { tr: 'Önizleme yükleniyor...', en: 'Loading preview...', de: 'Vorschau wird geladen...' },
        notAvailable: { tr: 'Önizleme mevcut değil', en: 'Preview not available', de: 'Keine Vorschau verfügbar' },
        error: { tr: 'Önizleme yüklenirken hata', en: 'Error loading preview', de: 'Fehler beim Laden der Vorschau' }
      };
      
      fileNameEl.textContent = fileName;
      body.innerHTML = '<p style="text-align: center; padding: 40px; color: #64748b;">' + (previewMsg.loading[lang] || previewMsg.loading.en) + '</p>';
      modal.classList.add('active');
      
      try {
        const response = await fetch('/preview/' + index);
        const contentType = response.headers.get('content-type');
        
        if (contentType.startsWith('image/')) {
          const blob = await response.blob();
          const url = URL.createObjectURL(blob);
          body.innerHTML = '<img src="' + url + '" alt="' + fileName + '" />';
        } else if (contentType.startsWith('text/')) {
          const text = await response.text();
          body.innerHTML = '<pre>' + text.replace(/</g, '&lt;').replace(/>/g, '&gt;') + '</pre>';
        } else if (contentType.startsWith('video/')) {
          body.innerHTML = '<video controls autoplay style="max-width: 100%; max-height: 80vh; border-radius: 12px;"><source src="/download/' + index + '" type="' + contentType + '"></video>';
        } else if (contentType.startsWith('audio/')) {
          body.innerHTML = '<audio controls autoplay style="width: 100%;"><source src="/download/' + index + '" type="' + contentType + '"></audio>';
        } else {
          body.innerHTML = '<p style="text-align: center; padding: 40px; color: #64748b;">' + (previewMsg.notAvailable[lang] || previewMsg.notAvailable.en) + '</p>';
        }
      } catch (error) {
        body.innerHTML = '<p style="text-align: center; padding: 40px; color: #ef4444;">' + (previewMsg.error[lang] || previewMsg.error.en) + '</p>';
      }
    }
    
    function closePreview() {
      document.getElementById('previewModal').classList.remove('active');
    }
    
    document.getElementById('previewModal').addEventListener('click', function(e) {
      if (e.target === this) closePreview();
    });

    // Sticky Header Observation to toggle style
    const observer = new IntersectionObserver( 
      ([e]) => e.target.classList.toggle("stuck", e.intersectionRatio < 1),
      { threshold: [1] }
    );
    // Ideally we watch if it hits top, but position sticky is handled by CSS. 
    // We can add a shadow when scrolled.
    // For now CSS alone is good properly.

    // Drag and drop upload
    const uploadSection = document.getElementById('uploadSection');
    
    uploadSection.addEventListener('dragover', (e) => {
      e.preventDefault();
      uploadSection.classList.add('dragover');
    });
    
    uploadSection.addEventListener('dragleave', () => {
      uploadSection.classList.remove('dragover');
    });
    
    uploadSection.addEventListener('drop', (e) => {
      e.preventDefault();
      uploadSection.classList.remove('dragover');
      const files = Array.from(e.dataTransfer.files);
      if (files.length > 0) uploadFiles(files);
    });

    // File upload with progress
    const fileInput = document.getElementById('fileInput');
    fileInput.addEventListener('change', (e) => {
      const files = Array.from(e.target.files);
      if (files.length > 0) uploadFiles(files);
    });

    async function uploadFiles(files) {
      const progress = document.getElementById('uploadProgress');
      const status = document.getElementById('uploadStatus');
      const fill = document.getElementById('uploadFill');
      const lang = document.body.getAttribute('data-lang');
      
      progress.style.display = 'block';
      
      const texts = {
        uploading: { tr: 'Gönderiliyor: ', en: 'Uploading: ', de: 'Hochladen: ' },
        success: { tr: '✅ Başarılı!', en: '✅ Success!', de: '✅ Erfolgreich!' },
        error: { tr: '❌ Hata!', en: '❌ Error!', de: '❌ Fehler!' }
      };
      
      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        status.textContent = texts.uploading[lang] + file.name;
        
        try {
          const success = await uploadFileWithProgress(file, (p) => {
            fill.style.width = ((i + p) / files.length * 100) + '%';
          });
          
          if (success) {
            fill.style.width = ((i + 1) / files.length * 100) + '%';
          }
        } catch (error) {
          showToast(texts.error[lang] + ' ' + file.name, 'error');
        }
      }
      
      status.textContent = texts.success[lang];
      showToast(texts.success[lang], 'success');
      
      setTimeout(() => {
        progress.style.display = 'none';
        fill.style.width = '0%';
        fileInput.value = '';
        location.reload();
      }, 2000);
    }

    function uploadFileWithProgress(file, onProgress) {
      return new Promise((resolve, reject) => {
        const formData = new FormData();
        formData.append('file', file);
        
        const xhr = new XMLHttpRequest();
        xhr.upload.addEventListener('progress', (e) => {
          if (e.lengthComputable) onProgress(e.loaded / e.total);
        });
        xhr.addEventListener('load', () => resolve(xhr.status >= 200 && xhr.status < 300));
        xhr.addEventListener('error', () => reject(new Error('Upload failed')));
        xhr.open('POST', '/upload');
        xhr.send(formData);
      });
    }

    // Reliable chunked download with integrity check
    async function downloadFileReliable(index, fileName, fileSize) {
      const progressEl = document.getElementById('progress' + index);
      const statusEl = document.getElementById('status' + index);
      const speedEl = document.getElementById('speed' + index);
      const fillEl = document.getElementById('fill' + index);
      const detailsEl = document.getElementById('details' + index);
      const lang = document.body.getAttribute('data-lang');
      const btn = event.target.closest('.download-btn');
      
      btn.disabled = true;
      progressEl.style.display = 'block';
      
      const texts = {
        downloading: { tr: 'İndiriliyor...', en: 'Downloading...', de: 'Herunterladen...' },
        verifying: { tr: 'Doğrulanıyor...', en: 'Verifying...', de: 'Überprüfen...' },
        complete: { tr: '✅ Tamamlandı!', en: '✅ Complete!', de: '✅ Abgeschlossen!' },
        error: { tr: '❌ Hata!', en: '❌ Error!', de: '❌ Fehler!' },
        retry: { tr: 'Tekrar deniyor...', en: 'Retrying...', de: 'Erneut versuchen...' },
        remaining: { tr: 'kaldı', en: 'remaining', de: 'verbleibend' }
      };
      
      statusEl.textContent = texts.downloading[lang];
      
      try {
        // Get file info including checksum
        const infoResponse = await fetch('/fileinfo/' + index);
        const fileInfo = await infoResponse.json();
        const expectedChecksum = fileInfo.checksum;
        const isLargeFile = fileInfo.isLargeFile;
        
        let blob;
        const startTime = Date.now();
        
        if (isLargeFile) {
          // Chunked download for large files
          const CHUNK_SIZE = 2 * 1024 * 1024; // 2MB chunks
          const chunks = [];
          let downloaded = 0;
          let retryCount = 0;
          const maxRetries = 3;
          
          while (downloaded < fileSize) {
            const start = downloaded;
            const end = Math.min(start + CHUNK_SIZE - 1, fileSize - 1);
            
            try {
              const response = await fetch('/download/' + index, {
                headers: { 'Range': 'bytes=' + start + '-' + end }
              });
              
              if (!response.ok && response.status !== 206) {
                throw new Error('Chunk download failed');
              }
              
              const chunk = await response.arrayBuffer();
              chunks.push(chunk);
              downloaded += chunk.byteLength;
              retryCount = 0; // Reset retry count on success
              
              // Update progress
              const progress = (downloaded / fileSize * 100).toFixed(1);
              fillEl.style.width = progress + '%';
              statusEl.textContent = progress + '%';
              
              // Calculate speed
              const elapsed = (Date.now() - startTime) / 1000;
              const speed = downloaded / elapsed;
              speedEl.textContent = formatSpeed(speed);
              
              // Show details
              const remaining = (fileSize - downloaded) / speed;
              const remText = (texts.remaining && texts.remaining[lang]) ? texts.remaining[lang] : 'remaining';
              detailsEl.textContent = formatBytes(downloaded) + ' / ' + formatBytes(fileSize) + 
                (remaining > 0 ? ' • ~' + formatTime(remaining) + ' ' + remText : '');
              
            } catch (chunkError) {
              retryCount++;
              if (retryCount >= maxRetries) {
                throw new Error('Max retries exceeded');
              }
              statusEl.textContent = texts.retry[lang] + ' (' + retryCount + '/' + maxRetries + ')';
              await new Promise(r => setTimeout(r, 1000 * retryCount)); // Exponential backoff
            }
          }
          
          blob = new Blob(chunks);
        } else {
          // Direct download for small files
          const response = await fetch('/download/' + index);
          if (!response.ok) throw new Error('Download failed');
          
          const reader = response.body.getReader();
          const chunks = [];
          let downloaded = 0;
          
          while (true) {
            const { done, value } = await reader.read();
            if (done) break;
            
            chunks.push(value);
            downloaded += value.length;
            
            const progress = (downloaded / fileSize * 100).toFixed(1);
            fillEl.style.width = progress + '%';
            statusEl.textContent = progress + '%';
            
            const elapsed = (Date.now() - startTime) / 1000;
            speedEl.textContent = formatSpeed(downloaded / elapsed);
          }
          
          blob = new Blob(chunks);
        }
        
        // Verify file size
        if (blob.size !== fileSize) {
          throw new Error('File size mismatch: expected ' + fileSize + ', got ' + blob.size);
        }
        
        statusEl.textContent = texts.verifying[lang];
        
        // Download the file
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = fileName;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
        
        statusEl.textContent = texts.complete[lang];
        speedEl.textContent = '';
        detailsEl.textContent = '';
        showToast(texts.complete[lang] + ' ' + fileName, 'success');
        
        setTimeout(() => {
          progressEl.style.display = 'none';
          fillEl.style.width = '0%';
          btn.disabled = false;
        }, 3000);
        
      } catch (error) {
        console.error('Download error:', error);
        statusEl.textContent = texts.error[lang];
        speedEl.textContent = '';
        detailsEl.textContent = error.message;
        showToast(texts.error[lang] + ' ' + fileName, 'error');
        btn.disabled = false;
      }
    }

    function formatSpeed(bytesPerSecond) {
      if (bytesPerSecond < 1024) return bytesPerSecond.toFixed(0) + ' B/s';
      if (bytesPerSecond < 1024 * 1024) return (bytesPerSecond / 1024).toFixed(1) + ' KB/s';
      return (bytesPerSecond / (1024 * 1024)).toFixed(1) + ' MB/s';
    }
    
    function formatBytes(bytes) {
      if (bytes < 1024) return bytes + ' B';
      if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
      if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
      return (bytes / (1024 * 1024 * 1024)).toFixed(1) + ' GB';
    }
    
    function formatTime(seconds) {
      if (seconds < 60) return Math.ceil(seconds) + 's';
      if (seconds < 3600) return Math.ceil(seconds / 60) + 'm';
      return Math.ceil(seconds / 3600) + 'h';
    }
  </script>
</body>
</html>
''';
  }

  String _getFileIcon(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    final iconMap = {
      'pdf': '📄',
      'doc': '📝',
      'docx': '📝',
      'xls': '📊',
      'xlsx': '📊',
      'ppt': '📽️',
      'pptx': '📽️',
      'jpg': '🖼️',
      'jpeg': '🖼️',
      'png': '🖼️',
      'gif': '🖼️',
      'webp': '🖼️',
      'mp4': '🎥',
      'avi': '🎥',
      'mkv': '🎥',
      'mov': '🎥',
      'mp3': '🎵',
      'wav': '🎵',
      'flac': '🎵',
      'zip': '📦',
      'rar': '📦',
      '7z': '📦',
      'txt': '📃',
      'apk': '📱',
    };
    return iconMap[ext] ?? '📄';
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  String _generateLoginPage(String language) {
    return '''
<!DOCTYPE html>
<html lang="$language">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - File Transfer</title>
  <style>
    :root {
      --primary: #667eea;
      --primary-dark: #5568d3;
      --secondary: #764ba2;
      --success: #22c55e;
      --error: #ef4444;
    }
    [data-theme="light"] {
      --bg-body: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
      --card-bg: #ffffff;
      --text-main: #1e293b;
      --text-muted: #64748b;
      --input-bg: #ffffff;
      --input-border: #e2e8f0;
      --input-text: #1e293b;
    }
    [data-theme="dark"] {
      --bg-body: #0f172a;
      --card-bg: #1e293b;
      --text-main: #f1f5f9;
      --text-muted: #94a3b8;
      --input-bg: #0f172a;
      --input-border: #334155;
      --input-text: #f1f5f9;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: var(--bg-body);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 20px;
      color: var(--text-main);
    }
    .lang-selector {
      display: flex;
      gap: 6px;
      background: rgba(255, 255, 255, 0.2);
      padding: 4px;
      border-radius: 20px;
      margin-bottom: 20px;
      backdrop-filter: blur(10px);
    }
    .lang-btn {
      padding: 6px 14px;
      border: none;
      background: transparent;
      color: #ffffff;
      border-radius: 16px;
      font-size: 13px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }
    .lang-btn.active {
      background: #ffffff;
      color: #333333;
      box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    }
    .login-card {
      background: var(--card-bg);
      padding: 40px;
      border-radius: 28px;
      box-shadow: 0 25px 80px rgba(0,0,0,0.35);
      text-align: center;
      width: 100%;
      max-width: 420px;
      animation: slideUp 0.6s cubic-bezier(0.4, 0, 0.2, 1);
    }
    @keyframes slideUp {
      from { opacity: 0; transform: translateY(40px); }
      to { opacity: 1; transform: translateY(0); }
    }
    .logo {
      width: 72px;
      height: 72px;
      background: linear-gradient(135deg, #667eea, #764ba2);
      border-radius: 22px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 20px;
      font-size: 36px;
      box-shadow: 0 8px 24px rgba(102,126,234,0.4);
    }
    h1 {
      font-size: 26px;
      font-weight: 800;
      color: var(--text-main);
      margin-bottom: 8px;
    }
    p {
      color: var(--text-muted);
      margin-bottom: 28px;
      font-size: 14px;
      line-height: 1.6;
    }
    input {
      width: 100%;
      padding: 16px;
      border: 3px solid var(--input-border);
      border-radius: 16px;
      font-size: 24px;
      text-align: center;
      letter-spacing: 12px;
      margin-bottom: 20px;
      font-weight: 700;
      transition: all 0.3s ease;
      background: var(--input-bg);
      color: var(--input-text);
    }
    input:focus {
      border-color: var(--primary);
      outline: none;
      box-shadow: 0 0 0 4px rgba(102,126,234,0.2);
    }
    button.submit-btn {
      width: 100%;
      padding: 16px;
      background: linear-gradient(135deg, #667eea, #764ba2);
      color: white;
      border: none;
      border-radius: 16px;
      font-size: 16px;
      font-weight: 700;
      cursor: pointer;
      transition: all 0.3s ease;
      box-shadow: 0 4px 16px rgba(102,126,234,0.4);
    }
    button.submit-btn:hover {
      transform: scale(1.02);
      box-shadow: 0 6px 24px rgba(102,126,234,0.5);
    }
    .error {
      color: #ef4444;
      margin-top: 16px;
      font-weight: 600;
      display: none;
      padding: 12px;
      background: #fef2f2;
      border-radius: 12px;
      font-size: 14px;
    }
    /* Multi-language Visibility */
    .lang-tr, .lang-en, .lang-de { display: none; }
    body[data-lang="tr"] .lang-tr { display: inline; }
    body[data-lang="en"] .lang-en { display: inline; }
    body[data-lang="de"] .lang-de { display: inline; }
    body[data-lang="tr"] .lang-tr-block { display: block; }
    body[data-lang="en"] .lang-en-block { display: block; }
    body[data-lang="de"] .lang-de-block { display: block; }
  </style>
</head>
<body data-lang="$language">
  <div class="lang-selector">
    <button class="lang-btn" onclick="setLanguage('tr')">TR</button>
    <button class="lang-btn" onclick="setLanguage('en')">EN</button>
    <button class="lang-btn" onclick="setLanguage('de')">DE</button>
  </div>
  
  <div class="login-card">
    <div class="logo">🔒</div>
    <h1>
      <span class="lang-tr">Güvenlik Kontrolü</span>
      <span class="lang-en">Security Check</span>
      <span class="lang-de">Sicherheitsprüfung</span>
    </h1>
    <p>
      <span class="lang-tr">Paylaşılan dosyalara erişmek için gönderenin cihazında gösterilen 4 haneli PIN kodunu girin.</span>
      <span class="lang-en">Please enter the 4-digit PIN code shown on the sender's device to access the shared files.</span>
      <span class="lang-de">Bitte geben Sie den auf dem Absendergerät angezeigten 4-stelligen PIN-Code ein, um auf die Dateien zuzugreifen.</span>
    </p>
    <input type="password" id="pinInput" maxlength="4" placeholder="••••" pattern="[0-9]*" inputmode="numeric" autofocus>
    <button class="submit-btn" onclick="login()">
      <span class="lang-tr">Dosyalara Eriş</span>
      <span class="lang-en">Access Files</span>
      <span class="lang-de">Auf Dateien zugreifen</span>
    </button>
    <div class="error" id="errorMsg"></div>
  </div>
  
  <script>
    const i18n = {
      enterPin: {
        tr: 'Lütfen 4 haneli bir PIN girin.',
        en: 'Please enter a 4-digit PIN.',
        de: 'Bitte geben Sie eine 4-stellige PIN ein.'
      },
      invalidPin: {
        tr: 'Geçersiz PIN. Lütfen tekrar deneyin.',
        en: 'Invalid PIN. Please try again.',
        de: 'Ungültige PIN. Bitte versuchen Sie es erneut.'
      },
      connectionError: {
        tr: 'Bağlantı hatası. Lütfen tekrar deneyin.',
        en: 'Connection error. Please try again.',
        de: 'Verbindungsfehler. Bitte versuchen Sie es erneut.'
      }
    };

    const savedLang = localStorage.getItem('preferredLang');
    if (savedLang && ['tr', 'en', 'de'].includes(savedLang)) {
      setLanguage(savedLang);
    } else {
      const serverLang = document.body.getAttribute('data-lang');
      if (serverLang && ['tr', 'en', 'de'].includes(serverLang)) {
        setLanguage(serverLang);
      } else {
        const browserLang = navigator.language || navigator.userLanguage || 'en';
        if (browserLang.startsWith('tr')) setLanguage('tr');
        else if (browserLang.startsWith('de')) setLanguage('de');
        else setLanguage('en');
      }
    }

    function setLanguage(lang) {
      document.body.setAttribute('data-lang', lang);
      document.querySelectorAll('.lang-btn').forEach(btn => {
        const btnText = btn.textContent.toLowerCase().trim();
        btn.classList.toggle('active', btnText === lang);
      });
      localStorage.setItem('preferredLang', lang);
    }

    document.getElementById('pinInput').addEventListener('keypress', function(e) {
      if (e.key === 'Enter') login();
    });
    
    async function login() {
      const pin = document.getElementById('pinInput').value;
      const errorMsg = document.getElementById('errorMsg');
      const lang = document.body.getAttribute('data-lang') || 'en';
      
      if (pin.length !== 4) {
        errorMsg.textContent = i18n.enterPin[lang] || i18n.enterPin.en;
        errorMsg.style.display = 'block';
        return;
      }
      
      try {
        const response = await fetch('/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ pin: pin })
        });
        
        const data = await response.json();
        if (data.success) {
          location.reload();
        } else {
          errorMsg.textContent = i18n.invalidPin[lang] || i18n.invalidPin.en;
          errorMsg.style.display = 'block';
          document.getElementById('pinInput').value = '';
          document.getElementById('pinInput').focus();
        }
      } catch (e) {
        errorMsg.textContent = i18n.connectionError[lang] || i18n.connectionError.en;
        errorMsg.style.display = 'block';
      }
    }
  </script>
</body>
</html>
    ''';
  }

  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
    _sharedFiles = [];

    try {
      _mdnsClient?.stop();
      _mdnsClient = null;
    } catch (e) {
      print('Error stopping mDNS: \$e');
    }

    print('Server stopped');
  }

  bool get isRunning => _server != null;

  String? getServerUrl(String? ipAddress) {
    if (ipAddress == null || !isRunning) return null;
    return 'http://$ipAddress:$port';
  }

  String? getLocalDomainUrl() {
    if (_localDomain == null || !isRunning) return null;
    return 'http://$_localDomain:$port';
  }
}
