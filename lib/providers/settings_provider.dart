import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/reminders.dart';
import '../constants/app_strings.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  Map<String, int> _reminderMinutes = Map<String, int>.from(defaultReminderMinutes);
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _notificationSound = 'adhan_makkah'; // 'adhan_makkah', 'adhan_madinah', 'ney', 'beep'
  String _appLanguage = 'tr'; // 'tr' or 'en'

  Map<String, int> get reminderMinutes => _reminderMinutes;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  String get notificationSound => _notificationSound;
  String get appLanguage => _appLanguage;

  String tr(String key) => AppStrings.get(key, _appLanguage);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final remindersJson = _prefs.getString('reminder_minutes');
    if (remindersJson != null) {
      final decoded = jsonDecode(remindersJson) as Map<String, dynamic>;
      _reminderMinutes = decoded.cast<String, int>();
    } else {
      _reminderMinutes = Map<String, int>.from(defaultReminderMinutes);
    }

    _soundEnabled = _prefs.getBool('sound_enabled') ?? true;
    _vibrationEnabled = _prefs.getBool('vibration_enabled') ?? true;
    _notificationSound = _prefs.getString('notification_sound') ?? 'adhan_makkah';
    _appLanguage = _prefs.getString('app_language') ?? 'tr';

    notifyListeners();
  }

  Future<void> setReminderMinutes(String prayer, int minutes) async {
    _reminderMinutes = Map<String, int>.from(_reminderMinutes);
    _reminderMinutes[prayer] = minutes;
    await _prefs.setString(
      'reminder_minutes',
      jsonEncode(_reminderMinutes),
    );
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _prefs.setBool('sound_enabled', enabled);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    await _prefs.setBool('vibration_enabled', enabled);
    notifyListeners();
  }

  Future<void> setNotificationSound(String soundKey) async {
    _notificationSound = soundKey;
    await _prefs.setString('notification_sound', soundKey);
    notifyListeners();
  }

  Future<void> setAppLanguage(String langCode) async {
    _appLanguage = langCode;
    await _prefs.setString('app_language', langCode);
    notifyListeners();
  }

  int getReminderMinutes(String prayer) {
    return _reminderMinutes[prayer] ?? defaultReminderMinutes[prayer] ?? 5;
  }
}
