enum AppView {
  home,
  send,
  hostingSession,
  receiveScan,
  sendCode,
  receiveCode,
  hostingCodeSession,
  transferHistory,
  transferDetail,
}

enum ThemeMode {
  light,
  dark,
}

enum AccentColor {
  blue,
  green,
  purple,
  orange,
  teal,
}

enum Language {
  tr('tr'),
  en('en'),
  de('de');

  final String value;
  const Language(this.value);
}

enum FileStatus {
  pending,
  transferring,
  completed,
  failed,
}

enum TransferStatus {
  sending,
  receiving,
  paused,
  completed,
  failed,
}

enum TransferDirection {
  sent,
  received,
}

extension ThemeModeExtension on ThemeMode {
  String get value {
    switch (this) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  static ThemeMode fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.dark;
    }
  }
}

extension AccentColorExtension on AccentColor {
  String get value {
    switch (this) {
      case AccentColor.blue:
        return 'blue';
      case AccentColor.green:
        return 'green';
      case AccentColor.purple:
        return 'purple';
      case AccentColor.orange:
        return 'orange';
      case AccentColor.teal:
        return 'teal';
    }
  }

  static AccentColor fromString(String value) {
    switch (value) {
      case 'blue':
        return AccentColor.blue;
      case 'green':
        return AccentColor.green;
      case 'purple':
        return AccentColor.purple;
      case 'orange':
        return AccentColor.orange;
      case 'teal':
        return AccentColor.teal;
      default:
        return AccentColor.blue;
    }
  }
}

extension LanguageExtension on Language {
  String get value {
    switch (this) {
      case Language.tr:
        return 'tr';
      case Language.en:
        return 'en';
      case Language.de:
        return 'de';
    }
  }

  static Language fromString(String value) {
    switch (value) {
      case 'tr':
        return Language.tr;
      case 'en':
        return Language.en;
      case 'de':
        return Language.de;
      default:
        return Language.tr;
    }
  }
}
