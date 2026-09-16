import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/constants/reminders.dart';

void main() {
  group('Reminders constants', () {
    test('Sunrise has default reminder and display name', () {
      expect(defaultReminderMinutes.containsKey('Sunrise'), isTrue);
      expect(prayerNames.contains('Sunrise'), isTrue);
      expect(prayerDisplayNames['Sunrise'], isNotNull);
    });

    test('adhan list excludes Sunrise', () {
      expect(adhanPrayerNames.contains('Sunrise'), isFalse);
      expect(adhanPrayerNames.length, 5);
    });

    test('all prayerNames have display names', () {
      for (final name in prayerNames) {
        expect(prayerDisplayNames.containsKey(name), isTrue,
            reason: '$name için görünen ad eksik');
      }
    });
  });
}
