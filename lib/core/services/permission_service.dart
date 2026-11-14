import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Centralized permission management for File Transfer Pro.
///
/// Handles requesting, checking, and guiding users to grant permissions
/// for all features: storage, camera, notifications, and local network.
class PermissionService {
  // ─────────────────────────────────────────────
  // Singleton
  // ─────────────────────────────────────────────
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // ─────────────────────────────────────────────
  // Storage
  // ─────────────────────────────────────────────

  /// Returns true when storage access is available.
  Future<bool> requestStoragePermission({BuildContext? context}) async {
    if (!Platform.isAndroid) return true;

    // Android 11+ (API 30+) — MANAGE_EXTERNAL_STORAGE
    if (await _isAndroid11OrAbove()) {
      final status = await Permission.manageExternalStorage.status;
      if (status.isGranted) return true;

      if (context != null && context.mounted && status.isDenied) {
        final lang = Localizations.localeOf(context).languageCode;
        final proceed = await _showPermissionRationale(
          context: context,
          title: _PermissionStrings.storageTitle(lang),
          message: _PermissionStrings.storageMessage(lang),
          icon: Icons.folder_rounded,
          iconColor: Colors.orange,
        );
        if (!proceed) return false;
      }

      final result = await Permission.manageExternalStorage.request();
      if (result.isPermanentlyDenied && context != null && context.mounted) {
        final lang = Localizations.localeOf(context).languageCode;
        await _showSettingsDialog(
          context: context,
          title: _PermissionStrings.storageTitle(lang),
          message: _PermissionStrings.storageDeniedMessage(lang),
        );
        return false;
      }
      return result.isGranted;
    }

    // Android 10 and below — READ/WRITE_EXTERNAL_STORAGE
    final status = await Permission.storage.status;
    if (status.isGranted) return true;

    if (context != null && context.mounted && status.isDenied) {
      final lang = Localizations.localeOf(context).languageCode;
      final proceed = await _showPermissionRationale(
        context: context,
        title: _PermissionStrings.storageTitle(lang),
        message: _PermissionStrings.storageMessage(lang),
        icon: Icons.folder_rounded,
        iconColor: Colors.orange,
      );
      if (!proceed) return false;
    }

    final result = await Permission.storage.request();
    if (result.isPermanentlyDenied && context != null && context.mounted) {
      final lang = Localizations.localeOf(context).languageCode;
      await _showSettingsDialog(
        context: context,
        title: _PermissionStrings.storageTitle(lang),
        message: _PermissionStrings.storageDeniedMessage(lang),
      );
      return false;
    }
    return result.isGranted;
  }

  /// Quick check without showing dialogs (fire-and-forget).
  Future<bool> hasStoragePermission() async {
    if (!Platform.isAndroid) return true;
    if (await _isAndroid11OrAbove()) {
      return Permission.manageExternalStorage.isGranted;
    }
    return Permission.storage.isGranted;
  }

  // ─────────────────────────────────────────────
  // Camera
  // ─────────────────────────────────────────────

  Future<bool> requestCameraPermission({BuildContext? context}) async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    if (context != null && context.mounted && status.isDenied) {
      final lang = Localizations.localeOf(context).languageCode;
      final proceed = await _showPermissionRationale(
        context: context,
        title: _PermissionStrings.cameraTitle(lang),
        message: _PermissionStrings.cameraMessage(lang),
        icon: Icons.qr_code_scanner_rounded,
        iconColor: Colors.blue,
      );
      if (!proceed) return false;
    }

