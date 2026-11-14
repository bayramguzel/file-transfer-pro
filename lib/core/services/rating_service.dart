import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

class RatingService {
  static const String _keyHasRated = 'rating_has_rated';
  static const String _keyNeverAskAgain = 'rating_never_ask_again';
  static const String _keyRemindLaterTimestamp = 'rating_remind_later_ts';
  static const String _keyTransferCount = 'rating_transfer_count';
  static const String _keyLaunchCount = 'rating_launch_count';
  static const String _keyStarsGiven = 'rating_stars_given';

  // Minimum usage thresholds before asking
  static const int minTransfersToAsk = 2;
  static const int minLaunchesToAsk = 3;
  static const Duration remindLaterDelay = Duration(days: 3);

  final SharedPreferences _prefs;

  RatingService(this._prefs);

  /// Has the user already rated the app
  bool get hasRated => _prefs.getBool(_keyHasRated) ?? false;

  /// Has user explicitly requested to never be prompted again
  bool get neverAskAgain => _prefs.getBool(_keyNeverAskAgain) ?? false;

  /// Total successful transfers completed by user
  int get transferCount => _prefs.getInt(_keyTransferCount) ?? 0;

  /// Total launches
  int get launchCount => _prefs.getInt(_keyLaunchCount) ?? 0;

  /// Stars given if rated through dialog
  int get starsGiven => _prefs.getInt(_keyStarsGiven) ?? 0;

  /// Increments launch count on app start
  Future<void> recordLaunch() async {
    final count = launchCount + 1;
    await _prefs.setInt(_keyLaunchCount, count);
  }

  /// Increments successful transfer count
  Future<void> recordTransfer() async {
    final count = transferCount + 1;
    await _prefs.setInt(_keyTransferCount, count);
  }

  /// Checks whether it's appropriate to prompt the user for rating
  bool shouldPromptForRating() {
    if (hasRated || neverAskAgain) {
      return false;
    }

    final remindTimestamp = _prefs.getInt(_keyRemindLaterTimestamp);
    if (remindTimestamp != null && remindTimestamp > 0) {
      final remindDate =
          DateTime.fromMillisecondsSinceEpoch(remindTimestamp);
      final difference = DateTime.now().difference(remindDate);
      if (difference < remindLaterDelay) {
        // Not enough days passed since user said "Remind me later"
        return false;
      }
    }

    // Require either a few launches or at least 2 successful transfers
    return transferCount >= minTransfersToAsk || launchCount >= minLaunchesToAsk;
  }

  /// User rated the app (5 stars / store visit) -> never prompt again!
  Future<void> markAsRated({int stars = 5}) async {
    await _prefs.setBool(_keyHasRated, true);
    await _prefs.setInt(_keyStarsGiven, stars);
    await _prefs.remove(_keyRemindLaterTimestamp);
  }

  /// User chose "Remind me later" -> wait a few days
  Future<void> remindLater() async {
    await _prefs.setInt(
      _keyRemindLaterTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// User chose "Never ask again"
  Future<void> setNeverAskAgain() async {
    await _prefs.setBool(_keyNeverAskAgain, true);
  }

  /// Opens the platform store listing (App Store on iOS, Google Play elsewhere).
  Future<bool> openStoreListing() async {
    if (!kIsWeb && Platform.isIOS) {
      final uri = Uri.parse(
        AppConstants.appStoreId.isEmpty
            ? AppConstants.websiteUrl
            : AppConstants.appStoreUrl,
      );
      try {
        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Error launching App Store listing: $e');
      }
      return false;
    }

    final marketUri = Uri.parse(AppConstants.googlePlayMarketUrl);
    final webUri = Uri.parse(AppConstants.googlePlayUrl);

    try {
      if (await canLaunchUrl(marketUri)) {
        return await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching store rating: $e');
    }
    return false;
  }
}
