import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:vibration/vibration.dart';
import '../constants/reminders.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get notificationsPlugin => _notificationsPlugin;

  Future<void> initialize() async {
    tzdata.initializeTimeZones();
    try {
      final String timeZoneName = DateTime.now().timeZoneName;
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      }
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
      // Clear previous channels to apply fresh v200 settings
      try {
        final existingChannels = await androidImplementation.getNotificationChannels() ?? [];
        for (final ch in existingChannels) {
          if (ch.id.startsWith('ezan_channel_') && !ch.id.contains('_v200')) {
            await androidImplementation.deleteNotificationChannel(ch.id);
          }
        }
      } catch (_) {}

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
        return 'ezan_channel_adhan_madinah_v200';
      case 'adhan_istanbul':
        return 'ezan_channel_adhan_istanbul_v200';
      case 'adhan_cairo':
        return 'ezan_channel_adhan_cairo_v200';
      case 'adhan_aqsa':
        return 'ezan_channel_adhan_aqsa_v200';
      case 'ney':
        return 'ezan_channel_ney_v200';
      case 'beep':
        return 'ezan_channel_beep_v200';
      case 'adhan_makkah':
      case 'adhan':
      default:
        return 'ezan_channel_adhan_makkah_v200';
    }
  }

  tz.TZDateTime _toTZDateTime(DateTime scheduledTime) {
    try {
      final now = DateTime.now();
      final difference = scheduledTime.difference(now);
      final tzNow = tz.TZDateTime.now(tz.local);
      if (difference.isNegative) {
        return tzNow.add(const Duration(seconds: 1));
      }
      return tzNow.add(difference);
    } catch (_) {
      return tz.TZDateTime.from(scheduledTime, tz.local);
    }
  }

  Future<bool> showTestNotification({
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    String soundKey = 'adhan_makkah',
  }) async {
    final channelId = _getChannelId(soundKey);
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      try {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      } catch (_) {}

      try {
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
      } catch (_) {}
    }

    // Direct vibration feedback when test button is tapped
    if (vibrationEnabled) {
      try {
        if ((await Vibration.hasVibrator()) == true) {
          Vibration.vibrate(pattern: [0, 800, 400, 800, 400, 800]);
        }
      } catch (_) {
        try {
          await HapticFeedback.vibrate();
        } catch (_) {}
      }
    }

    try {
      await _notificationsPlugin.show(
        999999,
        'Ezan Hatırlatıcı Test Bildirimi 🔔',
        'Anlık bildirim, titreşim ve ses sisteminiz başarıyla çalışıyor!',
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Ezan Hatırlatıcı Bildirimleri',
            channelDescription: 'Namaz vakitleri hatırlatma bildirimleri',
            importance: Importance.max,
            priority: Priority.max,
            visibility: NotificationVisibility.public,
            enableVibration: vibrationEnabled,
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
            playSound: soundEnabled,
            sound: soundEnabled ? _getSoundResource(soundKey) : null,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            category: AndroidNotificationCategory.alarm,
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
      return false;
    }
  }

  Future<bool> scheduleTestNotificationIn10Seconds({
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    String soundKey = 'adhan_makkah',
  }) async {
    // Cancel any previous test notification
    await cancelNotification(888888);

    final testTime = DateTime.now().add(const Duration(seconds: 10));
    await scheduleNotification(
      id: 888888,
      title: 'Zamanlanmış Ezan Testi (10s) 🕌',
      body: '10 saniyelik zamanlanmış ezan bildirimi ve uyarısı başarıyla çaldı!',
      scheduledTime: testTime,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      soundKey: soundKey,
    );
    return true;
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
    // Do not schedule if time has already passed
    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }

    final scheduledTzDateTime = _toTZDateTime(scheduledTime);
    final channelId = _getChannelId(soundKey);

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      try {
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
      } catch (_) {}
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        'Ezan Hatırlatıcı Bildirimleri',
        channelDescription: 'Namaz vakitleri hatırlatma bildirimleri',
        importance: Importance.max,
        priority: Priority.max,
        visibility: NotificationVisibility.public,
        enableVibration: vibrationEnabled,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
        playSound: soundEnabled,
        sound: soundEnabled ? _getSoundResource(soundKey) : null,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: soundEnabled,
      ),
    );

    try {
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
    } catch (e1) {
      try {
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

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  int _generateNotificationId(String prayer, DateTime date, String type) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}${prayer}_$type'.hashCode & 0x7FFFFFFF;
  }

  Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime prayerTime,
    required int minutesBefore,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    String soundKey = 'adhan_makkah',
  }) async {
    final displayName = prayerDisplayNames[prayerName] ?? prayerName;

    // 1. ALWAYS Schedule Exact Prayer Time (0 min offset - Exact Adhan)
    if (!prayerTime.isBefore(DateTime.now())) {
      final exactId = _generateNotificationId(prayerName, prayerTime, 'exact');
      await scheduleNotification(
        id: exactId,
        title: '$displayName Vakti Girdi 🕌',
        body: '$displayName ezanı okunuyor. Haydi namaza! 🕌',
        scheduledTime: prayerTime,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        soundKey: soundKey,
      );
    }

    // 2. ALSO Schedule Custom Offset Reminder (if minutesBefore != 0)
    if (minutesBefore != 0) {
      final DateTime reminderTime;
      if (minutesBefore > 0) {
        reminderTime = prayerTime.subtract(Duration(minutes: minutesBefore));
      } else {
        reminderTime = prayerTime.add(Duration(minutes: minutesBefore.abs()));
      }

      if (!reminderTime.isBefore(DateTime.now())) {
        final reminderId = _generateNotificationId(prayerName, prayerTime, 'reminder');
        final String message = minutesBefore > 0
            ? '$displayName vakit girmesine $minutesBefore dakika kaldı.'
            : '$displayName vakti gireli ${minutesBefore.abs()} dakika oldu.';

        await scheduleNotification(
          id: reminderId,
          title: '$displayName Hatırlatması ⏰',
          body: message,
          scheduledTime: reminderTime,
          soundEnabled: soundEnabled,
          vibrationEnabled: vibrationEnabled,
          soundKey: soundKey,
        );
      }
    }
  }
}