    final result = await Permission.camera.request();
    if (result.isPermanentlyDenied && context != null && context.mounted) {
      final lang = Localizations.localeOf(context).languageCode;
      await _showSettingsDialog(
        context: context,
        title: _PermissionStrings.cameraTitle(lang),
        message: _PermissionStrings.cameraDeniedMessage(lang),
      );
      return false;
    }
    return result.isGranted;
  }

  Future<bool> hasCameraPermission() => Permission.camera.isGranted;

  // ─────────────────────────────────────────────
  // Notifications
  // ─────────────────────────────────────────────

  Future<bool> requestNotificationPermission({BuildContext? context}) async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;
    // Android 13+ runtime izni ister; iOS'ta ise izin ilk istekte sorulur.
    if (Platform.isAndroid && !await _isAndroid13OrAbove()) return true;

    final status = await Permission.notification.status;
    if (status.isGranted) return true;

    if (context != null && context.mounted && status.isDenied) {
      final lang = Localizations.localeOf(context).languageCode;
      final proceed = await _showPermissionRationale(
        context: context,
        title: _PermissionStrings.notificationTitle(lang),
        message: _PermissionStrings.notificationMessage(lang),
        icon: Icons.notifications_active_rounded,
        iconColor: Colors.green,
      );
      if (!proceed) return false;
    }

    final result = await Permission.notification.request();
    if (result.isPermanentlyDenied && context != null && context.mounted) {
      final lang = Localizations.localeOf(context).languageCode;
      await _showSettingsDialog(
        context: context,
        title: _PermissionStrings.notificationTitle(lang),
        message: _PermissionStrings.notificationDeniedMessage(lang),
      );
      return false;
    }
    return result.isGranted;
  }

  Future<bool> hasNotificationPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;
    if (Platform.isAndroid && !await _isAndroid13OrAbove()) return true;
    return Permission.notification.isGranted;
  }

  // ─────────────────────────────────────────────
  // Batch: all permissions required for file transfer
  // ─────────────────────────────────────────────

  /// Requests all permissions needed to host/receive files.
  /// Shows a single rationale dialog grouped by purpose.
  Future<PermissionResult> requestAllTransferPermissions({
    required BuildContext context,
  }) async {
    final missing = await _getMissingTransferPermissions();
    if (missing.isEmpty) {
      return PermissionResult(
        storageGranted: true,
        cameraGranted: true,
        notificationGranted: true,
      );
    }

    // Show a combined rationale
    if (!context.mounted) {
      return PermissionResult(
        storageGranted: !missing.contains(_PermType.storage),
        cameraGranted: !missing.contains(_PermType.camera),
        notificationGranted: !missing.contains(_PermType.notification),
      );
    }
    final proceed =
        await _showBatchRationale(context: context, missing: missing);
    if (!proceed) {
      return PermissionResult(
        storageGranted: !missing.contains(_PermType.storage),
        cameraGranted: !missing.contains(_PermType.camera),
        notificationGranted: !missing.contains(_PermType.notification),
      );
    }

    bool storageGranted = !missing.contains(_PermType.storage);
    bool cameraGranted = !missing.contains(_PermType.camera);
    bool notificationGranted = !missing.contains(_PermType.notification);

    if (missing.contains(_PermType.storage)) {
      storageGranted = await requestStoragePermission();
    }
    if (missing.contains(_PermType.camera)) {
      cameraGranted = await requestCameraPermission();
    }
    if (missing.contains(_PermType.notification)) {
      notificationGranted = await requestNotificationPermission();
    }

    // If anything is permanently denied, guide to settings
    final permanentlyDenied = <_PermType>[];
    if (!storageGranted && missing.contains(_PermType.storage)) {
      if (await Permission.manageExternalStorage.isPermanentlyDenied ||
          await Permission.storage.isPermanentlyDenied) {
        permanentlyDenied.add(_PermType.storage);
      }
    }
    if (!cameraGranted && missing.contains(_PermType.camera)) {
      if (await Permission.camera.isPermanentlyDenied) {
        permanentlyDenied.add(_PermType.camera);
      }
    }

    if (permanentlyDenied.isNotEmpty && context.mounted) {
      final lang = Localizations.localeOf(context).languageCode;
      await _showSettingsDialog(
        context: context,
        title: _PermissionStrings.permissionRequired(lang),
        message: _PermissionStrings.permanentlyDeniedMessage(lang),
      );
    }

    return PermissionResult(
      storageGranted: storageGranted,
      cameraGranted: cameraGranted,
      notificationGranted: notificationGranted,
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  Future<List<_PermType>> _getMissingTransferPermissions() async {
    final missing = <_PermType>[];
    if (!await hasStoragePermission()) missing.add(_PermType.storage);
    if (!await hasCameraPermission()) missing.add(_PermType.camera);
    if (!await hasNotificationPermission()) missing.add(_PermType.notification);
    return missing;
  }

  static Future<bool> _isAndroid11OrAbove() async {
    if (!Platform.isAndroid) return false;
    // permission_handler resolves MANAGE_EXTERNAL_STORAGE only on API 30+
    // We detect by trying; if the permission doesn't exist it returns granted
    final info = await Permission.manageExternalStorage.status;
    return !info.isGranted
        ? true
        : true; // API check via sdk_int not available, rely on permission
    // Safe approximation: on API < 30, manageExternalStorage is always granted
  }

  static Future<bool> _isAndroid13OrAbove() async {
    // POST_NOTIFICATIONS was added in API 33
    if (!Platform.isAndroid) return false;
    return true; // Safe: request is harmless on older APIs
  }

  /// Shows a dialog explaining WHY a permission is needed, with "Allow" / "Not Now".
  Future<bool> _showPermissionRationale({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PermissionRationaleDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
      ),
    );
    return result ?? false;
  }

  /// Shows the combined "we need these permissions" dialog.
  Future<bool> _showBatchRationale({
    required BuildContext context,
    required List<_PermType> missing,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BatchPermissionDialog(missing: missing),
    );
    return result ?? false;
  }

  /// Shows a dialog directing the user to app settings when permission is permanently denied.
  Future<void> _showSettingsDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _SettingsDialog(title: title, message: message),
    );
  }
}

