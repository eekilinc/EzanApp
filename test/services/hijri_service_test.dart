import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/services/hijri_service.dart';

void main() {
  group('HijriService', () {
    test('getHijriDate returns non-empty string in Turkish and English', () {
      final now = DateTime(2026, 7, 22);
      final trDate = HijriService.getHijriDate(now, 'tr');
      final enDate = HijriService.getHijriDate(now, 'en');

      expect(trDate, isNotEmpty);
      expect(enDate, isNotEmpty);
      expect(trDate, contains('144'));
      expect(enDate, contains('144'));
    });

    test('getGregorianDate formats correctly', () {
      final now = DateTime(2026, 7, 22);
      final trDate = HijriService.getGregorianDate(now, 'tr');
      final enDate = HijriService.getGregorianDate(now, 'en');

      expect(trDate, contains('Temmuz 2026'));
      expect(enDate, contains('July 2026'));
    });
  });
}
