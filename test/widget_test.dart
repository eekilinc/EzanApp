import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/models/daily_content.dart';
import 'package:ezan_app/models/prayer_times.dart';

void main() {
  test('DailyContent has at least 30 entries', () {
    expect(DailyContent.contents.length, greaterThanOrEqualTo(30));
  });

  test('DailyContent getTodayContent returns valid content', () {
    final content = DailyContent.getTodayContent();
    expect(content.text, isNotEmpty);
    expect(content.source, isNotEmpty);
    expect(content.type, isNotEmpty);
  });

  test('PrayerEntry getDisplayTime formats time correctly', () {
    final time = DateTime(2026, 7, 22, 5, 30);
    final entry = PrayerEntry(name: 'Fajr', time: time);
    expect(entry.getDisplayTime(), '05:30');
  });

  test('PrayerEntry getDisplayTime pads single digit hours and minutes', () {
    final time = DateTime(2026, 7, 22, 9, 5);
    final entry = PrayerEntry(name: 'Fajr', time: time);
    expect(entry.getDisplayTime(), '09:05');
  });
}
