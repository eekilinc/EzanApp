import 'package:geolocator/geolocator.dart';
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
      await Geolocator.openLocationSettings();
      return false;
    }

    return true;
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationData(
        city: 'Current Location',
        latitude: position.latitude,
        longitude: position.longitude,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
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
    final city = turkishCities.firstWhere(
      (c) => c.name.toLowerCase() == cityName.toLowerCase(),
      orElse: () => turkishCities.first,
    );

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
