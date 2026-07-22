import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/models/location_data.dart';

void main() {
  group('LocationData', () {
    test('fromJson creates LocationData correctly', () {
      final json = {
        'city': 'Istanbul',
        'latitude': 41.0082,
        'longitude': 28.9784,
        'updatedAt': '2026-07-22T10:00:00.000Z',
      };

      final location = LocationData.fromJson(json);

      expect(location.city, 'Istanbul');
      expect(location.latitude, 41.0082);
      expect(location.longitude, 28.9784);
    });

    test('toJson converts LocationData to map', () {
      final now = DateTime(2026, 7, 22, 10, 0);
      final location = LocationData(
        city: 'Istanbul',
        latitude: 41.0082,
        longitude: 28.9784,
        updatedAt: now,
      );

      final json = location.toJson();

      expect(json['city'], 'Istanbul');
      expect(json['latitude'], 41.0082);
      expect(json['longitude'], 28.9784);
      expect(json['updatedAt'], now.toIso8601String());
    });

    test('roundtrip fromJson and toJson preserves data', () {
      final original = {
        'city': 'Ankara',
        'latitude': 39.9334,
        'longitude': 32.8597,
        'updatedAt': '2026-07-22T10:00:00.000Z',
      };

      final location = LocationData.fromJson(original);
      final json = location.toJson();

      expect(json['city'], original['city']);
      expect(json['latitude'], original['latitude']);
      expect(json['longitude'], original['longitude']);
    });
  });
}
