import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/services/qibla_service.dart';

void main() {
  group('QiblaService', () {
    test('calculateQiblaDirection returns valid degree between 0 and 360', () {
      // Istanbul coordinates
      final qiblaIstanbul = QiblaService.calculateQiblaDirection(41.0082, 28.9784);
      expect(qiblaIstanbul, greaterThanOrEqualTo(0));
      expect(qiblaIstanbul, lessThanOrEqualTo(360));
      // Istanbul Qibla is roughly 150-160 degrees
      expect(qiblaIstanbul, closeTo(152.0, 5.0));
    });

    test('calculateDistanceToMecca returns reasonable distance in km', () {
      // Istanbul to Mecca distance is roughly 2400-2500 km
      final distance = QiblaService.calculateDistanceToMecca(41.0082, 28.9784);
      expect(distance, greaterThan(2000));
      expect(distance, lessThan(3000));
    });

    test('validateCoordinates throws on out-of-range values', () {
      expect(() => QiblaService.calculateQiblaDirection(91, 0),
          throwsArgumentError);
      expect(() => QiblaService.calculateQiblaDirection(0, 181),
          throwsArgumentError);
      expect(() => QiblaService.calculateDistanceToMecca(-91, 0),
          throwsArgumentError);
    });

    test('validateCoordinates accepts boundary values', () {
      expect(() => QiblaService.calculateQiblaDirection(90, 180),
          returnsNormally);
      expect(() => QiblaService.calculateQiblaDirection(-90, -180),
          returnsNormally);
    });
  });
}
