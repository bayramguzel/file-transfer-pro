import 'dart:math';
// Filesize removed

class Helpers {
  static const int sessionExpirationMs = 5 * 60 * 1000; // 5 minutes

  /// Format bytes to human readable string (e.g., "1.5 MB")
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';

    const units = ['KB', 'MB', 'GB', 'TB'];
    var size = bytes / 1024;
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    var text = size.toStringAsFixed(decimals);
    if (text.contains('.')) {
      text = text
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    return '$text ${units[unitIndex]}';
  }

  /// Generate a random 6-digit transfer code
  static String generateTransferCode() {
    final random = Random();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
  }

  /// Format milliseconds to MM:SS string
  static String formatTimeLeft(int ms) {
    if (ms <= 0) {
      return '00:00';
    }
    final totalSeconds = ms ~/ 1000;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Generate a random username like "Brave Fox"
  static String generateRandomUsername() {
    const adjectives = [
      'Brave',
      'Clever',
      'Swift',
      'Silent',
      'Wise',
      'Cosmic',
      'Digital',
      'Quantum',
      'Phantom',
      'Shadow'
    ];
    const nouns = [
      'Fox',
      'Eagle',
      'Puma',
      'Jaguar',
      'Cipher',
      'Nomad',
      'Voyager',
      'Spectre',
      'Wanderer',
      'Rider'
    ];

    final random = Random();
    final randomAdjective = adjectives[random.nextInt(adjectives.length)];
    final randomNoun = nouns[random.nextInt(nouns.length)];

    return '$randomAdjective $randomNoun';
  }

  /// Get file extension from filename
  static String getFileExtension(String filename) {
    final lastDot = filename.lastIndexOf('.');
    if (lastDot == -1) return '';
    return filename.substring(lastDot + 1).toLowerCase();
  }

  /// Get file type category from mime type
  static String getFileTypeCategory(String mimeType) {
    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('video/')) return 'video';
    if (mimeType.startsWith('audio/')) return 'audio';
    if (mimeType.contains('zip') ||
        mimeType.contains('rar') ||
        mimeType.contains('tar') ||
        mimeType.contains('7z')) {
      return 'archive';
    }
    if (mimeType.contains('pdf') ||
        mimeType.contains('document') ||
        mimeType.contains('text')) {
      return 'document';
    }
    return 'file';
  }

  /// Calculate transfer speed in bytes per second
  static double calculateSpeed(int bytesTransferred, Duration elapsed) {
    if (elapsed.inMilliseconds == 0) return 0;
    return bytesTransferred / (elapsed.inMilliseconds / 1000);
  }

  /// Calculate ETA in milliseconds
  static int calculateETA(int remainingBytes, double speedBytesPerSec) {
    if (speedBytesPerSec <= 0) return 0;
    return ((remainingBytes / speedBytesPerSec) * 1000).round();
  }

  /// Format speed to human readable string (e.g., "1.5 MB/s")
  static String formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(2)} KB/s';
    } else if (bytesPerSecond < 1024 * 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB/s';
    }
  }
}
