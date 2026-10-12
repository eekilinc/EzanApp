import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times.dart';
import 'lru_cache.dart';

class ApiService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  static const String _cacheKeyPrefix = 'cached_prayer_times_';
  
  // In-memory cache for instant zero-latency access.
  // Sınırlı: günlük veri en fazla 45 gün, aylık veri en fazla 6 ay.
  // Gerçek kullanımda bu sınırlara yaklaşılmaz; ama sınırsız büyümenin
  // önüne geçmek için.
  static final LruCache<String, PrayerTimes> _memoryCache = LruCache(45);
  static final LruCache<String, List<PrayerTimes>> _monthlyMemoryCache =
      LruCache(6);

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  Future<PrayerTimes> getPrayerTimesForToday({
    required double latitude,
    required double longitude,
    String school = 'standard',
    int calcMethod = 13,
  }) async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final cacheKey = '$_cacheKeyPrefix${dateStr}_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_${school}_$calcMethod';

    // 1. Check in-memory cache (0ms instant return)
    final cachedToday = _memoryCache.get(cacheKey);
    if (cachedToday != null) return cachedToday;

    // 2. Check SharedPreferences cache (fast local disk read)
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(cacheKey);

    if (cachedJson != null) {
      try {
        final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
        final prayerTimes = PrayerTimes.fromJson(cachedData);
        _memoryCache.put(cacheKey, prayerTimes);

        // Background refresh in background without blocking UI
        unawaited(_fetchAndCacheToday(latitude, longitude, school, calcMethod, cacheKey, prefs));

        return prayerTimes;
      } catch (_) {}
    }

    // 3. Network fetch if no cache available
    return await _fetchAndCacheToday(latitude, longitude, school, calcMethod, cacheKey, prefs);
  }

  Future<PrayerTimes> _fetchAndCacheToday(
    double latitude,
    double longitude,
    String school,
    int calcMethod,
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
        'method': calcMethod,
        'school': school == 'hanafi' ? 1 : 0,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final prayerData = data['data'] as Map<String, dynamic>;

      await prefs.setString(cacheKey, jsonEncode(prayerData));
      final prayerTimes = PrayerTimes.fromJson(prayerData);
      _memoryCache.put(cacheKey, prayerTimes);

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
    int calcMethod = 13,
  }) async {
    final cacheKey = 'cached_monthly_${year}_${month}_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_${school}_$calcMethod';

    final cachedMonth = _monthlyMemoryCache.get(cacheKey);
    if (cachedMonth != null) return cachedMonth;

    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(cacheKey);
    if (cachedJson != null) {
      try {
        final list = jsonDecode(cachedJson) as List<dynamic>;
        final monthlyTimes = list.map((item) => PrayerTimes.fromJson(item as Map<String, dynamic>)).toList();
        _monthlyMemoryCache.put(cacheKey, monthlyTimes);
        return monthlyTimes;
      } catch (_) {}
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/calendar/$year/$month',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': calcMethod,
          'school': school == 'hanafi' ? 1 : 0,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>;

        await prefs.setString(cacheKey, jsonEncode(list));
        final monthlyTimes = list.map((item) => PrayerTimes.fromJson(item as Map<String, dynamic>)).toList();
        _monthlyMemoryCache.put(cacheKey, monthlyTimes);

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
