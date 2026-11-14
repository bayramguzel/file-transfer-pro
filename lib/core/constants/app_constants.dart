class AppConstants {
  // App Info
  static const String appName = 'File Transfer';
  static const String appDescription = 'Professional File Transfer';

  // Database
  static const String dbName = 'filetransfer.db';
  static const int dbVersion = 2; // Updated for direction tracking

  // LocalStorage Keys
  static const String keyUsername = 'filetransfer-username';
  static const String keyDeviceName = 'filetransfer-device-name';
  static const String keyProfilePicture = 'filetransfer-profile-picture';
  static const String keyTheme = 'filetransfer-theme';
  static const String keyAccent = 'filetransfer-accent';
  static const String keyLanguage = 'filetransfer-language';
  static const String keyDownloadDir = 'filetransfer-download-dir';

  // App Folder & Links
  static const String appFolderName = 'file_transfer';
  static const String googlePlayUrl =
      'https://play.google.com/store/apps/details?id=com.filetransfer.pro';
  static const String googlePlayMarketUrl =
      'market://details?id=com.filetransfer.pro';

  /// App Store Connect'te iOS uygulaması oluşturulduktan sonra doldurulmalıdır.
  static const String appStoreId = '';
  static const String appStoreUrl = 'https://apps.apple.com/app/id$appStoreId';
  static const String websiteUrl = 'https://www.41software.com';
  static const String privacyPolicyUrl =
      'https://www.41software.com/privacy/privacy_filetransfer.php';

  // Network
  static const int defaultPort = 8080;
  static const String defaultIP = '192.168.1.12';

  // Transfer
  static const int codeLength = 6;
  static const int minCodeValue = 100000;
  static const int maxCodeValue = 999999;

  // QR Code
  static const int qrSize = 220;
  static const int scanFps = 10;

  // UI
  static const Duration confettiDuration = Duration(seconds: 5);
  static const Duration copiedFeedbackDuration = Duration(seconds: 2);
  static const Duration transferPollInterval = Duration(seconds: 5);
}
