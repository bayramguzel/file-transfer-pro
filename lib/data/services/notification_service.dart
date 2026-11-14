import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          await OpenFilex.open(response.payload!);
        }
      },
    );
  }

  /// iOS'ta bildirim izni açılışta değil, ilk bildirim gösterilirken istenir.
  /// Bu, App Store'un "izinleri kullanım anında iste" kuralına uygundur.
  Future<void> ensureIOSPermissions() async {
    if (kIsWeb || !Platform.isIOS) return;
    try {
      final ios = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('iOS notification permission request failed: $e');
    }
  }

  Future<void> showDownloadCompleteNotification(
      String fileName, String filePath,
      {String? title, String? body}) async {
    await ensureIOSPermissions();

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Notifications for completed downloads',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecond,
      title: title ?? 'Download Completed',
      body: body ?? '$fileName has been downloaded successfully.',
      notificationDetails: notificationDetails,
      payload: filePath,
    );
  }

  Future<void> showProgressNotification(
      int id, String fileName, int progress) async {
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'download_progress_channel',
      'Download Progress',
      channelDescription: 'Notifications for active downloads',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: 'Downloading...',
      body: '$fileName ($progress%)',
      notificationDetails: notificationDetails,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }
}
