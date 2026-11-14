import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupportService extends ChangeNotifier {
  static final SupportService _instance = SupportService._internal();
  factory SupportService() => _instance;
  SupportService._internal();

  static const String _keySupportExpiresAt = 'support_expires_at';
  static const int maxSupportHours = 48;

  DateTime? _expiresAt;
  Timer? _tickerTimer;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  DateTime? get expiresAt => _expiresAt;

  bool get isSupportActive {
    if (_expiresAt == null) return false;
    return DateTime.now().isBefore(_expiresAt!);
  }

  Duration get remainingDuration {
    if (!isSupportActive || _expiresAt == null) return Duration.zero;
    final diff = _expiresAt!.difference(DateTime.now());
    if (diff.isNegative) return Duration.zero;
    if (diff.inHours > maxSupportHours) {
      return const Duration(hours: maxSupportHours);
    }
    return diff;
  }

  int get remainingHours => remainingDuration.inHours;
  int get remainingMinutes => remainingDuration.inMinutes % 60;

  bool get canAddMoreTime {
    return remainingDuration < const Duration(hours: maxSupportHours);
  }

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final epoch = prefs.getInt(_keySupportExpiresAt);
    if (epoch != null) {
      _expiresAt = DateTime.fromMillisecondsSinceEpoch(epoch);
    }
    _initialized = true;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      notifyListeners();
    });
  }

  Future<void> addSupportHours(int hours) async {
    final now = DateTime.now();
    final maxExpiry = now.add(const Duration(hours: maxSupportHours));

    DateTime newExpiry;
    if (isSupportActive && _expiresAt != null) {
      newExpiry = _expiresAt!.add(Duration(hours: hours));
    } else {
      newExpiry = now.add(Duration(hours: hours));
    }

    if (newExpiry.isAfter(maxExpiry)) {
      newExpiry = maxExpiry;
    }

    _expiresAt = newExpiry;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySupportExpiresAt, newExpiry.millisecondsSinceEpoch);

    notifyListeners();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}
