import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/models/prayer_times.dart';

void main() {
  group('PrayerTimes', () {
    test('fromJson creates PrayerTimes correctly', () {
      final json = {
        'date': {
          'gregorian': {'date': '22-7-2026'}
        },
        'timings': {
          'Fajr': '05:30',
          'Dhuhr': '12:30',
          'Asr': '15:45',
          'Maghrib': '18:15',
          'Isha': '19:30',
        }
      };

      final prayerTimes = PrayerTimes.fromJson(json);

      expect(prayerTimes.date.year, 2026);
      expect(prayerTimes.date.month, 7);
      expect(prayerTimes.date.day, 22);
      expect(prayerTimes.timings.length, 5);
    });

    test('getTimingByName returns correct time', () {
      final json = {
        'date': {
          'gregorian': {'date': '22-7-2026'}
        },
        'timings': {
          'Fajr': '05:30',
          'Dhuhr': '12:30',
        }
      };

      final prayerTimes = PrayerTimes.fromJson(json);
      final fajrTime = prayerTimes.getTimingByName('Fajr');

      expect(fajrTime, isNotNull);
      expect(fajrTime!.hour, 5);
      expect(fajrTime.minute, 30);
    });

    test('getPrayerList returns prayers in order', () {
      final json = {
        'date': {
          'gregorian': {'date': '22-7-2026'}
        },
        'timings': {
          'Fajr': '05:30',
          'Dhuhr': '12:30',
          'Asr': '15:45',
          'Maghrib': '18:15',
          'Isha': '19:30',
        }
      };

      final prayerTimes = PrayerTimes.fromJson(json);
      final prayers = prayerTimes.getPrayerList();

      expect(prayers.length, 5);
      expect(prayers[0].name, 'Fajr');
      expect(prayers[4].name, 'Isha');
    });

    test('withOffsets adjusts timings correctly', () {
      final json = {
        'date': {
          'gregorian': {'date': '22-7-2026'}
        },
        'timings': {
          'Fajr': '05:30',
          'Dhuhr': '12:30',
          'Asr': '15:45',
          'Maghrib': '18:15',
          'Isha': '19:30',
        }
      };

      final prayerTimes = PrayerTimes.fromJson(json);
      final adjusted = prayerTimes.withOffsets({
        'Fajr': 5,
        'Maghrib': -3,
        'Isha': 0,
      });

      expect(adjusted.fajrTime, '05:35');
      expect(adjusted.dhuhrTime, '12:30');
      expect(adjusted.maghribTime, '18:12');
      expect(adjusted.ishaTime, '19:30');
    });
  });

  group('PrayerEntry', () {
    test('getDisplayTime formats time correctly', () {
      final time = DateTime(2026, 7, 22, 5, 30);
      final entry = PrayerEntry(name: 'Fajr', time: time);

      expect(entry.getDisplayTime(), '05:30');
    });

    test('getDisplayTime pads single digit hours and minutes', () {
      final time = DateTime(2026, 7, 22, 9, 5);
      final entry = PrayerEntry(name: 'Fajr', time: time);

      expect(entry.getDisplayTime(), '09:05');
    });
  });
}
