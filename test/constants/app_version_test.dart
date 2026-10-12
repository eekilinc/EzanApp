import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/constants/app_version.dart';

/// Sürüm bilgisi üç yerde tutuluyor ve kayarsa in-app updater bozulur:
///   - pubspec.yaml      (build/release sırasında okunur)
///   - AppVersion        (uygulama içi "hangi sürümdeyim" ve updater karşılaştırması)
///   - GitHub tag'ı      (release iş akışı ve APK indirme bağlantısı)
/// Bu test ilk ikisini senkron tutar; tag'ı CI doğrulayacaktır.
void main() {
  group('AppVersion tutarlılığı', () {
    test('sürüm ve buildNumber beklenen biçimde', () {
      expect(AppVersion.version, matches(RegExp(r'^\d+\.\d+\.\d+$')));
      expect(AppVersion.buildNumber, greaterThan(0));
      expect(AppVersion.releaseTag, 'v${AppVersion.version}');
      expect(AppVersion.fullDisplay, contains(AppVersion.version));
    });

    test('pubspec.yaml ile aynı sürüm ve build numarası', () async {
      final pubspec = await File('pubspec.yaml').readAsString();
      final versionLine = RegExp(r'^version:\s*(\S+)\s*$', multiLine: true)
          .firstMatch(pubspec);

      expect(versionLine, isNotNull, reason: 'pubspec.yaml içinde version: yok');

      final raw = versionLine!.group(1)!; // ör. 5.4.0+88
      final parts = raw.split('+');
      final name = parts.first;
      final build = int.tryParse(parts.length > 1 ? parts[1] : '');

      expect(name, AppVersion.version,
          reason: 'pubspec.yaml ($name) != AppVersion (${AppVersion.version})');
      expect(build, AppVersion.buildNumber,
          reason: 'pubspec.yaml build ($build) != AppVersion '
              '(${AppVersion.buildNumber})');
    });
  });
}