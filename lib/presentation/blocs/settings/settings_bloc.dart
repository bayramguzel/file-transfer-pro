import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc(this.repository) : super(SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateUsername>(_onUpdateUsername);
    on<UpdateDeviceName>(_onUpdateDeviceName);
    on<UpdateProfilePicture>(_onUpdateProfilePicture);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateAccentColor>(_onUpdateAccentColor);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<UpdateDownloadDirectory>(_onUpdateDownloadDirectory);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final username = repository.getUsername();
    final deviceName = repository.getDeviceName();
    final profilePicturePath = repository.getProfilePicturePath();
    final themeMode = repository.getThemeMode();
    final accentColor = repository.getAccentColor();
    final language = repository.getLanguage();
    final downloadDirectory = repository.getDownloadDirectory();

    emit(state.copyWith(
      username: username,
      deviceName: deviceName,
      profilePicturePath: profilePicturePath,
      themeMode: themeMode,
      accentColor: accentColor,
      language: language,
      downloadDirectory: downloadDirectory,
    ));
  }

  Future<void> _onUpdateUsername(
    UpdateUsername event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.setUsername(event.username);
    emit(state.copyWith(username: event.username));
  }

  Future<void> _onUpdateDeviceName(
    UpdateDeviceName event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.setDeviceName(event.deviceName);
    emit(state.copyWith(deviceName: event.deviceName));
  }

  Future<void> _onUpdateProfilePicture(
    UpdateProfilePicture event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.setProfilePicturePath(event.picturePath);
    emit(state.copyWith(profilePicturePath: event.picturePath));
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.setThemeMode(event.themeMode);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onUpdateAccentColor(
    UpdateAccentColor event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.setAccentColor(event.accentColor);
    emit(state.copyWith(accentColor: event.accentColor));
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.setLanguage(event.language);
    emit(state.copyWith(language: event.language));
  }

  Future<void> _onUpdateDownloadDirectory(
    UpdateDownloadDirectory event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.setDownloadDirectory(event.directory);
    emit(state.copyWith(downloadDirectory: event.directory));
  }
}
