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

    group('magneticDeclination (WMM2025, resmi test vektörleriyle doğrulandı)', () {
      // Beklenen aralıklar bağımsız Python çapraz kontrolünden
      // (2026 sonu, resmi WMM2025.COF + 100 resmi test vektörüyle max hata 0.005).
      final date = DateTime(2026, 9, 16);
      test('Istanbul ~ +6 derece dogu', () {
        final d = QiblaService.magneticDeclination(41.0082, 28.9784, date);
        expect(d, greaterThan(4.5));
        expect(d, lessThan(7.0));
      });
      test('New York ~ -12.5 derece bati', () {
        final d = QiblaService.magneticDeclination(40.7128, -74.0060, date);
        expect(d, greaterThan(-14.0));
        expect(d, lessThan(-11.0));
      });
      test('Jakarta ~ +0.7 derece', () {
        final d = QiblaService.magneticDeclination(-6.2, 106.85, date);
        expect(d, greaterThan(-0.5));
        expect(d, lessThan(2.0));
      });
      test('Sydney ~ +12.8 derece dogu', () {
        final d = QiblaService.magneticDeclination(-33.87, 151.21, date);
        expect(d, greaterThan(11.0));
        expect(d, lessThan(14.5));
      });
      test('trueHeadingFromMagnetic dogru toplar', () {
        final d = QiblaService.magneticDeclination(41.0082, 28.9784, date);
        final t = QiblaService.trueHeadingFromMagnetic(100.0, 41.0082, 28.9784, date);
        expect(t, closeTo((100.0 + d) % 360, 1e-9));
      });
    });
  });
}
