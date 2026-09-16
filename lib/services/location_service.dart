import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/location_data.dart';

class LocationService {
  static const String _locationKey = 'user_location';
  static const String _useGpsKey = 'use_gps';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      return result == LocationPermission.whileInUse ||
          result == LocationPermission.always;
    }

    if (permission == LocationPermission.deniedForever) {
      // Kalıcı rette konum ayarları değil, uygulama ayarları açılmalı
      // (kullanıcı izni yalnızca oradan geri verebilir).
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  /// Cihaz konum servisi (GPS) açık mı?
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      // GPS kapalıysa sessizce değil, erken çık (çağıran kullanıcıya bildirir).
      if (!await isLocationServiceEnabled()) return null;

      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // İl/ilçe adını çöz (başarısız olursa "Current Location" kalır).
      final cityName = await resolvePlaceName(
        position.latitude,
        position.longitude,
      );

      return LocationData(
        city: cityName ?? 'Current Location',
        latitude: position.latitude,
        longitude: position.longitude,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Koordinattan "İlçe, İl" adını çözer. ~1 km ızgara önbelleği sayesinde
  /// aynı bölgede tekrar ağ isteği yapılmaz; çevrimdışı/hatada null döner
  /// (çağıran "Current Location" kullanır).
  Future<String?> resolvePlaceName(double latitude, double longitude) async {
    final gridKey =
        'geo_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    try {
      final cached = _prefs.getString(gridKey);
      if (cached != null && cached.isNotEmpty) return cached;
    } catch (_) {}

    try {
      final placemarks = await geo
          .placemarkFromCoordinates(latitude, longitude, localeIdentifier: 'tr')
          .timeout(const Duration(seconds: 4));
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final district = (p.locality ?? p.subAdministrativeArea ?? '').trim();
      final city = (p.administrativeArea ?? '').trim();
      String? name;
      if (city.isNotEmpty && district.isNotEmpty && district != city) {
        name = '$district, $city';
      } else if (city.isNotEmpty) {
        name = city;
      } else if (district.isNotEmpty) {
        name = district;
      }
      if (name != null && name.isNotEmpty) {
        try {
          await _prefs.setString(gridKey, name);
        } catch (_) {}
        return name;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLocation(LocationData location) async {
    final json = jsonEncode(location.toJson());
    await _prefs.setString(_locationKey, json);
  }

  Future<LocationData?> getSavedLocation() async {
    final json = _prefs.getString(_locationKey);
    if (json == null) return null;

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return LocationData.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> setUseGps(bool useGps) async {
    await _prefs.setBool(_useGpsKey, useGps);
  }

  Future<bool> shouldUseGps() async {
    return _prefs.getBool(_useGpsKey) ?? true;
  }

  Future<LocationData?> getLocation() async {
    final useGps = await shouldUseGps();

    if (useGps) {
      final gpsLocation = await getCurrentLocation();
      if (gpsLocation != null) {
        await saveLocation(gpsLocation);
        return gpsLocation;
      }
    }

    return await getSavedLocation();
  }

  Future<LocationData> selectCity(String cityName) async {
    final matches = turkishCities.where(
      (c) => c.name.toLowerCase() == cityName.toLowerCase(),
    );
    if (matches.isEmpty) {
      // Sessizce yanlış şehre düşmek yerine hata fırlat (çağıran yakalar).
      throw ArgumentError('Bilinmeyen şehir: $cityName');
    }
    final city = matches.first;

    final location = LocationData(
      city: city.name,
      latitude: city.latitude,
      longitude: city.longitude,
      updatedAt: DateTime.now(),
    );

    await saveLocation(location);
    await setUseGps(false);
    return location;
  }

  List<String> getCityList() {
    return turkishCities.map((c) => c.name).toList();
  }
}
