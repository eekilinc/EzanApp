import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/reminders.dart';
import '../constants/app_strings.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  Map<String, int> _reminderMinutes = Map<String, int>.from(defaultReminderMinutes);
  bool _soundEnabled = true;
  bool _adhanSoundEnabled = true;
  bool _reminderSoundEnabled = true;
  bool _vibrationEnabled = true;
  String _adhanSound = 'adhan_makkah';
  String _reminderSound = 'beep';
  String _appLanguage = 'tr';
  ThemeMode _themeMode = ThemeMode.system;
  String _asrSchool = 'standard';
  String _colorTheme = 'green'; // 'green', 'blue', 'teal', 'crimson', 'amber'

  Map<String, int> get reminderMinutes => _reminderMinutes;
  bool get soundEnabled => _soundEnabled;
  bool get adhanSoundEnabled => _adhanSoundEnabled;
  bool get reminderSoundEnabled => _reminderSoundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  String get notificationSound => _adhanSound;
  String get adhanSound => _adhanSound;
  String get reminderSound => _reminderSound;
  String get appLanguage => _appLanguage;
  ThemeMode get themeMode => _themeMode;
  String get asrSchool => _asrSchool;
  String get colorTheme => _colorTheme;

  String tr(String key) => AppStrings.get(key, _appLanguage);

  MaterialColor get primaryMaterialColor {
    switch (_colorTheme) {
      case 'blue':
        return Colors.indigo;
      case 'teal':
        return Colors.teal;
      case 'crimson':
        return Colors.red;
      case 'amber':
        return Colors.amber;
      case 'green':
      default:
        return Colors.green;
    }
  }

  Color get primaryColor {
    switch (_colorTheme) {
      case 'blue':
        return Colors.indigo.shade800;
      case 'teal':
        return Colors.teal.shade800;
      case 'crimson':
        return Colors.red.shade900;
      case 'amber':
        return const Color(0xFFB78103);
      case 'green':
      default:
        return Colors.green.shade800;
    }
  }

  Color get secondaryColor {
    switch (_colorTheme) {
      case 'blue':
        return Colors.indigo.shade600;
      case 'teal':
        return Colors.teal.shade600;
      case 'crimson':
        return Colors.red.shade700;
      case 'amber':
        return Colors.amber.shade700;
      case 'green':
      default:
        return Colors.green.shade700;
    }
  }

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
    _adhanSoundEnabled = _prefs.getBool('adhan_sound_enabled') ?? _soundEnabled;
    _reminderSoundEnabled = _prefs.getBool('reminder_sound_enabled') ?? _soundEnabled;
    _vibrationEnabled = _prefs.getBool('vibration_enabled') ?? true;
    
    // Load separate sounds with fallbacks
    _adhanSound = _prefs.getString('adhan_sound') ?? _prefs.getString('notification_sound') ?? 'adhan_makkah';
    _reminderSound = _prefs.getString('reminder_sound') ?? 'beep';
    
    _appLanguage = _prefs.getString('app_language') ?? 'tr';
    _asrSchool = _prefs.getString('asr_school') ?? 'standard';
    _colorTheme = _prefs.getString('color_theme') ?? 'green';

    final themeStr = _prefs.getString('theme_mode') ?? 'system';
    if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

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
    _adhanSoundEnabled = enabled;
    _reminderSoundEnabled = enabled;
    await _prefs.setBool('sound_enabled', enabled);
    await _prefs.setBool('adhan_sound_enabled', enabled);
    await _prefs.setBool('reminder_sound_enabled', enabled);
    notifyListeners();
  }

  Future<void> setAdhanSoundEnabled(bool enabled) async {
    _adhanSoundEnabled = enabled;
    await _prefs.setBool('adhan_sound_enabled', enabled);
    notifyListeners();
  }

  Future<void> setReminderSoundEnabled(bool enabled) async {
    _reminderSoundEnabled = enabled;
    await _prefs.setBool('reminder_sound_enabled', enabled);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    await _prefs.setBool('vibration_enabled', enabled);
    notifyListeners();
  }

  Future<void> setNotificationSound(String soundKey) async {
    _adhanSound = soundKey;
    await _prefs.setString('notification_sound', soundKey);
    await _prefs.setString('adhan_sound', soundKey);
    notifyListeners();
  }

  Future<void> setAdhanSound(String soundKey) async {
    _adhanSound = soundKey;
    await _prefs.setString('adhan_sound', soundKey);
    await _prefs.setString('notification_sound', soundKey);
    notifyListeners();
  }

  Future<void> setReminderSound(String soundKey) async {
    _reminderSound = soundKey;
    await _prefs.setString('reminder_sound', soundKey);
    notifyListeners();
  }

  Future<void> setAppLanguage(String langCode) async {
    _appLanguage = langCode;
    await _prefs.setString('app_language', langCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    await _prefs.setString('theme_mode', modeStr);
    notifyListeners();
  }

  Future<void> setAsrSchool(String school) async {
    _asrSchool = school;
    await _prefs.setString('asr_school', school);
    notifyListeners();
  }

  Future<void> setColorTheme(String theme) async {
    _colorTheme = theme;
    await _prefs.setString('color_theme', theme);
    notifyListeners();
  }

  int getReminderMinutes(String prayer) {
    return _reminderMinutes[prayer] ?? defaultReminderMinutes[prayer] ?? 5;
  }
}
