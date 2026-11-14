import 'dart:ui';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../core/models/enums.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  // Username
  String getUsername() {
    return _prefs.getString(AppConstants.keyUsername) ??
        Helpers.generateRandomUsername();
  }

  Future<void> setUsername(String username) async {
    await _prefs.setString(AppConstants.keyUsername, username);
  }

  // Device Name
  String getDeviceName() {
    return _prefs.getString(AppConstants.keyDeviceName) ??
        Platform.localHostname;
  }

  Future<void> setDeviceName(String deviceName) async {
    await _prefs.setString(AppConstants.keyDeviceName, deviceName);
  }

  // Profile Picture
  String? getProfilePicturePath() {
    return _prefs.getString(AppConstants.keyProfilePicture);
  }

  Future<void> setProfilePicturePath(String? path) async {
    if (path == null) {
      await _prefs.remove(AppConstants.keyProfilePicture);
    } else {
      await _prefs.setString(AppConstants.keyProfilePicture, path);
    }
  }

  // Theme
  ThemeMode getThemeMode() {
    final value = _prefs.getString(AppConstants.keyTheme);
    return value != null
        ? ThemeModeExtension.fromString(value)
        : ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode theme) async {
    await _prefs.setString(AppConstants.keyTheme, theme.value);
  }

  // Accent Color
  AccentColor getAccentColor() {
    final value = _prefs.getString(AppConstants.keyAccent);
    return value != null
        ? AccentColorExtension.fromString(value)
        : AccentColor.blue;
  }

  Future<void> setAccentColor(AccentColor color) async {
    await _prefs.setString(AppConstants.keyAccent, color.value);
  }

  // Language
  Language getLanguage() {
    final value = _prefs.getString(AppConstants.keyLanguage);
    if (value != null) {
      return LanguageExtension.fromString(value);
    }

    // Auto-detect system language on first launch
    return _detectSystemLanguage();
  }

  Language _detectSystemLanguage() {
    // Use dart:ui to get platform locale
    try {
      final systemLocale = PlatformDispatcher.instance.locale.languageCode;
      switch (systemLocale) {
        case 'tr':
          return Language.tr;
        case 'de':
          return Language.de;
        case 'en':
          return Language.en;
        default:
          return Language.en; // Default to English for unsupported languages
      }
    } catch (e) {
      return Language.en; // Fallback to English if detection fails
    }
  }

  Future<void> setLanguage(Language language) async {
    await _prefs.setString(AppConstants.keyLanguage, language.value);
  }

  // Download Directory

  /// iOS'ta uygulamanın Belgeler klasörü (uygulama açılışında doldurulur).
  static String iosDocumentsPath = '';

  /// Kullanıcının kaydettiği özel klasörü döner.
  /// Kullanıcı bir seçim yapmamışsa null döner.
  String? getDownloadDirectory() {
    return _prefs.getString(AppConstants.keyDownloadDir);
  }

  /// Kullanıcının seçtiği klasörü döner.
  /// Seçim yoksa cihazın platform bazlı varsayılan Downloads/file_transfer klasörünü döner.
  String getEffectiveDownloadDirectory() {
    final saved = getDownloadDirectory();
    if (saved != null && saved.isNotEmpty) return saved;

    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download/${AppConstants.appFolderName}';
    } else if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        return '$userProfile\\Downloads\\${AppConstants.appFolderName}';
      }
    } else if (Platform.isLinux || Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null) return '$home/Downloads/${AppConstants.appFolderName}';
    } else if (Platform.isIOS) {
      // iOS sanal alanı: indirilenler Belgeler klasöründe tutulur ve
      // Dosyalar uygulamasında "File Transfer Pro" altında görünür.
      return iosDocumentsPath;
    }
    return '';
  }

  Future<void> setDownloadDirectory(String path) async {
    await _prefs.setString(AppConstants.keyDownloadDir, path);
  }

  Future<void> clearDownloadDirectory() async {
    await _prefs.remove(AppConstants.keyDownloadDir);
  }
}
