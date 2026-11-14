import '../../core/models/enums.dart';
import '../../core/services/rating_service.dart';
import '../../data/models/transfer.dart';
import '../../data/models/transfer_file.dart';
import '../../data/repositories/transfer_repository.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/permission_service.dart';
import '../../data/services/local_network_service.dart';
import '../../data/services/notification_service.dart';
import '../../core/utils/helpers.dart';
import '../widgets/qr_code_widget.dart';
import '../blocs/settings/settings_bloc.dart';

class LocalHostingPage extends StatefulWidget {
  final List<File> files;
  final String? sharedText;

  const LocalHostingPage({
    super.key,
    required this.files,
    this.sharedText,
  });

  @override
  State<LocalHostingPage> createState() => _LocalHostingPageState();
}

class _LocalHostingPageState extends State<LocalHostingPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final LocalNetworkService _networkService = LocalNetworkService();
  final PermissionService _permissionService = PermissionService();
  late List<File> _hostedFiles;
  String? _serverUrl;
  bool _isLoading = true;
  String? _error;
  bool _isPinEnabled = false;
  String? _pin;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  bool _isRestartingServer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _hostedFiles = List.from(widget.files);
    _generatePin();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _startServer();
    _setupFileReceivedListener();
  }

  void _generatePin() {
    final random = math.Random();
    _pin = (1000 + random.nextInt(9000)).toString();
  }

  void _setupFileReceivedListener() {
    _networkService.onFileReceived = (fileName, filePath) async {
      if (!mounted) return;

      // iOS'ta kısa, iOS'ta olmayan platformlarda etkisiz dokunma geri bildirimi.
      if (Platform.isIOS) {
        HapticFeedback.mediumImpact();
      }

      // Show local notification
      NotificationService().showDownloadCompleteNotification(
        fileName,
        filePath,
        title: AppLocalizations.of(context)?.transferCompleted,
        body: AppLocalizations.of(context)?.fileReceivedFrom(fileName),
      );

      try {
        context.read<RatingService>().recordTransfer();
      } catch (_) {}

      // Persist received transfer to SQLite so it appears in "Son Aktarılanlar"
      await _recordIncomingTransfer(fileName, filePath);

      if (mounted) {
        _showTransferNotification(
          message: AppLocalizations.of(context)!.fileReceivedFrom(fileName),
          filePath: filePath,
          isReceived: true,
        );
      }
    };

    _networkService.onFileSent = (fileName) {
      if (mounted) {
        final transferredWord = AppLocalizations.of(context)?.transferred ?? 'aktarıldı';
        _showTransferNotification(
          message: '✓ $fileName $transferredWord',
          isReceived: false,
        );
      }
    };
  }

  void _showTransferNotification({
    required String message,
    String? filePath,
    bool isReceived = true,
  }) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isReceived ? Icons.download_done_rounded : Icons.upload_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (filePath != null) ...[
              TextButton(
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  OpenFilex.open(filePath);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n?.open ?? 'Aç',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 6),
            ],
            // 'X' button to dismiss bottom notification immediately
            InkWell(
              onTap: () => messenger.hideCurrentSnackBar(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isReceived ? const Color(0xFF10B981) : const Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Future<void> _recordOutgoingTransfer() async {
    if (_hostedFiles.isEmpty) return;
    try {
      final transferId = 'tx_${DateTime.now().millisecondsSinceEpoch}';
      final transferFiles = _hostedFiles.map((file) {
        final name = file.path.split(Platform.pathSeparator).last;
        int size = 0;
        try {
          if (file.existsSync()) size = file.lengthSync();
        } catch (_) {}
        final ext = name.contains('.') ? name.split('.').last : 'file';
        return TransferFile(
          name: name,
          size: size,
          type: ext,
          progress: 1.0,
          status: FileStatus.completed,
        );
      }).toList();

      final transfer = Transfer(
        id: transferId,
        status: TransferStatus.completed,
        files: transferFiles,
        progress: 1.0,
        timestamp: DateTime.now(),
        direction: TransferDirection.sent,
        senderName: _getDeviceName(),
        receiverName: 'Wi-Fi / Web',
      );

      final repo = context.read<TransferRepository>();
      await repo.addTransfer(transfer);
    } catch (e) {
      debugPrint('Error recording outgoing transfer: $e');
    }
  }

  Future<void> _recordIncomingTransfer(String fileName, String filePath) async {
    try {
      final file = File(filePath);
      int size = 0;
      try {
        if (file.existsSync()) size = file.lengthSync();
      } catch (_) {}
      final ext = fileName.contains('.') ? fileName.split('.').last : 'file';

      final transfer = Transfer(
        id: 'rx_${DateTime.now().millisecondsSinceEpoch}',
        status: TransferStatus.completed,
        files: [
          TransferFile(
            name: fileName,
            size: size,
            type: ext,
            progress: 1.0,
            status: FileStatus.completed,
          ),
        ],
        progress: 1.0,
        timestamp: DateTime.now(),
        direction: TransferDirection.received,
        senderName: 'Sender',
        receiverName: _getDeviceName(),
      );

      final repo = context.read<TransferRepository>();
      await repo.addTransfer(transfer);
    } catch (e) {
      debugPrint('Error recording incoming transfer: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (!Platform.isAndroid) return;
    await _permissionService.requestStoragePermission(
        context: mounted ? context : null);
    await _permissionService.requestNotificationPermission(
        context: mounted ? context : null);
  }

  Future<void> _startServer() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Request permissions before starting server
    if (Platform.isAndroid) {
      await _requestPermissions();
    }

    try {
      final ip = await _networkService.getLocalIpAddress();
      if (ip == null) {
        throw Exception(AppLocalizations.of(context)!.ipAddressTakenError);
      }

      _networkService.setSharedText(widget.sharedText);
      _networkService.setSenderName(await _getUserName());
      _networkService.setDeviceName(_getDeviceName());
      _networkService.setLanguage(_getLanguageCode());
      _networkService.setProfilePicture(_getProfilePicturePath());
      _networkService.setDownloadDirectory(_getDownloadDirectory());

      final success = await _networkService.startServer(_hostedFiles,
          pin: _isPinEnabled ? _pin : null);
      if (!success) {
        throw Exception(AppLocalizations.of(context)!.serverStartError);
      }

      WakelockPlus.enable();
      await _recordOutgoingTransfer();
      setState(() {
        _serverUrl = _networkService.getServerUrl(ip);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getDeviceName() {
    try {
      final settingsState = context.read<SettingsBloc>().state;
      if (settingsState.deviceName.isNotEmpty) {
        return settingsState.deviceName;
      }
      return Platform.localHostname;
    } catch (e) {
      return '';
    }
  }

  Future<String> _getUserName() async {
    try {
      final settingsState = context.read<SettingsBloc>().state;
      if (settingsState.username.isNotEmpty) {
        return settingsState.username;
      }
      return Platform.localHostname;
    } catch (e) {
      return 'File Transfer User';
    }
  }

  String _getLanguageCode() {
    try {
      final settingsState = context.read<SettingsBloc>().state;
      return settingsState.language.value;
    } catch (e) {
      return 'tr';
    }
  }

  String? _getProfilePicturePath() {
    try {
      final settingsState = context.read<SettingsBloc>().state;
      return settingsState.profilePicturePath;
    } catch (e) {
      return null;
    }
  }

  String? _getDownloadDirectory() {
    try {
      final settingsState = context.read<SettingsBloc>().state;
      if (settingsState.downloadDirectory != null &&
          settingsState.downloadDirectory!.isNotEmpty) {
        return settingsState.downloadDirectory;
      }
      return context.read<SettingsBloc>().repository.getEffectiveDownloadDirectory();
    } catch (e) {
      return null;
    }
  }

  Future<void> _stopSharing() async {
    await _networkService.stopServer();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _copyUrl() {
    if (_serverUrl != null) {
      if (Platform.isIOS) {
        HapticFeedback.lightImpact();
      }
      Clipboard.setData(ClipboardData(text: _serverUrl!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.urlCopied),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  int get _totalSize {
    return _hostedFiles.fold(0, (sum, file) {
      try {
        if (file.existsSync()) {
          return sum + file.lengthSync();
        }
        return sum;
      } catch (e) {
        return sum;
      }
    });
  }

  Future<void> _addFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result != null && result.files.isNotEmpty) {
        final newFiles = result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
        setState(() {
          _hostedFiles.insertAll(0, newFiles);
          _networkService.updateSharedFiles(_hostedFiles);
        });
        await _recordOutgoingTransfer();

        if (mounted) {
          _showTransferNotification(
            message: '${newFiles.length} ${AppLocalizations.of(context)!.filesAdded}',
            isReceived: false,
          );
        }
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // iOS uygulamayı arka plana alınca ağ sunucusunu askıya alır.
    // Uygulamaya dönüldüğünde paylaşım sessizce yeniden açılır.
    if (state == AppLifecycleState.resumed &&
        _serverUrl != null &&
        !_networkService.isRunning) {
      _restartServerAfterBackground();
    }
  }

  Future<void> _restartServerAfterBackground() async {
    if (_isRestartingServer) return;
    _isRestartingServer = true;
    try {
      final ip = await _networkService.getLocalIpAddress();
      final success = await _networkService.startServer(
        _hostedFiles,
        pin: _isPinEnabled ? _pin : null,
      );
      if (!mounted) return;
      setState(() {
        _serverUrl = success ? _networkService.getServerUrl(ip) : null;
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.serverRestarted),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      _isRestartingServer = false;
    }
  }

  Widget _buildIosLocalNetworkHint(ThemeData theme) {
    if (!Platform.isIOS) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.iosLocalNetworkHint,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    _pulseController.dispose();
    _rotationController.dispose();
    _networkService.stopServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF0F0F23), const Color(0xFF1A1A2E)]
                  : [
                      Colors.white,
                      theme.colorScheme.primary.withValues(alpha: 0.05)
                    ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3),
                ),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)!.preparingSharing,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.startingServer,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF0F0F23), const Color(0xFF1A1A2E)]
                  : [Colors.white, Colors.red.withValues(alpha: 0.05)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.error_outline_rounded,
                        size: 64, color: Colors.red.shade400),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.sharingFailed,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Text(_error!,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          child: Text(AppLocalizations.of(context)!.goBack,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _stopSharing();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.wifi_tethering_rounded,
                    color: Colors.green, size: 18),
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.sharingActive,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                  Platform.isIOS
                      ? CupertinoIcons.back
                      : Icons.arrow_back_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface),
            ),
            onPressed: _stopSharing,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton.icon(
                onPressed: _addFiles,
                style: TextButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: Icon(Icons.add_box_rounded,
                    size: 22, color: theme.colorScheme.primary),
                label: Text(
                  AppLocalizations.of(context)!.addMore,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF0F0F23), const Color(0xFF1A1A2E)]
                  : [
                      Colors.white,
                      theme.colorScheme.primary.withValues(alpha: 0.05)
                    ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card with Animation
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.cloud_done_rounded,
                                    color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '✨ ${AppLocalizations.of(context)!.serverActive}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .filesSharing(widget.files.length),
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      AppLocalizations.of(context)!.live,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  _buildIosLocalNetworkHint(theme),

                  if (widget.sharedText != null &&
                      widget.sharedText!.trim().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.link_rounded,
                                    color: theme.colorScheme.primary, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Paylaşılan Bağlantı',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      'Wi-Fi ile diğer cihazlara aktarılıyor',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: SelectableText(
                              widget.sharedText!,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(
                                        text: widget.sharedText!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            AppLocalizations.of(context)!
                                                .copiedToClipboard),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy_rounded, size: 18),
                                  label: const Text('Kopyala'),
                                ),
                              ),
                              if (widget.sharedText!.startsWith('http://') ||
                                  widget.sharedText!.startsWith('https://')) ...[
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final uri =
                                          Uri.tryParse(widget.sharedText!);
                                      if (uri != null) {
                                        await launchUrl(uri,
                                            mode:
                                                LaunchMode.externalApplication);
                                      }
                                    },
                                    icon: const Icon(Icons.open_in_browser_rounded,
                                        size: 18),
                                    label: const Text('Aç'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // QR Code Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner_rounded,
                                color: theme.colorScheme.primary, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.connectWithQRCode,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.15),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: QrCodeWidget(data: _serverUrl!, size: 200),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: theme.colorScheme.primary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .receiverScanQRMessage,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // PIN Security Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lock_rounded,
                                    color: theme.colorScheme.primary, size: 22),
                                const SizedBox(width: 12),
                                Text(
                                  AppLocalizations.of(context)!.pinProtection,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: _isPinEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _isPinEnabled = value;
                                  if (value && _pin == null) {
                                    _generatePin();
                                  }
                                  _startServer(); // Restart server with new PIN settings
                                });
                              },
                              activeThumbColor: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                        if (_isPinEnabled) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _pin ?? '----',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 8,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: const Icon(Icons.refresh_rounded),
                                  onPressed: () {
                                    setState(() {
                                      _generatePin();
                                      _startServer();
                                    });
                                  },
                                  tooltip: AppLocalizations.of(context)!
                                      .generateNewPIN,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.pinMessage,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Connection Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF667EEA).withValues(alpha: 0.2),
                                const Color(0xFF764BA2).withValues(alpha: 0.2)
                              ]
                            : [
                                const Color(0xFF667EEA).withValues(alpha: 0.1),
                                const Color(0xFF764BA2).withValues(alpha: 0.1)
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.router,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.connectionInfo,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // IP Address
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.router,
                                  color: theme.colorScheme.primary, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                'IP:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _serverUrl!
                                      .replaceFirst('http://', '')
                                      .split(':')[0],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Port
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.settings_ethernet,
                                  color: theme.colorScheme.primary, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                'Port:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _serverUrl!.split(':').last,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Full URL
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.link_rounded,
                                  color: theme.colorScheme.primary, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _serverUrl!,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _copyUrl,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary,
                                          theme.colorScheme.secondary
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.copy_rounded,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Files List
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF667EEA)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.folder_rounded,
                                      color: Color(0xFF667EEA), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  AppLocalizations.of(context)!.sharedFiles,
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: _addFiles,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.add_circle_rounded,
                                            color: Color(0xFF667EEA), size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppLocalizations.of(context)!.addMore,
                                          style: const TextStyle(
                                            color: Color(0xFF667EEA),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                Helpers.formatBytes(_totalSize),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._hostedFiles.asMap().entries.map((entry) {
                          final file = entry.value;
                          final fileName =
                              file.path.split(Platform.pathSeparator).last;
                          String fileSize = '0 B';
                          try {
                            if (file.existsSync()) {
                              fileSize = Helpers.formatBytes(file.lengthSync());
                            } else {
                              fileSize = l10n.fileNotFound;
                            }
                          } catch (e) {
                            fileSize = l10n.error;
                          }
                          final extension =
                              fileName.split('.').last.toLowerCase();
                          final iconData = _getFileIcon(extension);
                          final iconColor = _getFileColor(extension);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(iconData,
                                      size: 22, color: iconColor),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fileName,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.data_usage_rounded,
                                            size: 12,
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            fileSize,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.7),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.check_circle_rounded,
                                    color: Colors.green.shade400, size: 20),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                          theme.colorScheme.secondary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_rounded,
                            color: theme.colorScheme.primary, size: 22),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.keepScreenOpenMessage,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stop Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade600]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _stopSharing,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.stop_circle_rounded,
                                  color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(context)!.stopSharing,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
      case 'ods':
        return Icons.table_chart_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image_rounded;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
        return Icons.video_file_rounded;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file_rounded;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileColor(String extension) {
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
      case 'ods':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Colors.purple;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
        return Colors.pink;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Colors.teal;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
