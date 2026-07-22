import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/reminders.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  Map<String, int> _reminderMinutes = defaultReminderMinutes;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  Map<String, int> get reminderMinutes => _reminderMinutes;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final remindersJson = _prefs.getString('reminder_minutes');
    if (remindersJson != null) {
      final decoded = jsonDecode(remindersJson) as Map<String, dynamic>;
      _reminderMinutes = decoded.cast<String, int>();
    }

    _soundEnabled = _prefs.getBool('sound_enabled') ?? true;
    _vibrationEnabled = _prefs.getBool('vibration_enabled') ?? true;

    notifyListeners();
  }

  Future<void> setReminderMinutes(String prayer, int minutes) async {
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

  int getReminderMinutes(String prayer) {
    return _reminderMinutes[prayer] ?? defaultReminderMinutes[prayer] ?? 5;
  }
}
