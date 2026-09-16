import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/models/islamic_event.dart';

void main() {
  group('IslamicEvent', () {
    test('daysRemaining truncates time components (no off-by-one)', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final event = IslamicEvent(
        titleTr: 'Test',
        titleEn: 'Test',
        hijri: '1 Test 1447',
        dateTr: 'Bugün',
        dateEn: 'Today',
        gregorianDate: today,
        icon: Icons.event,
        color: Colors.teal,
      );
      expect(event.daysRemaining, 0);
    });

    test('getUpcomingEvents never returns past events', () {
      final upcoming = IslamicEventService.getUpcomingEvents();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      for (final e in upcoming) {
        expect(e.gregorianDate.isBefore(today), isFalse);
      }
    });

    test('getUpcomingEvents is sorted ascending', () {
      final upcoming = IslamicEventService.getUpcomingEvents();
      for (var i = 1; i < upcoming.length; i++) {
        expect(
          upcoming[i].gregorianDate.isBefore(upcoming[i - 1].gregorianDate),
          isFalse,
        );
      }
    });

    test('getNextEvent returns first upcoming or null', () {
      final next = IslamicEventService.getNextEvent();
      final upcoming = IslamicEventService.getUpcomingEvents();
      if (upcoming.isEmpty) {
        expect(next, isNull);
      } else {
        expect(next, isNotNull);
        expect(next!.gregorianDate, upcoming.first.gregorianDate);
      }
    });
  });
}
