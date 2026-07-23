import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times.dart';

class ApiService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  static const String _cacheKeyPrefix = 'cached_prayer_times_';
  
  // In-memory cache for instant zero-latency access
  static final Map<String, PrayerTimes> _memoryCache = {};
  static final Map<String, List<PrayerTimes>> _monthlyMemoryCache = {};

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  Future<PrayerTimes> getPrayerTimesForToday({
    required double latitude,
    required double longitude,
    String school = 'standard',
  }) async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final cacheKey = '$_cacheKeyPrefix${dateStr}_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_$school';

    // 1. Check in-memory cache (0ms instant return)
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey]!;
    }

    // 2. Check SharedPreferences cache (fast local disk read)
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(cacheKey);

    if (cachedJson != null) {
      try {
        final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
        final prayerTimes = PrayerTimes.fromJson(cachedData);
        _memoryCache[cacheKey] = prayerTimes;

        // Background refresh in background without blocking UI
        _fetchAndCacheToday(latitude, longitude, school, cacheKey, prefs).ignore();

        return prayerTimes;
      } catch (_) {}
    }

    // 3. Network fetch if no cache available
    return await _fetchAndCacheToday(latitude, longitude, school, cacheKey, prefs);
  }

  Future<PrayerTimes> _fetchAndCacheToday(
    double latitude,
    double longitude,
    String school,
    String cacheKey,
    SharedPreferences prefs,
  ) async {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch ~/ 1000;
    final response = await _dio.get(
      '$_baseUrl/timings/$timestamp',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'method': 13, // Diyanet / Turkey Method
        'school': school == 'hanafi' ? 1 : 0,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final prayerData = data['data'] as Map<String, dynamic>;

      await prefs.setString(cacheKey, jsonEncode(prayerData));
      final prayerTimes = PrayerTimes.fromJson(prayerData);
      _memoryCache[cacheKey] = prayerTimes;

      return prayerTimes;
    } else {
      throw Exception('API yanıt veremedi (Status: ${response.statusCode})');
    }
  }

  Future<List<PrayerTimes>> getMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
    String school = 'standard',
  }) async {
    final cacheKey = 'cached_monthly_${year}_${month}_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_$school';

    if (_monthlyMemoryCache.containsKey(cacheKey)) {
      return _monthlyMemoryCache[cacheKey]!;
    }

    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(cacheKey);
    if (cachedJson != null) {
      try {
        final list = jsonDecode(cachedJson) as List<dynamic>;
        final monthlyTimes = list.map((item) => PrayerTimes.fromJson(item as Map<String, dynamic>)).toList();
        _monthlyMemoryCache[cacheKey] = monthlyTimes;
        return monthlyTimes;
      } catch (_) {}
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/calendar/$year/$month',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': 13,
          'school': school == 'hanafi' ? 1 : 0,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>;

        await prefs.setString(cacheKey, jsonEncode(list));
        final monthlyTimes = list.map((item) => PrayerTimes.fromJson(item as Map<String, dynamic>)).toList();
        _monthlyMemoryCache[cacheKey] = monthlyTimes;

        return monthlyTimes;
      } else {
        throw Exception('Aylık takvim alınamadı');
      }
    } catch (e) {
      if (cachedJson != null) {
        final list = jsonDecode(cachedJson) as List<dynamic>;
        return list.map((item) => PrayerTimes.fromJson(item as Map<String, dynamic>)).toList();
      }
      rethrow;
    }
  }
}
