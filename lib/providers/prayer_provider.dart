import 'package:flutter/material.dart';
import '../models/prayer_times.dart';
import '../models/location_data.dart';
import '../models/islamic_event.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/notification_planner.dart';
import 'settings_provider.dart';

class PrayerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();

  PrayerTimes? _prayerTimes;
  LocationData? _location;
  bool _isLoading = false;
  String? _error;

  // Gün devri ve saat dilimi değişimini yakalamak için izlenen durum.
  DateTime? _loadedForDate;
  Duration? _loadedWithOffset;

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
      final rawTimes = await _apiService.getPrayerTimesForToday(
        latitude: _location!.latitude,
        longitude: _location!.longitude,
        school: settingsProvider?.asrSchool ?? 'standard',
        calcMethod: settingsProvider?.calcMethod ?? 13,
      );

      _prayerTimes = rawTimes.withOffsets(settingsProvider?.prayerTimeOffsets);

      // Gün devri / saat dilimi takibi için damgala.
      final nowStamp = DateTime.now();
      _loadedForDate = DateTime(nowStamp.year, nowStamp.month, nowStamp.day);
      _loadedWithOffset = nowStamp.timeZoneOffset;

      // Mevcut vakitlerle bildirimleri tazele (ayarlar boşsa atlanır).
      await scheduleNotifications(settingsProvider);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Uygulama aradan dönünce çağrılır: gün devri veya saat dilimi/saat
  /// değişimi varsa vakitleri yeniden yükleyip bildirimleri tazeler.
  /// Yeniden yükleme yapıldıysa true döner (UI setState yapabilir).
  Future<bool> refreshIfDateOrTimezoneChanged([
    SettingsProvider? settingsProvider,
  ]) async {
    if (_location == null || _prayerTimes == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_loadedForDate != today || _loadedWithOffset != now.timeZoneOffset) {
      await loadPrayerTimes(settingsProvider);
      return true;
    }
    return false;
  }

  /// Bildirimleri yeniden planlar.
  ///
  /// [settings] null ise hiçbir şey yapılmaz — vakitler ya da konum henüz
  /// yoksa planlayacak bir şey de yoktur.
  Future<void> scheduleNotifications(SettingsProvider? settings) async {
    if (_prayerTimes == null || _location == null || settings == null) return;

    final request = NotificationPlanRequest(
      days: await _loadPlanningDays(settings.asrSchool, settings.calcMethod),
      now: DateTime.now(),
      reminderMinutes: settings.reminderMinutes,
      prayerOffsets: settings.prayerTimeOffsets,
      adhanSoundKey: settings.adhanSound,
      adhanSoundEnabled: settings.effectiveAdhanSoundEnabled,
      reminderSoundKey: settings.reminderSound,
      reminderSoundEnabled: settings.effectiveReminderSoundEnabled,
      vibrationEnabled: settings.vibrationEnabled,
      fridayReminderEnabled: settings.fridayReminderEnabled,
      sahurReminderEnabled: settings.sahurReminderEnabled,
      nextEvent: settings.eventReminderEnabled ? _safeNextEvent() : null,
    );

    // Saf hesap: girdi -> planlanacak bildirimler.
    final planned = NotificationPlanner.build(request);

    // Planı baştan yazıyoruz. Bildirimleri biriktirmek Android'de
    // AlarmManager kuyruğunu şişirir ve iptal edilmeyen kayıtlar kalır.
    await _notificationService.cancelAllNotifications();
    for (final n in planned) {
      await _notificationService.scheduleNotification(
        id: n.id,
        title: n.title,
        body: n.body,
        scheduledTime: n.scheduledTime,
        soundEnabled: n.soundEnabled,
        vibrationEnabled: n.vibrationEnabled,
        soundKey: n.soundKey,
        payload: n.payload,
      );
    }
  }

  /// Planlama için gün listesi: içinde bulunulan ay + pencere ay sonuna
  /// yetişmiyorsa bir sonraki ay.
  Future<List<PrayerTimes>> _loadPlanningDays(
    String asrSchool,
    int calcMethod,
  ) async {
    final now = DateTime.now();
    try {
      final month = await _apiService.getMonthlyPrayerTimes(
        latitude: _location!.latitude,
        longitude: _location!.longitude,
        year: now.year,
        month: now.month,
        school: asrSchool,
        calcMethod: calcMethod,
      );

      final days = List<PrayerTimes>.from(month);

      // Pencere bugün+7 gün; ayın 24'ünden sonrası bir sonraki aya taşar.
      if (now.day >= 24) {
        try {
          final nextMonth = await _apiService.getMonthlyPrayerTimes(
            latitude: _location!.latitude,
            longitude: _location!.longitude,
            year: now.year,
            month: now.month + 1,
            school: asrSchool,
            calcMethod: calcMethod,
          );
          days.addAll(nextMonth);
        } catch (_) {
          // Pencere bir sonraki aya yetişmiyor; içinde bulunulan ay yeter.
        }
      }

      return days;
    } catch (_) {
      // Aylık veri alınamadı — bugünkü vakitlerle devam. Bildirim eksik
      // olsa da hiç bildirim almamaktan iyidir.
      return [_prayerTimes!];
    }
  }

  IslamicEvent? _safeNextEvent() {
    try {
      return IslamicEventService.getNextEvent();
    } catch (_) {
      return null;
    }
  }

  Future<void> selectCity(
    String cityName, [
    SettingsProvider? settingsProvider,
  ]) async {
    try {
      _location = await _locationService.selectCity(cityName);
      await loadPrayerTimes(settingsProvider);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  /// GPS konumuna geçmeyi dener; başarı durumunu döner (UI bilgi verir).
  Future<bool> useGpsLocation([SettingsProvider? settingsProvider]) async {
    final gpsLocation = await _locationService.getCurrentLocation();
    if (gpsLocation != null) {
      _location = gpsLocation;
      await _locationService.saveLocation(gpsLocation);
      await _locationService.setUseGps(true);
      await loadPrayerTimes(settingsProvider);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Cihaz konum servisi (GPS) açık mı? (Konum seçim UI'ı için)
  Future<bool> isGpsEnabled() => _locationService.isLocationServiceEnabled();

  List<String> getCityList() {
    return _locationService.getCityList();
  }

  /// Şu an içinde bulunulan vakit.
  ///
  /// Hesaplama [PrayerTimes.currentPrayerAt] üzerinde yapılır; gece yarısı
  /// kenar durumu dahil tüm mantık orada ve testlidir.
  ({PrayerEntry prayer, bool isFromYesterday})? getCurrentPrayer({
    DateTime? now,
  }) {
    return _prayerTimes?.currentPrayerAt(now ?? DateTime.now());
  }

  double getPrayerProgress() {
    return _prayerTimes?.progressAt(DateTime.now()) ?? 0.0;
  }

  PrayerEntry? getNextPrayer() {
    return _prayerTimes?.nextPrayerAt(DateTime.now());
  }

  Duration? getTimeUntilNextPrayer() {
    final nextPrayer = getNextPrayer();
    if (nextPrayer == null) return null;

    final diff = nextPrayer.time.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }
}
