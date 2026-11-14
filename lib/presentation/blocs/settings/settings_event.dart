import 'package:equatable/equatable.dart';
import '../../../core/models/enums.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateUsername extends SettingsEvent {
  final String username;

  const UpdateUsername(this.username);

  @override
  List<Object?> get props => [username];
}

class UpdateDeviceName extends SettingsEvent {
  final String deviceName;

  const UpdateDeviceName(this.deviceName);

  @override
  List<Object?> get props => [deviceName];
}

class UpdateThemeMode extends SettingsEvent {
  final ThemeMode themeMode;

  const UpdateThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class UpdateAccentColor extends SettingsEvent {
  final AccentColor accentColor;

  const UpdateAccentColor(this.accentColor);

  @override
  List<Object?> get props => [accentColor];
}

class UpdateLanguage extends SettingsEvent {
  final Language language;

  const UpdateLanguage(this.language);

  @override
  List<Object?> get props => [language];
}

class UpdateDownloadDirectory extends SettingsEvent {
  final String directory;

  const UpdateDownloadDirectory(this.directory);

  @override
  List<Object?> get props => [directory];
}

class UpdateProfilePicture extends SettingsEvent {
  final String? picturePath;

  const UpdateProfilePicture(this.picturePath);

  @override
  List<Object?> get props => [picturePath];
}
