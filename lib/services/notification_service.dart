import 'dart:typed_data';
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
      // Fallback
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
          _getChannelId(sKey),
          'Ezan Hatırlatıcı ($sKey)',
          description: 'Namaz vakitleri hatırlatma bildirimleri',
          importance: Importance.max,
          playSound: true,
          sound: _getSoundResource(sKey),
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );
        await androidImplementation.createNotificationChannel(channel);
      }

      try {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      } catch (_) {}
    }
  }

  Future<bool> isExactAlarmPermissionGranted() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? true;
    }
    return true;
  }

  Future<void> requestExactAlarmsPermission() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      try {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      } catch (_) {}
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
        return 'ezan_channel_adhan_madinah_v6';
      case 'adhan_istanbul':
        return 'ezan_channel_adhan_istanbul_v6';
      case 'adhan_cairo':
        return 'ezan_channel_adhan_cairo_v6';
      case 'adhan_aqsa':
        return 'ezan_channel_adhan_aqsa_v6';
      case 'ney':
        return 'ezan_channel_ney_v6';
      case 'beep':
        return 'ezan_channel_beep_v6';
      case 'adhan_makkah':
      case 'adhan':
      default:
        return 'ezan_channel_adhan_makkah_v6';
    }
  }

  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    try {
      return tz.TZDateTime(
        tz.local,
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
      );
    } catch (_) {
      return tz.TZDateTime.from(dateTime, tz.local);
    }
  }

  Future<bool> showTestNotification({
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    String soundKey = 'adhan_makkah',
  }) async {
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
          await androidImplementation.requestExactAlarmsPermission();
        } catch (_) {}

        final channelId = _getChannelId(soundKey);
        final channel = AndroidNotificationChannel(
          channelId,
          'Ezan Hatırlatıcı ($soundKey)',
          description: 'Namaz vakitleri hatırlatma bildirimleri',
          importance: Importance.max,
          playSound: soundEnabled,
          sound: soundEnabled ? _getSoundResource(soundKey) : null,
          enableVibration: vibrationEnabled,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );
        await androidImplementation.createNotificationChannel(channel);
      }

      await _notificationsPlugin.show(
        999999,
        'Ezan Hatırlatıcı Test Bildirimi 🔔',
        'Bildirim sisteminiz ve ses ayarlarınız başarıyla çalışıyor!',
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
            audioAttributesUsage: AudioAttributesUsage.alarm,
            category: AndroidNotificationCategory.alarm,
            fullScreenIntent: true,
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
    final scheduledTzDateTime = _toTZDateTime(scheduledTime);

    final notificationDetails = NotificationDetails(
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
        audioAttributesUsage: AudioAttributesUsage.alarm,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundEnabled,
      ),
    );

    try {
      // Primary: Android System AlarmClock (bypasses Doze mode & battery saver with 100% exact timing)
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      try {
        // Secondary fallback: exactAllowWhileIdle
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTzDateTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {
        try {
          // Tertiary fallback: inexactAllowWhileIdle
          await _notificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            scheduledTzDateTime,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (_) {}
      }
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
      title: '$displayName Hatırlatması 🕌',
      body: message,
      scheduledTime: notificationTime,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      soundKey: soundKey,
    );
  }
}
