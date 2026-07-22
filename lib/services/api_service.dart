import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times.dart';

class ApiService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  static const String _cacheKeyPrefix = 'cached_prayer_times_';
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<PrayerTimes> getPrayerTimesForToday({
    required double latitude,
    required double longitude,
  }) async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final cacheKey = '$_cacheKeyPrefix${dateStr}_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

    try {
      final timestamp = now.millisecondsSinceEpoch ~/ 1000;
      final response = await _dio.get(
        '$_baseUrl/timings/$timestamp',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': 2,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final prayerData = data['data'] as Map<String, dynamic>;

        // Cache response locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(prayerData));

        return PrayerTimes.fromJson(prayerData);
      } else {
        throw Exception('API yanıt veremedi (Status: ${response.statusCode})');
      }
    } catch (e) {
      // Try to fallback to cached data if offline or error occurs
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);

      if (cachedJson != null) {
        final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
        return PrayerTimes.fromJson(cachedData);
      }

      // If no specific cache for today, look for any recent cached prayer times
      final keys = prefs.getKeys().where((k) => k.startsWith(_cacheKeyPrefix));
      if (keys.isNotEmpty) {
        final lastKey = keys.last;
        final cachedJson = prefs.getString(lastKey);
        if (cachedJson != null) {
          final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
          return PrayerTimes.fromJson(cachedData);
        }
      }

      throw Exception('Namaz vakitleri alınamadı. İnternet bağlantınızı kontrol edin.');
    }
  }
}
