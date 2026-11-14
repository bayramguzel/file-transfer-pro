import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/services/support_service.dart';
import 'core/services/rating_service.dart';
import 'core/utils/ad_helper.dart';
import 'data/datasources/database.dart';
import 'data/services/notification_service.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/transfer_repository.dart';
import 'l10n/app_localizations.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/blocs/settings/settings_event.dart';
import 'presentation/blocs/settings/settings_state.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/local_hosting_page.dart';

/// iOS'ta "Ac" ile gelen dosyada paylasim ekranina gitmek icin kullanilir.
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
final List<String> _pendingIncomingFiles = [];

void _openIncomingFile(String path) {
  final navigator = _navigatorKey.currentState;
  if (navigator == null) {
    _pendingIncomingFiles.add(path);
    return;
  }
  navigator.push(
    MaterialPageRoute<void>(
      builder: (_) => LocalHostingPage(files: [File(path)]),
    ),
  );
}

void _flushPendingIncomingFiles() {
  if (_pendingIncomingFiles.isEmpty) return;
  final paths = List<String>.from(_pendingIncomingFiles);
  _pendingIncomingFiles.clear();
  for (final path in paths) {
    _openIncomingFile(path);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // iOS: uygulama sanal alanı nedeniyle indirilen dosyalar Belgeler
  // klasöründe tutulur (Dosyalar uygulamasında "File Transfer Pro").
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      final documents = await getApplicationDocumentsDirectory();
      SettingsRepository.iosDocumentsPath =
          '${documents.path}/${AppConstants.appFolderName}';
    } catch (e) {
      debugPrint('Could not resolve iOS documents directory: $e');
    }
  }

  // Initialize AdMob & Unity Ads without blocking first frame/splash.
  // iOS'ta reklam kimlikleri tanımlanana kadar reklam SDK'ları başlatılmaz.
  if (AdHelper.isAdsEnabled) {
    unawaited(MobileAds.instance.initialize());
    unawaited(AdHelper.initUnityAds());
  }
  unawaited(SupportService().init());
  // iOS'ta bildirim izni istenmez; eklenti yalnızca hazırlanır.
  unawaited(NotificationService().init());

  // Initialize dependencies
  final prefs = await SharedPreferences.getInstance();

  // Check if splash should be shown today (once per day)
  final lastSplash = prefs.getString('last_splash_date');
  final today = DateTime.now().toIso8601String().split('T')[0];

  // iOS: Dosyalar uygulamasindan veya baska bir uygulamadan "Ac" ile gelen
  // dosya, dogrudan paylasim ekraninda karsilanir.
  String? initialIncomingFile;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    const incomingChannel = MethodChannel('file_transfer/incoming_file');
    incomingChannel.setMethodCallHandler((call) async {
      if (call.method == 'openFile' && call.arguments is String) {
        _openIncomingFile(call.arguments as String);
      }
      return null;
    });
    try {
      initialIncomingFile =
          await incomingChannel.invokeMethod<String>('getInitialFile');
    } catch (e) {
      debugPrint('Error checking incoming file: $e');
    }
  }

  // Check if opened via sharing or open-with file intent (always bypass splash)
  bool hasSharingIntent = false;
  if (!kIsWeb) {
    try {
      final sharedFiles = await ReceiveSharingIntent.instance.getInitialMedia();
      hasSharingIntent = sharedFiles.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking initial sharing media: $e');
    }
  }
  if (initialIncomingFile != null && initialIncomingFile.isNotEmpty) {
    hasSharingIntent = true;
  }

  // Never show splash on web, or when launched via share/open intent, or if already shown today
  final bool showSplash = !kIsWeb && (lastSplash != today) && !hasSharingIntent;

  final database = AppDatabase();

  // Create repositories & services
  final settingsRepository = SettingsRepository(prefs);
  final transferRepository = TransferRepository(database);
  final ratingService = RatingService(prefs);
  await ratingService.recordLaunch();

  runApp(FileTransferApp(
    settingsRepository: settingsRepository,
    transferRepository: transferRepository,
    ratingService: ratingService,
    showSplash: showSplash,
  ));

  if (initialIncomingFile != null && initialIncomingFile.isNotEmpty) {
    _openIncomingFile(initialIncomingFile);
  }
  WidgetsBinding.instance
      .addPostFrameCallback((_) => _flushPendingIncomingFiles());
}

class FileTransferApp extends StatelessWidget {
  final SettingsRepository settingsRepository;
  final TransferRepository transferRepository;
  final RatingService ratingService;
  final bool showSplash;

  const FileTransferApp({
    super.key,
    required this.settingsRepository,
    required this.transferRepository,
    required this.ratingService,
    required this.showSplash,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: SupportService()),
        Provider<TransferRepository>.value(value: transferRepository),
        Provider<RatingService>.value(value: ratingService),
        BlocProvider(
          create: (context) =>
              SettingsBloc(settingsRepository)..add(LoadSettings()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          // Seçilen dili belirle
          final selectedLanguage = settingsState.language;
          final Locale appLocale = Locale(selectedLanguage.value);

          return MaterialApp(
            title: 'File Transfer',
            navigatorKey: _navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(
              settingsState.themeMode,
              settingsState.accentColor,
            ),
            // Seçilen dili doğrudan uygula
            locale: appLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr', ''),
              Locale('en', ''),
              Locale('de', ''),
            ],
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              // Öncelik 1: Kullanıcının seçtiği dil
              final userLanguage = settingsState.language;
              final userLocale = Locale(userLanguage.value);

              // Kullanıcı dili destekleniyor mu kontrol et
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == userLocale.languageCode) {
                  return supportedLocale;
                }
              }

              // Öncelik 2: Cihaz dili (eğer destekleniyorsa)
              if (deviceLocale != null) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode ==
                      deviceLocale.languageCode) {
                    return supportedLocale;
                  }
                }
              }

              // Öncelik 3: Varsayılan olarak İngilizce
              return const Locale('en', '');
            },
            home: showSplash ? const SplashPage() : const HomePage(),
          );
        },
      ),
    );
  }
}
