import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/services/update_service.dart';

void main() {
  group('UpdateService.isNewerVersion', () {
    test('returns true when latest major is higher', () {
      expect(UpdateService.isNewerVersion('6.0.0', '5.0.0'), isTrue);
      expect(UpdateService.isNewerVersion('v6.0.0', '5.0.0'), isTrue);
    });

    test('returns true when latest minor is higher', () {
      expect(UpdateService.isNewerVersion('5.1.0', '5.0.0'), isTrue);
      expect(UpdateService.isNewerVersion('v5.2.0', 'v5.1.0'), isTrue);
    });

    test('returns true when latest patch is higher', () {
      expect(UpdateService.isNewerVersion('5.0.1', '5.0.0'), isTrue);
      expect(UpdateService.isNewerVersion('v5.0.5', '5.0.4'), isTrue);
    });

    test('returns false when latest is equal to current', () {
      expect(UpdateService.isNewerVersion('5.0.0', '5.0.0'), isFalse);
      expect(UpdateService.isNewerVersion('v5.0.0', '5.0.0'), isFalse);
      expect(UpdateService.isNewerVersion('5.0.0+80', '5.0.0'), isFalse);
    });

    test('returns false when latest is older than current', () {
      expect(UpdateService.isNewerVersion('4.0.4', '5.0.0'), isFalse);
      expect(UpdateService.isNewerVersion('v4.9.9', 'v5.0.0'), isFalse);
    });

    test('handles empty or malformed strings gracefully', () {
      expect(UpdateService.isNewerVersion('', '5.0.0'), isFalse);
      expect(UpdateService.isNewerVersion('5.0.0', ''), isFalse);
    });
  });
}
