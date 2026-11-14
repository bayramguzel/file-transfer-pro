import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

/// Reklam yapılandırması.
///
/// Android kimlikleri yayın (production) kimlikleridir. iOS reklamları ise
/// App Store'da yayınlanacak iOS uygulaması için ayrı AdMob uygulama kimliği,
/// reklam birimi kimlikleri ve Unity Ads iOS yerleşim kimlikleri girilene
/// kadar kapalıdır. Böylece iOS'ta test reklamı veya yarım kalmış reklam
/// alanı gösterilmez (App Store inceleme politikaları).
class AdHelper {
  /// iOS reklam kimlikleri tanımlandığında true yapılmalıdır.
  static const bool iosAdsConfigured = false;

  /// Bu platformda reklam gösterilebilir mi?
  static bool get isAdsEnabled =>
      !kIsWeb && (Platform.isAndroid || (Platform.isIOS && iosAdsConfigured));

  /// Unity Ads yalnızca Android'de kullanılır.
  static bool get isUnityAdsEnabled => !kIsWeb && Platform.isAndroid;

  // Unity Ads / LevelPlay Configuration
  static const String unityGameId = '800357410';
  static const String unityOrganizationCoreId = '9072401080631';

  // Unity Ads Placement IDs (platform bazlı)
  static String get unityBannerPlacementId =>
      Platform.isIOS ? 'Banner_iOS' : 'Banner_Android';
  static String get unityInterstitialPlacementId =>
      Platform.isIOS ? 'Interstitial_iOS' : 'Interstitial_Android';
  static String get unityRewardedPlacementId =>
      Platform.isIOS ? 'Rewarded_iOS' : 'Rewarded_Android';

  // Google AdMob Unit IDs
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2100987662328122/3932144798';
    } else if (Platform.isIOS) {
      // iOS uygulaması AdMob'a eklendiğinde gerçek birim kimliği ile değiştirin.
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Initialize Unity Ads SDK (Android)
  static Future<void> initUnityAds() async {
    if (!isUnityAdsEnabled) {
      return;
    }

    try {
      await UnityAds.init(
        gameId: unityGameId,
        testMode: false,
        onComplete: () {
          _isUnityAdsInitialized = true;
          debugPrint('Unity Ads initialization complete.');
        },
        onFailed: (error, message) {
          _isUnityAdsInitialized = false;
          debugPrint('Unity Ads initialization failed: $error - $message');
        },
      );
    } catch (e) {
      debugPrint('Error initializing Unity Ads: $e');
    }
  }

  static bool _isUnityAdsInitialized = false;
  static bool get isUnityAdsInitialized => _isUnityAdsInitialized;

  /// Show Rewarded Video Ad
  ///
  /// Unity Ads kullanılamayan platformlarda (iOS/web/masaüstü) ödül doğrudan
  /// verilir; böylece kullanıcı destek süresi gibi bir kazanımı kaybetmez.
  static Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onFailed,
    VoidCallback? onStart,
    VoidCallback? onClick,
    VoidCallback? onSkipped,
  }) async {
    if (!isUnityAdsEnabled) {
      onRewarded();
      return;
    }

    try {
      await UnityAds.load(
        placementId: unityRewardedPlacementId,
        onComplete: (placementId) {
          UnityAds.showVideoAd(
            placementId: unityRewardedPlacementId,
            onStart: (placementId) => onStart?.call(),
            onClick: (placementId) => onClick?.call(),
            onSkipped: (placementId) => onSkipped?.call(),
            onComplete: (placementId) {
              onRewarded();
            },
            onFailed: (placementId, error, message) {
              debugPrint('Rewarded ad failed: $error - $message');
              onFailed?.call();
            },
          );
        },
        onFailed: (placementId, error, message) {
          debugPrint('Failed to load rewarded ad: $error - $message');
          // Try direct show in case it was pre-cached
          UnityAds.showVideoAd(
            placementId: unityRewardedPlacementId,
            onStart: (placementId) => onStart?.call(),
            onClick: (placementId) => onClick?.call(),
            onSkipped: (placementId) => onSkipped?.call(),
            onComplete: (placementId) {
              onRewarded();
            },
            onFailed: (placementId, error, message) {
              debugPrint('Rewarded ad fallback show failed: $error - $message');
              onFailed?.call();
            },
          );
        },
      );
    } catch (e) {
      debugPrint('Exception while showing rewarded ad: $e');
      onFailed?.call();
    }
  }
}
