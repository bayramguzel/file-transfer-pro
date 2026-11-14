import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../../core/services/support_service.dart';
import '../../core/utils/ad_helper.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _admobBannerAd;
  bool _isAdmobLoaded = false;
  bool _useUnityAds = true;
  bool _unityFailed = false;

  @override
  void initState() {
    super.initState();
    if (AdHelper.isUnityAdsEnabled) {
      _useUnityAds = true;
    } else {
      _useUnityAds = false;
      _loadAdmobAd();
    }
  }

  void _loadAdmobAd() {
    if (!AdHelper.isAdsEnabled) return;
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    _admobBannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdmobLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdmobLoaded = false;
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _admobBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If support is active, hide banner ads completely
    final isSupportActive =
        context.select<SupportService, bool>((s) => s.isSupportActive);

    if (isSupportActive) {
      return const SizedBox.shrink();
    }

    // Reklamların yapılandırılmadığı platformlarda (iOS) yer kaplamayız.
    if (!AdHelper.isAdsEnabled) {
      return const SizedBox.shrink();
    }

    if (_useUnityAds && !_unityFailed) {
      return Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(minHeight: 50, maxHeight: 60),
        child: UnityBannerAd(
          placementId: AdHelper.unityBannerPlacementId,
          onLoad: (placementId) {
            debugPrint('Unity Banner loaded: $placementId');
          },
          onClick: (placementId) {
            debugPrint('Unity Banner clicked: $placementId');
          },
          onFailed: (placementId, error, message) {
            debugPrint('Unity Banner failed: $error $message. Falling back to AdMob.');
            if (mounted) {
              setState(() {
                _unityFailed = true;
                _loadAdmobAd();
              });
            }
          },
        ),
      );
    }

    if (_isAdmobLoaded && _admobBannerAd != null) {
      return SizedBox(
        width: _admobBannerAd!.size.width.toDouble(),
        height: _admobBannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _admobBannerAd!),
      );
    }

    return const SizedBox.shrink();
  }
}
