import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../constants/reminders.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tzdata.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'ezan_channel',
            'Ezan Hatırlatıcı Bildirimleri',
            channelDescription: 'Namaz vakitleri hatırlatma bildirimleri',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: vibrationEnabled,
            playSound: soundEnabled,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: soundEnabled,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // In case exact alarm fails, fallback to inexact scheduling
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'ezan_channel',
              'Ezan Hatırlatıcı Bildirimleri',
              channelDescription: 'Namaz vakitleri hatırlatma bildirimleri',
              importance: Importance.max,
              priority: Priority.high,
              enableVibration: vibrationEnabled,
              playSound: soundEnabled,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: soundEnabled,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {}
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  int _generateNotificationId(String prayer, DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}$prayer'.hashCode & 0x7FFFFFFF;
  }

  Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime prayerTime,
    required int minutesBefore,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
  }) async {
    final notificationTime = prayerTime.subtract(Duration(minutes: minutesBefore));

    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    final id = _generateNotificationId(prayerName, prayerTime);
    final displayName = prayerDisplayNames[prayerName] ?? prayerName;
    final message = minutesBefore == 0
        ? '$displayName vakti girdi!'
        : '$displayName vakit girmesine $minutesBefore dakika kaldı.';

    await scheduleNotification(
      id: id,
      title: '$displayName Hatırlatması',
      body: message,
      scheduledTime: notificationTime,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
    );
  }
}
