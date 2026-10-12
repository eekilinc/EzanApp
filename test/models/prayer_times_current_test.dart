import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/models/prayer_times.dart';

PrayerTimes day(DateTime date, {bool withIsha = true}) {
  final t = <String, DateTime>{
    'Fajr': DateTime(date.year, date.month, date.day, 5, 0),
    'Sunrise': DateTime(date.year, date.month, date.day, 6, 30),
    'Dhuhr': DateTime(date.year, date.month, date.day, 13, 0),
    'Asr': DateTime(date.year, date.month, date.day, 16, 0),
    'Maghrib': DateTime(date.year, date.month, date.day, 19, 0),
  };
  if (withIsha) {
    t['Isha'] = DateTime(date.year, date.month, date.day, 20, 30);
  }
  return PrayerTimes(
    date: DateTime(date.year, date.month, date.day),
    createdAt: date,
    timings: t,
  );
}

void main() {
  group('currentPrayerAt — gündüz', () {
    test('sabah öncesi dünün Yatsı döner', () {
      final r = day(DateTime(2026, 3, 15))
          .currentPrayerAt(DateTime(2026, 3, 15, 3, 0));
      expect(r, isNotNull);
      expect(r!.prayer.name, 'Isha');
      expect(r.isFromYesterday, isTrue);
    });

    test('sabah-sonrası Sabah', () {
      final r = day(DateTime(2026, 3, 15))
          .currentPrayerAt(DateTime(2026, 3, 15, 5, 30));
      expect(r!.prayer.name, 'Fajr');
      expect(r.isFromYesterday, isFalse);
    });

    test('sabahın tamında (saat eşitliği) Sabah sayılır', () {
      final r = day(DateTime(2026, 3, 15))
          .currentPrayerAt(DateTime(2026, 3, 15, 5, 0));
      expect(r!.prayer.name, 'Fajr');
    });

    test('güneş doğumu vakti Güneş olur', () {
      final r = day(DateTime(2026, 3, 15))
          .currentPrayerAt(DateTime(2026, 3, 15, 7, 0));
      expect(r!.prayer.name, 'Sunrise');
    });

    test('öğleden sonra Öğle', () {
      final r = day(DateTime(2026, 3, 15))
          .currentPrayerAt(DateTime(2026, 3, 15, 14, 0));
      expect(r!.prayer.name, 'Dhuhr');
    });

    test('ikindiden sonra İkindi', () {
      final r = day(DateTime(2026, 3, 15))
          .currentPrayerAt(DateTime(2026, 3, 15, 17, 0));
      expect(r!.prayer.name, 'Asr');
    });

    test('aksamdan sonra Akşam', () {
      final r = day(DateTime(2026, 3, 15))
          .currentPrayerAt(DateTime(2026, 3, 15, 19, 30));
      expect(r!.prayer.name, 'Maghrib');
    });

    test('yatsıdan sonra Yatsı (bugünün)', () {
      final r = day(DateTime(2026, 3, 15))
          .currentPrayerAt(DateTime(2026, 3, 15, 22, 0));
      expect(r!.prayer.name, 'Isha');
      expect(r.isFromYesterday, isFalse);
    });
  });

  group('currentPrayerAt — gece yarısı kenar durumu', () {
    test('00:01 dünün Yatsı döner ve tarih bir gün geridedir', () {
      final r = day(DateTime(2026, 3, 15))
          .currentPrayerAt(DateTime(2026, 3, 15, 0, 1));
      expect(r!.prayer.name, 'Isha');
      expect(r.isFromYesterday, isTrue);
      expect(r.prayer.time, DateTime(2026, 3, 14, 20, 30));
    });

    test('23:59 bugünün Yatsı (geri tarih değil)', () {
      final r = day(DateTime(2026, 3, 15))
          .currentPrayerAt(DateTime(2026, 3, 15, 23, 59));
      expect(r!.prayer.time, DateTime(2026, 3, 15, 20, 30));
      expect(r.isFromYesterday, isFalse);
    });

    test('sabahın 1 dakika öncesi hâlâ dünün Yatsı', () {
      final r = day(DateTime(2026, 3, 15))
          .currentPrayerAt(DateTime(2026, 3, 15, 4, 59));
      expect(r!.prayer.name, 'Isha');
      expect(r.isFromYesterday, isTrue);
    });
  });

  group('currentPrayerAt — boş durumlar', () {
    test('Isha yoksa gece yarısında null döner', () {
      final r = day(DateTime(2026, 3, 15), withIsha: false)
          .currentPrayerAt(DateTime(2026, 3, 15, 3, 0));
      expect(r, isNull);
    });

    test('çizelge boşsa null', () {
      final empty = PrayerTimes(
        date: DateTime(2026, 3, 15),
        createdAt: DateTime(2026, 3, 15),
        timings: const {},
      );
      expect(empty.currentPrayerAt(DateTime(2026, 3, 15, 12, 0)), isNull);
    });
  });
}