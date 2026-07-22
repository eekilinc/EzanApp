import 'package:dio/dio.dart';
import '../models/prayer_times.dart';

class ApiService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  final Dio _dio = Dio();

  Future<PrayerTimes> getPrayerTimes({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  }) async {
    try {
      // Get first day of the month for timestamp
      final firstDay = DateTime(year, month, 1);
      final timestamp = (firstDay.millisecondsSinceEpoch / 1000).toInt();

      final response = await _dio.get(
        '$_baseUrl/timings/$timestamp',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': 2,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return PrayerTimes.fromJson(data['data']);
      } else {
        throw Exception('Failed to load prayer times');
      }
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<PrayerTimes> getPrayerTimesForToday({
    required double latitude,
    required double longitude,
  }) async {
    final now = DateTime.now();
    return getPrayerTimes(
      latitude: latitude,
      longitude: longitude,
      year: now.year,
      month: now.month,
    );
  }

  Future<List<PrayerTimes>> getPrayerTimesForMonth({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  }) async {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final prayerTimesList = <PrayerTimes>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final timestamp =
          DateTime(year, month, day).millisecondsSinceEpoch ~/ 1000;
      try {
        final response = await _dio.get(
          '$_baseUrl/timings/$timestamp',
          queryParameters: {
            'latitude': latitude,
            'longitude': longitude,
            'method': 2,
          },
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          prayerTimesList.add(PrayerTimes.fromJson(data['data']));
        }
      } catch (e) {
        continue;
      }
    }

    return prayerTimesList;
  }
}
