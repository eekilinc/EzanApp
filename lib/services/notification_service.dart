import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../constants/reminders.dart';
import 'audio_service.dart';

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
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    } catch (_) {
      // Fallback if Europe/Istanbul is not available
    }

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
      final sounds = [
        'adhan_makkah',
        'adhan_madinah',
        'adhan_istanbul',
        'adhan_cairo',
        'adhan_aqsa',
        'ney',
        'beep'
      ];
      for (final sKey in sounds) {
        final channel = AndroidNotificationChannel(
          'ezan_channel_${sKey}_v4',
          'Ezan Hatırlatıcı ($sKey)',
          description: 'Namaz vakitleri hatırlatma bildirimleri',
          importance: Importance.max,
          playSound: true,
          sound: _getSoundResource(sKey),
          enableVibration: true,
        );
        await androidImplementation.createNotificationChannel(channel);
      }

      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  RawResourceAndroidNotificationSound _getSoundResource(String soundKey) {
    switch (soundKey) {
      case 'adhan_madinah':
        return const RawResourceAndroidNotificationSound('adhan_madinah');
      case 'adhan_istanbul':
        return const RawResourceAndroidNotificationSound('adhan_istanbul');
      case 'adhan_cairo':
        return const RawResourceAndroidNotificationSound('adhan_cairo');
      case 'adhan_aqsa':
        return const RawResourceAndroidNotificationSound('adhan_aqsa');
      case 'ney':
        return const RawResourceAndroidNotificationSound('ney_tone');
      case 'beep':
        return const RawResourceAndroidNotificationSound('beep_tone');
      case 'adhan_makkah':
      case 'adhan':
      default:
        return const RawResourceAndroidNotificationSound('adhan_makkah');
    }
  }

  String _getChannelId(String soundKey) {
    switch (soundKey) {
      case 'adhan_madinah':
        return 'ezan_channel_adhan_madinah_v4';
      case 'adhan_istanbul':
        return 'ezan_channel_adhan_istanbul_v4';
      case 'adhan_cairo':
        return 'ezan_channel_adhan_cairo_v4';
      case 'adhan_aqsa':
        return 'ezan_channel_adhan_aqsa_v4';
      case 'ney':
        return 'ezan_channel_ney_v4';
      case 'beep':
        return 'ezan_channel_beep_v4';
      case 'adhan_makkah':
      case 'adhan':
      default:
        return 'ezan_channel_adhan_makkah_v4';
    }
  }

  Future<bool> showTestNotification({
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    String soundKey = 'adhan_makkah',
  }) async {
    // 1. Play audio in foreground as instant feedback
    if (soundEnabled) {
      try {
        await AudioService().playNotificationSound(soundKey);
      } catch (_) {}
    }

    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        try {
          await androidImplementation.requestNotificationsPermission();
        } catch (_) {}

        // Ensure notification channel is created
        final channelId = _getChannelId(soundKey);
        final channel = AndroidNotificationChannel(
          channelId,
          'Ezan Hatırlatıcı Bildirimleri ($soundKey)',
          description: 'Namaz vakitleri hatırlatma bildirimleri',
          importance: Importance.max,
          playSound: soundEnabled,
          sound: soundEnabled ? _getSoundResource(soundKey) : null,
          enableVibration: vibrationEnabled,
        );
        await androidImplementation.createNotificationChannel(channel);
      }

      await _notificationsPlugin.show(
        999999,
        'Ezan Hatırlatıcı Test Bildirimi 🔔',
        'Bildirim sisteminiz ve ayarlarınız başarıyla çalışıyor!',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _getChannelId(soundKey),
            'Ezan Hatırlatıcı Bildirimleri',
            channelDescription: 'Namaz vakitleri hatırlatma bildirimleri',
            importance: Importance.max,
            priority: Priority.max,
            visibility: NotificationVisibility.public,
            enableVibration: vibrationEnabled,
            playSound: soundEnabled,
            sound: soundEnabled ? _getSoundResource(soundKey) : null,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: soundEnabled,
          ),
        ),
      );
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    String soundKey = 'adhan_makkah',
  }) async {
    try {
      final scheduledTzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTzDateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _getChannelId(soundKey),
            'Ezan Hatırlatıcı Bildirimleri',
            channelDescription: 'Namaz vakitleri hatırlatma bildirimleri',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: vibrationEnabled,
            playSound: soundEnabled,
            sound: soundEnabled ? _getSoundResource(soundKey) : null,
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
        final scheduledTzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTzDateTime,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _getChannelId(soundKey),
              'Ezan Hatırlatıcı Bildirimleri',
              channelDescription: 'Namaz vakitleri hatırlatma bildirimleri',
              importance: Importance.max,
              priority: Priority.high,
              enableVibration: vibrationEnabled,
              playSound: soundEnabled,
              sound: soundEnabled ? _getSoundResource(soundKey) : null,
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
    String soundKey = 'adhan_makkah',
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
      soundKey: soundKey,
    );
  }
}
