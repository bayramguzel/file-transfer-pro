import 'package:equatable/equatable.dart';
import '../../../core/models/enums.dart';

class SettingsState extends Equatable {
  final String username;
  final String deviceName;
  final String? profilePicturePath;
  final ThemeMode themeMode;
  final AccentColor accentColor;
  final Language language;
  final String? downloadDirectory;

  const SettingsState({
    required this.username,
    this.deviceName = '',
    this.profilePicturePath,
    required this.themeMode,
    required this.accentColor,
    required this.language,
    this.downloadDirectory,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      username: '',
      deviceName: '',
      profilePicturePath: null,
      themeMode: ThemeMode.dark,
      accentColor: AccentColor.blue,
      language: Language.en,
      downloadDirectory: null,
    );
  }

  SettingsState copyWith({
    String? username,
    String? deviceName,
    String? profilePicturePath,
    ThemeMode? themeMode,
    AccentColor? accentColor,
    Language? language,
    String? downloadDirectory,
  }) {
    return SettingsState(
      username: username ?? this.username,
      deviceName: deviceName ?? this.deviceName,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      language: language ?? this.language,
      downloadDirectory: downloadDirectory ?? this.downloadDirectory,
    );
  }

  @override
  List<Object?> get props => [
        username,
        deviceName,
        profilePicturePath,
        themeMode,
        accentColor,
        language,
        downloadDirectory,
      ];
}