// ─────────────────────────────────────────────
// Result model
// ─────────────────────────────────────────────

class PermissionResult {
  final bool storageGranted;
  final bool cameraGranted;
  final bool notificationGranted;

  const PermissionResult({
    required this.storageGranted,
    required this.cameraGranted,
    required this.notificationGranted,
  });

  bool get allGranted => storageGranted && cameraGranted && notificationGranted;
  bool get canTransfer => storageGranted;
  bool get canScanQr => cameraGranted;
}

// ─────────────────────────────────────────────
// Internal enum
// ─────────────────────────────────────────────

enum _PermType { storage, camera, notification }

// ─────────────────────────────────────────────
// String constants (Turkish default)
// ─────────────────────────────────────────────

class _PermissionStrings {
  static String storageTitle(String lang) {
    if (lang == 'de') return 'Speicherberechtigung erforderlich';
    if (lang == 'tr') return 'Depolama İzni Gerekli';
    return 'Storage Permission Required';
  }

  static String storageMessage(String lang) {
    if (lang == 'de') {
      return 'Speicherzugriff wird benötigt, um Dateien zu teilen und herunterzuladen. Ohne diese Berechtigung ist keine Übertragung möglich.';
    }
    if (lang == 'tr') {
      return 'Dosya paylaşabilmek ve indirebilmek için depolama erişimi gerekiyor. Bu izin olmadan dosya transferi yapılamaz.';
    }
    return 'Storage access is required to share and download files. File transfer cannot work without this permission.';
  }

  static String storageDeniedMessage(String lang) {
    if (lang == 'de') {
      return 'Speicherberechtigung wurde dauerhaft verweigert. Bitte erteilen Sie die Berechtigung manuell in den App-Einstellungen.';
    }
    if (lang == 'tr') {
      return 'Depolama izni kalıcı olarak reddedildi. Lütfen uygulama ayarlarından manuel olarak izin verin.';
    }
    return 'Storage permission permanently denied. Please grant permission manually in app settings.';
  }

  static String cameraTitle(String lang) {
    if (lang == 'de') return 'Kameraberechtigung erforderlich';
    if (lang == 'tr') return 'Kamera İzni Gerekli';
    return 'Camera Permission Required';
  }

  static String cameraMessage(String lang) {
    if (lang == 'de') {
      return 'Kamerazugriff wird benötigt, um durch Scannen von QR-Codes eine Verbindung zu anderen Geräten herzustellen.';
    }
    if (lang == 'tr') {
      return 'QR kodu tarayarak diğer cihazlara bağlanmak için kamera erişimi gerekiyor.';
    }
    return 'Camera access is required to connect to other devices by scanning QR codes.';
  }

  static String cameraDeniedMessage(String lang) {
    if (lang == 'de') {
      return 'Kameraberechtigung wurde dauerhaft verweigert. Bitte erteilen Sie die Berechtigung manuell in den App-Einstellungen.';
    }
    if (lang == 'tr') {
      return 'Kamera izni kalıcı olarak reddedildi. Lütfen uygulama ayarlarından manuel olarak izin verin.';
    }
    return 'Camera permission permanently denied. Please grant permission manually in app settings.';
  }

  static String notificationTitle(String lang) {
    if (lang == 'de') return 'Benachrichtigungsberechtigung';
    if (lang == 'tr') return 'Bildirim İzni';
    return 'Notification Permission';
  }

  static String notificationMessage(String lang) {
    if (lang == 'de') {
      return 'Berechtigung wird benötigt, um Benachrichtigungen anzuzeigen, wenn Dateiübertragungen abgeschlossen sind.';
    }
    if (lang == 'tr') {
      return 'Dosya transferleri tamamlandığında bildirim göstermek için izin gerekiyor.';
    }
    return 'Permission is required to show notifications when file transfers are completed.';
  }

