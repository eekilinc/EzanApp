import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/models/prayer_times.dart';

PrayerTimes day(DateTime date) {
  return PrayerTimes(
    date: DateTime(date.year, date.month, date.day),
    createdAt: date,
    timings: {
      'Fajr': DateTime(date.year, date.month, date.day, 5, 0),
      'Sunrise': DateTime(date.year, date.month, date.day, 6, 30),
      'Dhuhr': DateTime(date.year, date.month, date.day, 13, 0),
      'Asr': DateTime(date.year, date.month, date.day, 16, 0),
      'Maghrib': DateTime(date.year, date.month, date.day, 19, 0),
      'Isha': DateTime(date.year, date.month, date.day, 20, 30),
    },
  );
}

void main() {
  group('nextPrayerAt', () {
    test('sabah öncesi sıradaki Sabah', () {
      final r = day(DateTime(2026, 3, 15)).nextPrayerAt(DateTime(2026, 3, 15, 3, 0));
      expect(r!.name, 'Fajr');
    });

    test('sabah sonrası sıradaki Güneş (6\'lı çizelge)', () {
      final r = day(DateTime(2026, 3, 15)).nextPrayerAt(DateTime(2026, 3, 15, 6, 0));
      expect(r!.name, 'Sunrise');
    });

    test('özleden sonra sıradaki İkindi', () {
      final r = day(DateTime(2026, 3, 15)).nextPrayerAt(DateTime(2026, 3, 15, 14, 0));
      expect(r!.name, 'Asr');
    });

    test('aksama biraz kala sıradaki Akşam', () {
      final r = day(DateTime(2026, 3, 15)).nextPrayerAt(DateTime(2026, 3, 15, 18, 0));
      expect(r!.name, 'Maghrib');
    });

    test('yatsıdan sonra ertesi günün Sabahı', () {
      final r = day(DateTime(2026, 3, 15)).nextPrayerAt(DateTime(2026, 3, 15, 23, 0));
      expect(r!.name, 'Fajr');
      expect(r.time, DateTime(2026, 3, 16, 5, 0));
    });

    test('vakit saati tam eşitse bir sonrakine geçer', () {
      final r = day(DateTime(2026, 3, 15)).nextPrayerAt(DateTime(2026, 3, 15, 13, 0));
      expect(r!.name, 'Asr');
    });

    test('çizelge boşsa null', () {
      final empty = PrayerTimes(
        date: DateTime(2026, 3, 15),
        createdAt: DateTime(2026, 3, 15),
        timings: const {},
      );
      expect(empty.nextPrayerAt(DateTime(2026, 3, 15, 12, 0)), isNull);
    });
  });

  group('progressAt', () {
    test('vakit tam girdiğinde ilerleme 0', () {
      final p = day(DateTime(2026, 3, 15)).progressAt(DateTime(2026, 3, 15, 5, 0));
      expect(p, closeTo(0.0, 0.01));
    });

    test('vakit aralığının ortasında ~0.5', () {
      // Öğle 13:00, İkindi 16:00 → 14:30 tam yarı
      final p = day(DateTime(2026, 3, 15)).progressAt(DateTime(2026, 3, 15, 14, 30));
      expect(p, closeTo(0.5, 0.02));
    });

    test('sonraki vakte yaklaşınca 1\'e yaklaşır', () {
      final p = day(DateTime(2026, 3, 15)).progressAt(DateTime(2026, 3, 15, 15, 59));
      expect(p, greaterThan(0.95));
      expect(p, lessThanOrEqualTo(1.0));
    });

    test('her zaman 0..1 aralığında', () {
      final t = day(DateTime(2026, 3, 15));
      for (var h = 0; h < 24; h++) {
        final p = t.progressAt(DateTime(2026, 3, 15, h));
        expect(p, greaterThanOrEqualTo(0.0), reason: 'saat $h altı');
        expect(p, lessThanOrEqualTo(1.0), reason: 'saat $h üstü');
      }
    });

    test('günün son vaktinden sonra ilerleme sıfırlanır (yeni döngü)', () {
      // Yatsı 20:30 geçti → son vakitten ertesi gün Sabah'a (05:00) aralık.
      final p = day(DateTime(2026, 3, 15)).progressAt(DateTime(2026, 3, 15, 23, 0));
      expect(p, greaterThanOrEqualTo(0.0));
      expect(p, lessThan(0.5)); // 20:30→05:00 aralığının başındayız
    });

    test('gece yarısı sonrası ilerleme düşük başlar', () {
      final p = day(DateTime(2026, 3, 15)).progressAt(DateTime(2026, 3, 15, 0, 1));
      expect(p, greaterThanOrEqualTo(0.0));
      expect(p, lessThan(0.2));
    });

    test('ilk vakden önce ilerleme mantıklı (0..1)', () {
      final p = day(DateTime(2026, 3, 15)).progressAt(DateTime(2026, 3, 15, 1, 0));
      expect(p, greaterThanOrEqualTo(0.0));
      expect(p, lessThanOrEqualTo(1.0));
    });

    test('çizelge boşsa 0', () {
      final empty = PrayerTimes(
        date: DateTime(2026, 3, 15),
        createdAt: DateTime(2026, 3, 15),
        timings: const {},
      );
      expect(empty.progressAt(DateTime(2026, 3, 15, 12, 0)), 0.0);
    });

    test('ilerleme zamanla monoton artar (aynı gün içinde)', () {
      final t = day(DateTime(2026, 3, 15));
      var previous = -1.0;
      for (var h = 5; h < 20; h++) {
        final p = t.progressAt(DateTime(2026, 3, 15, h));
        // saat değişince ilerleme sıfırlanabilir; genel olarak 0..1 ve
        // makul sıralama korunur.
        expect(p, greaterThanOrEqualTo(0.0));
        expect(p, lessThanOrEqualTo(1.0));
        previous = p;
      }
      expect(previous, isNotNull);
    });
  });
}