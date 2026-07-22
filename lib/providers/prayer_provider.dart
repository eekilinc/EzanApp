import 'package:flutter/material.dart';
import '../models/prayer_times.dart';
import '../models/location_data.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../constants/reminders.dart';
import 'settings_provider.dart';

class PrayerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();

  PrayerTimes? _prayerTimes;
  LocationData? _location;
  bool _isLoading = false;
  String? _error;

  PrayerTimes? get prayerTimes => _prayerTimes;
  LocationData? get location => _location;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initializeLocation(SettingsProvider settingsProvider) async {
    await _locationService.init();
    await _locationService.requestLocationPermission();

    _location = await _locationService.getLocation();
    if (_location != null) {
      await loadPrayerTimes(settingsProvider);
    }
    notifyListeners();
  }

  Future<void> loadPrayerTimes([SettingsProvider? settingsProvider]) async {
    if (_location == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prayerTimes = await _apiService.getPrayerTimesForToday(
        latitude: _location!.latitude,
        longitude: _location!.longitude,
      );

      // Schedule notifications for today's prayers using settings
      await scheduleNotifications(
        customReminderMinutes: settingsProvider?.reminderMinutes,
        soundEnabled: settingsProvider?.soundEnabled ?? true,
        vibrationEnabled: settingsProvider?.vibrationEnabled ?? true,
        soundKey: settingsProvider?.notificationSound ?? 'adhan_makkah',
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> scheduleNotifications({
    Map<String, int>? customReminderMinutes,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
    String soundKey = 'adhan_makkah',
  }) async {
    if (_prayerTimes == null) return;

    await _notificationService.cancelAllNotifications();

    final prayers = _prayerTimes!.getPrayerList();
    final reminders = customReminderMinutes ?? defaultReminderMinutes;

    for (final prayer in prayers) {
      final reminderMinutes = reminders[prayer.name] ?? defaultReminderMinutes[prayer.name] ?? 5;
      await _notificationService.schedulePrayerNotification(
        prayerName: prayer.name,
        prayerTime: prayer.time,
        minutesBefore: reminderMinutes,
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        soundKey: soundKey,
      );
    }
  }

  Future<void> selectCity(String cityName, [SettingsProvider? settingsProvider]) async {
    _location = await _locationService.selectCity(cityName);
    await loadPrayerTimes(settingsProvider);
    notifyListeners();
  }

  Future<void> useGpsLocation([SettingsProvider? settingsProvider]) async {
    final gpsLocation = await _locationService.getCurrentLocation();
    if (gpsLocation != null) {
      _location = gpsLocation;
      await _locationService.saveLocation(gpsLocation);
      await _locationService.setUseGps(true);
      await loadPrayerTimes(settingsProvider);
      notifyListeners();
    }
  }

  List<String> getCityList() {
    return _locationService.getCityList();
  }

  PrayerEntry? getNextPrayer() {
    if (_prayerTimes == null) return null;

    final prayers = _prayerTimes!.getPrayerList();
    final now = DateTime.now();

    for (final prayer in prayers) {
      if (prayer.time.isAfter(now)) {
        return prayer;
      }
    }

    return null;
  }

  Duration? getTimeUntilNextPrayer() {
    final nextPrayer = getNextPrayer();
    if (nextPrayer == null) return null;

    final now = DateTime.now();
    final diff = nextPrayer.time.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }
}