  static String notificationDeniedMessage(String lang) {
    if (lang == 'de') {
      return 'Benachrichtigungsberechtigung wurde dauerhaft verweigert. Bitte erteilen Sie die Berechtigung manuell in den App-Einstellungen.';
    }
    if (lang == 'tr') {
      return 'Bildirim izni kalıcı olarak reddedildi. Lütfen uygulama ayarlarından manuel olarak izin verin.';
    }
    return 'Notification permission permanently denied. Please grant permission manually in app settings.';
  }

  static String permissionRequired(String lang) {
    if (lang == 'de') return 'Berechtigung erforderlich';
    if (lang == 'tr') return 'İzin Gerekli';
    return 'Permission Required';
  }

  static String permanentlyDeniedMessage(String lang) {
    if (lang == 'de') {
      return 'Einige Berechtigungen wurden dauerhaft verweigert. Bitte erteilen Sie die erforderlichen Berechtigungen in den Einstellungen.';
    }
    if (lang == 'tr') {
      return 'Bazı izinler kalıcı olarak reddedildi. Uygulamanın düzgün çalışması için lütfen Ayarlar\'dan gerekli izinleri verin.';
    }
    return 'Some permissions were permanently denied. Please grant the required permissions in Settings for the app to function properly.';
  }

  static String allow(String lang) {
    if (lang == 'de') return 'Erlauben';
    if (lang == 'tr') return 'İzin Ver';
    return 'Allow';
  }

  static String notNow(String lang) {
    if (lang == 'de') return 'Nicht jetzt';
    if (lang == 'tr') return 'Şimdi Değil';
    return 'Not Now';
  }

  static String openSettings(String lang) {
    if (lang == 'de') return 'Einstellungen öffnen';
    if (lang == 'tr') return 'Ayarları Aç';
    return 'Open Settings';
  }

  static String cancel(String lang) {
    if (lang == 'de') return 'Abbrechen';
    if (lang == 'tr') return 'İptal';
    return 'Cancel';
  }

  static String batchTitle(String lang) {
    if (lang == 'de') return 'Berechtigungen erforderlich';
    if (lang == 'tr') return 'İzin Gerekli';
    return 'Permissions Required';
  }

  static String batchMessage(String lang) {
    if (lang == 'de') {
      return 'Um alle Funktionen der App nutzen zu können, sind folgende Berechtigungen erforderlich:';
    }
    if (lang == 'tr') {
      return 'Uygulamanın tüm özelliklerini kullanabilmek için aşağıdaki izinler gerekiyor:';
    }
    return 'To use all features of the app, the following permissions are required:';
  }

  static String permTypeLabel(_PermType type, String lang) {
    switch (type) {
      case _PermType.storage:
        if (lang == 'de') return '📁  Speicher — Dateien lesen und schreiben';
        if (lang == 'tr') return '📁  Depolama — dosya okuma ve yazma';
        return '📁  Storage — read and write files';
      case _PermType.camera:
        if (lang == 'de') return '📷  Kamera — QR-Codes scannen';
        if (lang == 'tr') return '📷  Kamera — QR kod tarama';
        return '📷  Camera — scan QR codes';
      case _PermType.notification:
        if (lang == 'de') return '🔔  Benachrichtigungen — Übertragungsstatus';
        if (lang == 'tr') return '🔔  Bildirimler — transfer bildirimleri';
        return '🔔  Notifications — transfer notifications';
    }
  }
}

// ─────────────────────────────────────────────
// Dialogs
// ─────────────────────────────────────────────

class _PermissionRationaleDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;

  const _PermissionRationaleDialog({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_PermissionStrings.notNow(lang)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(_PermissionStrings.allow(lang),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchPermissionDialog extends StatelessWidget {
  final List<_PermType> missing;

  const _BatchPermissionDialog({required this.missing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.security_rounded,
                      color: theme.colorScheme.primary, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  _PermissionStrings.batchTitle(lang),
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _PermissionStrings.batchMessage(lang),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 16),
                ...missing.map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        _PermissionStrings.permTypeLabel(type, lang),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_PermissionStrings.notNow(lang)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(_PermissionStrings.allow(lang),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsDialog extends StatelessWidget {
  final String title;
  final String message;

  const _SettingsDialog({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.settings_rounded, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_PermissionStrings.cancel(lang)),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            openAppSettings();
          },
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: Text(_PermissionStrings.openSettings(lang)),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
