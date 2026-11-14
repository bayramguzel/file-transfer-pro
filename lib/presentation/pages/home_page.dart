import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/enums.dart' as enums;
import '../../core/services/permission_service.dart';
import '../../core/services/rating_service.dart';
import '../../core/services/support_service.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/transfer.dart';
import '../../data/repositories/transfer_repository.dart';
import '../../data/services/device_discovery_service.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_event.dart';
import '../blocs/settings/settings_state.dart';
import '../widgets/app_drawer.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/network_status_indicator.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/smooth_animations.dart';
import '../widgets/support_dialog.dart';
import 'app_selection_page.dart';
import 'clipboard_page.dart';
import 'local_hosting_page.dart';
import 'local_send_page.dart';
import 'qr_scanner_page.dart';
import 'transfer_detail_page.dart';
import 'transfer_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final DeviceDiscoveryService _discoveryService = DeviceDiscoveryService();
  final PermissionService _permissionService = PermissionService();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription? _intentDataStreamSubscription;

  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _gradientController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  bool _isWifiConnected = false;
  String? _wifiIp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAnimations();
    _checkConnectivityAndStartDiscovery();
    _listenToConnectivity();
    _initSharingIntent();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
      _checkAndShowRatingPrompt();
    });
  }

  Future<void> _checkAndShowRatingPrompt() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    try {
      final ratingService = context.read<RatingService>();
      if (ratingService.shouldPromptForRating()) {
        RatingDialog.show(context, ratingService);
      }
    } catch (_) {}
  }

  Future<void> _requestPermissions() async {
    if (!mounted) return;
    // iOS'ta izinler kullanım anında istenir (QR tarama, kamera);
    // açılışta toplu izin istemi App Store yönergeleriyle uyumlu değildir.
    if (Platform.isIOS) return;
    await _permissionService.requestAllTransferPermissions(context: context);
  }

  void _initSharingIntent() {
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleSharedFiles(value);
      }
    }, onError: (err) {
      debugPrint("getIntentDataStream error: $err");
    });

    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleSharedFiles(value);
        ReceiveSharingIntent.instance.reset();
      }
    });
  }

  Future<void> _handleSharedFiles(List<SharedMediaFile> sharedFiles) async {
    if (sharedFiles.isEmpty) return;

    final List<File> realFiles = [];
    String? detectedLinkOrText;

    for (final item in sharedFiles) {
      final path = item.path;
      final isUrlOrText = item.type == SharedMediaType.url ||
          item.type == SharedMediaType.text ||
          path.startsWith('http://') ||
          path.startsWith('https://');

      bool isExistingFile = false;
      if (!isUrlOrText) {
        try {
          isExistingFile = File(path).existsSync();
        } catch (_) {
          isExistingFile = false;
        }
      }

      if (isUrlOrText || !isExistingFile) {
        detectedLinkOrText = path;
      } else {
        realFiles.add(File(path));
      }
    }

    // If a link or text was shared, create a shortcut file (.html / .txt)
    // so it can also be downloaded / transferred as a clean file across devices!
    if (detectedLinkOrText != null && detectedLinkOrText.trim().isNotEmpty) {
      try {
        final tempDir = await getTemporaryDirectory();
        final text = detectedLinkOrText.trim();
        final isUrl = text.startsWith('http://') || text.startsWith('https://');
        final fileName = isUrl ? 'paylasilan_baglanti.txt' : 'paylasilan_metin.txt';
        final shortcutFile = File('${tempDir.path}/$fileName');
        await shortcutFile.writeAsString(text);
        realFiles.add(shortcutFile);
      } catch (e) {
        debugPrint('Error creating shortcut file: $e');
      }
    }

    if (mounted && (realFiles.isNotEmpty || detectedLinkOrText != null)) {
      Navigator.of(context).push(
        SmoothPageRoute(
          page: LocalHostingPage(
            files: realFiles,
            sharedText: detectedLinkOrText,
          ),
        ),
      );
    }
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _intentDataStreamSubscription?.cancel();
    _pulseController.dispose();
    _floatController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnectivityAndStartDiscovery();
    }
  }

  Future<void> _checkConnectivityAndStartDiscovery() async {
    final results = await Connectivity().checkConnectivity();
    final isConnectedToWlan = results.contains(ConnectivityResult.wifi);

    String? ip;
    if (isConnectedToWlan) {
      try {
        ip = await NetworkInfo().getWifiIP();
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _isWifiConnected = isConnectedToWlan;
        _wifiIp = ip;
      });
    }

    if (isConnectedToWlan && !_discoveryService.isDiscovering) {
      try {
        await _discoveryService.startDiscovery();
      } catch (_) {}
    }
  }

  void _listenToConnectivity() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      _checkConnectivityAndStartDiscovery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AnimatedLogo(animation: _pulseAnimation),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ).createShader(bounds),
              child: Text(
                s.appTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          const NetworkStatusIndicator(),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              final isDarkMode = state.themeMode == enums.ThemeMode.dark;
              return IconButton(
                tooltip: isDarkMode ? s.themeLight : s.themeDark,
                icon: Icon(
                  isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  context.read<SettingsBloc>().add(
                        UpdateThemeMode(
                          isDarkMode
                              ? enums.ThemeMode.light
                              : enums.ThemeMode.dark,
                        ),
                      );
                },
              );
            },
          ),
          Consumer<SupportService>(
            builder: (context, supportService, child) {
              final isActive = supportService.isSupportActive;
              return IconButton(
                tooltip: s.supportApp,
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isActive
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: isActive ? Colors.amber : null,
                      size: 24,
                    ),
                    if (!isActive)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => SupportDialog.show(context),
              );
            },
          ),
          IconButton(
            tooltip: s.shareWithFriends,
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              // iOS'ta paylaşım metni App Store bağlantısı içerir; iPad'de
              // paylaşım sayfasının konumu belirtilmelidir.
              final shareText = Platform.isIOS
                  ? s.shareAppText.replaceAll(
                      AppConstants.googlePlayUrl,
                      AppConstants.appStoreId.isEmpty
                          ? AppConstants.websiteUrl
                          : AppConstants.appStoreUrl,
                    )
                  : s.shareAppText;
              final shareBox = context.findRenderObject() as RenderBox?;
              Share.share(
                shareText,
                sharePositionOrigin: shareBox == null
                    ? null
                    : shareBox.localToGlobal(Offset.zero) & shareBox.size,
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {
                HapticFeedback.lightImpact();
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: Stack(
        children: [
          _AnimatedBackground(
            controller: _gradientController,
            isDark: isDark,
            primaryColor: theme.colorScheme.primary,
            secondaryColor: theme.colorScheme.secondary,
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Personalized User Profile & Wi-Fi Status Header
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: child,
                    ),
                    child: BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, state) {
                        return _ProfileAndNetworkHeader(
                          state: state,
                          isWifiConnected: _isWifiConnected,
                          wifiIp: _wifiIp,
                          onOpenSettings: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          onWifiTap: () {
                            if (!_isWifiConnected) {
                              _showWlanRequiredDialog(context);
                            }
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Section Header: Quick Actions
                  _SectionHeader(
                    icon: Icons.grid_view_rounded,
                    title: s.quickActions,
                    theme: theme,
                  ),

                  const SizedBox(height: 12),

                  // 3. Balanced 2x2 Action Grid (Fast, easy, touch-friendly)
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.18,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _ModernActionCard(
                        icon: Icons.cloud_upload_rounded,
                        colors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        title: s.sendFile,
                        subtitle: s.shareFilesSecurely,
                        tag: '⚡ ${s.fast}',
                        onTap: () => _navigateToLocalSend(context),
                      ),
                      _ModernActionCard(
                        icon: Icons.qr_code_scanner_rounded,
                        colors: const [Color(0xFF059669), Color(0xFF10B981)],
                        title: s.receiveFile,
                        subtitle: s.receiveFilesDescription,
                        tag: '📷 QR',
                        onTap: () => _navigateToQrScanner(context),
                      ),
                      // APK/uygulama paylaşımı Android'e özgüdür.
                      if (!Platform.isIOS)
                        _ModernActionCard(
                          icon: Icons.android_rounded,
                          colors: const [Color(0xFFF97316), Color(0xFFEF4444)],
                          title: s.shareApp,
                          subtitle: s.shareAppDescription,
                          tag: '📱 APK',
                          onTap: () => _navigateToAppSelection(context),
                        ),
                      _ModernActionCard(
                        icon: Icons.content_paste_rounded,
                        colors: const [Color(0xFF0284C7), Color(0xFF06B6D4)],
                        title: s.clipboardSync,
                        subtitle: s.clipboardSharingDescription,
                        tag: '📋 ${s.easy}',
                        onTap: () => _navigateToClipboard(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 4. Quick Utilities & Folder Bar
                  _QuickUtilitiesBar(
                    onOpenHistory: () => _navigateToHistory(context),
                    onRateApp: () {
                      RatingDialog.show(context, context.read<RatingService>());
                    },
                    onOpenFolderInfo: () {
                      final path = context
                          .read<SettingsBloc>()
                          .repository
                          .getEffectiveDownloadDirectory();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.folder_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${s.appFolderNotice}\n$path',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // 5. Recent Transfers Section (Live DB Stream)
                  _RecentTransfersSection(
                    onSeeAll: () => _navigateToHistory(context),
                  ),

                  const SizedBox(height: 20),

                  // 6. How it works accordion
                  _AccordionSection(
                    icon: Icons.lightbulb_outline_rounded,
                    title: s.howItWorks,
                    theme: theme,
                    isDark: isDark,
                    initiallyExpanded: false,
                    child: _HowItWorksCard(theme: theme, isDark: isDark),
                  ),

                  const SizedBox(height: 12),

                  // 7. Features accordion
                  _AccordionSection(
                    icon: Icons.star_rounded,
                    title: s.features,
                    theme: theme,
                    isDark: isDark,
                    initiallyExpanded: false,
                    child: _FeaturesGrid(theme: theme, isDark: isDark),
                  ),

                  const SizedBox(height: 24),

                  // 8. Footer
                  _Footer(theme: theme),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
    );
  }

  static Future<void> _navigateToLocalSend(BuildContext context) async {
    HapticFeedback.lightImpact();
    final results = await Connectivity().checkConnectivity();
    final isConnectedToWlan = results.contains(ConnectivityResult.wifi);

    if (!isConnectedToWlan && context.mounted) {
      _showWlanRequiredDialog(context);
      return;
    }

    if (context.mounted) {
      Navigator.of(context).push(
        SmoothPageRoute(
          page: LocalSendPage(
            onFilesSelected: (files) {
              Navigator.of(context).pushReplacement(
                SmoothPageRoute(
                  page: LocalHostingPage(files: files),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  static Future<void> _navigateToQrScanner(BuildContext context) async {
    HapticFeedback.lightImpact();
    final results = await Connectivity().checkConnectivity();
    final isConnectedToWlan = results.contains(ConnectivityResult.wifi);

    if (!isConnectedToWlan && context.mounted) {
      _showWlanRequiredDialog(context);
      return;
    }

    if (context.mounted) {
      Navigator.of(context).push(
        SmoothPageRoute(
          page: const QrScannerPage(),
        ),
      );
    }
  }

  static Future<void> _navigateToAppSelection(BuildContext context) async {
    // Yüklü uygulamaları (APK) paylaşma yalnızca Android'de desteklenir.
    if (!Platform.isAndroid) return;
    HapticFeedback.lightImpact();
    final results = await Connectivity().checkConnectivity();
    final isConnectedToWlan = results.contains(ConnectivityResult.wifi);

    if (!isConnectedToWlan && context.mounted) {
      _showWlanRequiredDialog(context);
      return;
    }

    if (context.mounted) {
      Navigator.of(context).push(
        SmoothPageRoute(
          page: const AppSelectionPage(),
        ),
      );
    }
  }

  static void _navigateToClipboard(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      SmoothPageRoute(
        page: const ClipboardPage(),
      ),
    );
  }

  static void _navigateToHistory(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      SmoothPageRoute(
        page: TransferHistoryPage(
          transferRepository: context.read<TransferRepository>(),
        ),
      ),
    );
  }

  static void _showWlanRequiredDialog(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: Colors.red, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(s.wifiRequired)),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            s.networkOfflineMessage,
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.ok),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// MODERN PROFILE & NETWORK HEADER
// =====================================================

class _ProfileAndNetworkHeader extends StatelessWidget {
  final SettingsState state;
  final bool isWifiConnected;
  final String? wifiIp;
  final VoidCallback onOpenSettings;
  final VoidCallback onWifiTap;

  const _ProfileAndNetworkHeader({
    required this.state,
    required this.isWifiConnected,
    required this.wifiIp,
    required this.onOpenSettings,
    required this.onWifiTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocalizations.of(context)!;

    final displayName =
        state.username.isNotEmpty ? state.username : s.user;
    final deviceName = state.deviceName.isNotEmpty
        ? state.deviceName
        : Platform.localHostname;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Avatar with Tap
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onOpenSettings();
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: (state.profilePicturePath != null &&
                            File(state.profilePicturePath!).existsSync())
                        ? Image.file(
                            File(state.profilePicturePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person_rounded,
                                    color: Colors.white, size: 28),
                          )
                        : const Icon(Icons.person_rounded,
                            color: Colors.white, size: 28),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isWifiConnected
                          ? const Color(0xFF22C55E)
                          : Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // User details
          Expanded(
            child: GestureDetector(
              onTap: onOpenSettings,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.edit_rounded,
                          size: 13,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📱 $deviceName',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Wi-Fi Pill Badge
          GestureDetector(
            onTap: onWifiTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isWifiConnected
                    ? const Color(0xFF22C55E).withValues(alpha: 0.12)
                    : Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isWifiConnected
                      ? const Color(0xFF22C55E).withValues(alpha: 0.3)
                      : Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isWifiConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    size: 15,
                    color: isWifiConnected
                        ? const Color(0xFF22C55E)
                        : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isWifiConnected
                        ? (wifiIp ?? s.connectedWifi)
                        : s.notConnected,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isWifiConnected
                          ? const Color(0xFF16A34A)
                          : Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// MODERN ACTION CARD (2x2 Grid)
// =====================================================

class _ModernActionCard extends StatefulWidget {
  final IconData icon;
  final List<Color> colors;
  final String title;
  final String subtitle;
  final String tag;
  final VoidCallback onTap;

  const _ModernActionCard({
    required this.icon,
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.onTap,
  });

  @override
  State<_ModernActionCard> createState() => _ModernActionCardState();
}

class _ModernActionCardState extends State<_ModernActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.colors.first.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Icon Container + Arrow/Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: widget.colors.first.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, size: 24, color: Colors.white),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.colors.first.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.tag,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: widget.colors.first,
                      ),
                    ),
                  ),
                ],
              ),

              // Title and Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// QUICK UTILITIES & FOLDER BAR
// =====================================================

class _QuickUtilitiesBar extends StatelessWidget {
  final VoidCallback onOpenHistory;
  final VoidCallback onRateApp;
  final VoidCallback onOpenFolderInfo;

  const _QuickUtilitiesBar({
    required this.onOpenHistory,
    required this.onRateApp,
    required this.onOpenFolderInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // History Button
          _UtilityChip(
            icon: Icons.history_rounded,
            label: s.transferHistory,
            iconColor: const Color(0xFF6366F1),
            onTap: onOpenHistory,
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // Rate 5 Stars Button
          _UtilityChip(
            icon: Icons.star_rounded,
            label: s.rateAppTitle,
            iconColor: Colors.amber.shade600,
            onTap: onRateApp,
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // Folder Path Button
          _UtilityChip(
            icon: Icons.folder_special_rounded,
            label: 'file_transfer',
            iconColor: const Color(0xFF059669),
            onTap: onOpenFolderInfo,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _UtilityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isDark;

  const _UtilityChip({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// RECENT TRANSFERS SECTION (Live Stream)
// =====================================================

class _RecentTransfersSection extends StatelessWidget {
  final VoidCallback onSeeAll;

  const _RecentTransfersSection({required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocalizations.of(context)!;
    final transferRepo = context.read<TransferRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionHeader(
              icon: Icons.history_rounded,
              title: s.recentTransfers,
              theme: theme,
            ),
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                s.seeAll,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Transfer>>(
          stream: transferRepo.watchAllTransfers(),
          builder: (context, snapshot) {
            final transfers = snapshot.data ?? [];
            if (transfers.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.swap_horiz_rounded,
                          color: theme.colorScheme.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        s.noRecentTransfers,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final recentList = transfers.take(3).toList();
            return Column(
              children: recentList.map((transfer) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.grey.withValues(alpha: 0.12),
                    ),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (transfer.direction ==
                                enums.TransferDirection.sent
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF10B981))
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        transfer.direction == enums.TransferDirection.sent
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: transfer.direction ==
                                enums.TransferDirection.sent
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      transfer.files.isNotEmpty
                          ? transfer.files.first.name
                          : s.transferred,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${Helpers.formatBytes(transfer.totalSize)} • ${transfer.timestamp.day}.${transfer.timestamp.month}.${transfer.timestamp.year}',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(
                        SmoothPageRoute(
                          page: TransferDetailPage(transfer: transfer),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// =====================================================
// SECTION HEADER
// =====================================================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final ThemeData theme;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// ANIMATED LOGO & BACKGROUND
// =====================================================

class _AnimatedLogo extends StatelessWidget {
  final Animation<double> animation;

  const _AnimatedLogo({required this.animation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  const _AnimatedBackground({
    required this.controller,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0F0F23),
                      const Color(0xFF1A1A2E),
                      Color.lerp(
                          const Color(0xFF1A1A2E),
                          primaryColor.withValues(alpha: 0.2),
                          math.sin(controller.value * math.pi).abs())!,
                    ]
                  : [
                      Colors.white,
                      Color.lerp(
                          Colors.white,
                          primaryColor.withValues(alpha: 0.05),
                          math.sin(controller.value * math.pi).abs())!,
                      Color.lerp(
                          Colors.white,
                          secondaryColor.withValues(alpha: 0.05),
                          math.cos(controller.value * math.pi).abs())!,
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: _BackgroundPatternPainter(
              animation: controller.value,
              color: primaryColor.withValues(alpha: isDark ? 0.05 : 0.03),
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  final double animation;
  final Color color;

  _BackgroundPatternPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final offset = Offset(
        size.width * (0.1 + i * 0.15) +
            math.sin(animation * math.pi * 2 + i) * 20,
        size.height * (0.1 + i * 0.12) +
            math.cos(animation * math.pi * 2 + i) * 20,
      );
      canvas.drawCircle(offset, 40 + i * 10.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =====================================================
// HOW IT WORKS & FEATURES ACCORDIONS
// =====================================================

class _HowItWorksCard extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;

  const _HowItWorksCard({required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    final steps = lang == 'tr'
        ? [
            {
              'num': '1',
              'icon': Icons.wifi_tethering_rounded,
              'title': 'Aynı Ağa Bağlanın',
              'desc': 'Cihazları aynı Wi-Fi ağına bağlayın veya internet olmadan Kişisel Erişim Noktası (Hotspot) açın.',
              'color': const Color(0xFF6366F1),
            },
            {
              'num': '2',
              'icon': Icons.drive_folder_upload_rounded,
              'title': 'Dosya veya Uygulama Seçin',
              'desc': 'Fotoğraf, video, belge veya yüklü uygulamaları (.apk) seçin; bağlantı ve metin de paylaşabilirsiniz.',
              'color': const Color(0xFF10B981),
            },
            {
              'num': '3',
              'icon': Icons.qr_code_scanner_rounded,
              'title': 'QR Kod veya Web ile Bağlanın',
              'desc': 'Oluşturulan QR kodu diğer cihazın kamerasıyla taratın ya da verilen web adresini tarayıcıya girin.',
              'color': const Color(0xFFF59E0B),
            },
            {
              'num': '4',
              'icon': Icons.download_done_rounded,
              'title': 'Işık Hızında & Sınırsız İndirin',
              'desc': 'Alıcı cihazda uygulama yüklü olmasa bile dosyaları orijinal kalitede ve sınırsız hızda indirin.',
              'color': const Color(0xFF06B6D4),
            },
          ]
        : (lang == 'de'
            ? [
                {
                  'num': '1',
                  'icon': Icons.wifi_tethering_rounded,
                  'title': 'Mit demselben Netzwerk verbinden',
                  'desc': 'Geräte mit demselben WLAN verbinden oder einen Hotspot ohne Internetverbindung öffnen.',
                  'color': const Color(0xFF6366F1),
                },
                {
                  'num': '2',
                  'icon': Icons.drive_folder_upload_rounded,
                  'title': 'Dateien oder Apps auswählen',
                  'desc': 'Fotos, Videos, Dokumente, installierte Apps (.apk) oder Texte und Links auswählen.',
                  'color': const Color(0xFF10B981),
                },
                {
                  'num': '3',
                  'icon': Icons.qr_code_scanner_rounded,
                  'title': 'QR-Code scannen oder Webadresse öffnen',
                  'desc': 'Den QR-Code mit der Kamera des anderen Geräts scannen oder die IP-Adresse im Browser eingeben.',
                  'color': const Color(0xFFF59E0B),
                },
                {
                  'num': '4',
                  'icon': Icons.download_done_rounded,
                  'title': 'Sofortig & unbegrenzt empfangen',
                  'desc': 'Empfangen Sie Dateien in Originalqualität ohne Größenbeschränkung auch ohne installierte App.',
                  'color': const Color(0xFF06B6D4),
                },
              ]
            : [
                {
                  'num': '1',
                  'icon': Icons.wifi_tethering_rounded,
                  'title': 'Connect to Same Network',
                  'desc': 'Connect devices to the same Wi-Fi network or create a mobile hotspot without internet.',
                  'color': const Color(0xFF6366F1),
                },
                {
                  'num': '2',
                  'icon': Icons.drive_folder_upload_rounded,
                  'title': 'Select Files or Apps',
                  'desc': 'Choose photos, videos, documents, installed apps (.apk), or share links and clipboard text.',
                  'color': const Color(0xFF10B981),
                },
                {
                  'num': '3',
                  'icon': Icons.qr_code_scanner_rounded,
                  'title': 'Scan QR Code or Open Web',
                  'desc': 'Scan the QR code with the receiver camera or enter the local IP address in any browser.',
                  'color': const Color(0xFFF59E0B),
                },
                {
                  'num': '4',
                  'icon': Icons.download_done_rounded,
                  'title': 'Instant & Unlimited Transfer',
                  'desc': 'Transfer files directly with zero compression and ultra-fast speed, no app required on receiver.',
                  'color': const Color(0xFF06B6D4),
                },
              ]);

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;

        return _StepItem(
          number: step['num'] as String,
          icon: step['icon'] as IconData,
          title: step['title'] as String,
          description: step['desc'] as String,
          color: step['color'] as Color,
          isLast: isLast,
        );
      }).toList(),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isLast;

  const _StepItem({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.15)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AccordionSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final ThemeData theme;
  final bool isDark;
  final Widget child;
  final bool initiallyExpanded;

  const _AccordionSection({
    required this.icon,
    required this.title,
    required this.theme,
    required this.isDark,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 18),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;

  const _FeaturesGrid({required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    final features = lang == 'tr'
        ? [
            {'icon': '🚀', 'title': 'Ultra Hızlı Aktarım', 'desc': '50+ MB/s doğrudan yerel Wi-Fi'},
            {'icon': '🔒', 'title': '%100 Güvenli & Yerel', 'desc': 'Veriler cihazlar arasında kalır'},
            {'icon': '🌐', 'title': 'Web Tarayıcı Desteği', 'desc': 'Alıcıda uygulama gerekmez'},
            {'icon': '📱', 'title': 'APK Paylaşımı', 'desc': 'Uygulama adıyla .apk aktarımı'},
            {'icon': '📋', 'title': 'Canlı Pano Eşitleme', 'desc': 'Metin ve link senkronizasyonu'},
            {'icon': '♾️', 'title': 'Sınırsız & Kayıpsız', 'desc': 'Orijinal kalite, sıfır limit'},
          ]
        : (lang == 'de'
            ? [
                {'icon': '🚀', 'title': 'Ultra Schnell', 'desc': 'Bis zu 50+ MB/s im lokalen WLAN'},
                {'icon': '🔒', 'title': '100% Sicher & Lokal', 'desc': 'Direkt von Gerät zu Gerät'},
                {'icon': '🌐', 'title': 'Browser-Unterstützung', 'desc': 'Keine App auf Empfänger nötig'},
                {'icon': '📱', 'title': 'App-Freigabe (APK)', 'desc': 'Echte App-Namen bei .apk'},
                {'icon': '📋', 'title': 'Zwischenablage Sync', 'desc': 'Echtzeit-Text- und Linkaustausch'},
                {'icon': '♾️', 'title': 'Unbegrenzte Qualität', 'desc': 'Ohne Komprimierung und Limit'},
              ]
            : [
                {'icon': '🚀', 'title': 'Ultra-Fast Speed', 'desc': 'Up to 50+ MB/s direct Wi-Fi'},
                {'icon': '🔒', 'title': '100% Secure & Local', 'desc': 'Never touches cloud servers'},
                {'icon': '🌐', 'title': 'Web Browser Support', 'desc': 'No receiver app required'},
                {'icon': '📱', 'title': 'APK & App Sharing', 'desc': 'Named APK extraction & share'},
                {'icon': '📋', 'title': 'Clipboard Sync', 'desc': 'Real-time text & link sync'},
                {'icon': '♾️', 'title': 'Unlimited & Lossless', 'desc': 'Full quality, zero file limits'},
              ]);

    final pastelBgList = isDark
        ? const [
            Color(0xFF1B242C),
            Color(0xFF192B21),
            Color(0xFF281E2E),
            Color(0xFF2D221A),
            Color(0xFF2D1B22),
            Color(0xFF1A2A2B),
          ]
        : const [
            Color(0xFFF0F7FF),
            Color(0xFFF0FDF4),
            Color(0xFFFAF5FF),
            Color(0xFFFFF7ED),
            Color(0xFFFFF1F2),
            Color(0xFFF0FDFA),
          ];

    final pastelBorderList = isDark
        ? const [
            Color(0xFF2E3E4E),
            Color(0xFF2A4A38),
            Color(0xFF483354),
            Color(0xFF4C3828),
            Color(0xFF4E2B38),
            Color(0xFF2B4648),
          ]
        : const [
            Color(0xFFBAE6FD),
            Color(0xFFBBF7D0),
            Color(0xFFE9D5FF),
            Color(0xFFFED7AA),
            Color(0xFFFECDD3),
            Color(0xFF99F6E4),
          ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.45,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final f = features[index];
        final bg = pastelBgList[index % pastelBgList.length];
        final border = pastelBorderList[index % pastelBorderList.length];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(f['icon']!, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(
                f['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                f['desc']!,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  fontSize: 10.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  final ThemeData theme;

  const _Footer({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              theme.colorScheme.primary.withValues(alpha: 0.08),
              theme.colorScheme.secondary.withValues(alpha: 0.08)
            ]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_rounded, color: Colors.red.shade400, size: 16),
              const SizedBox(width: 8),
              Text(
                'Made with love by 41Software',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '© ${DateTime.now().year} ${AppConstants.appName}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
