import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/models/islamic_event.dart';
import 'package:ezan_app/services/hijri_service.dart';

void main() {
  group('IslamicEvent.daysRemaining', () {
    test('truncates time components (no off-by-one)', () {
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

    test('tomorrow is 1', () {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final event = IslamicEvent(
        titleTr: 'Test',
        titleEn: 'Test',
        hijri: '1 Test 1447',
        dateTr: 'Yarın',
        dateEn: 'Tomorrow',
        gregorianDate: tomorrow,
        icon: Icons.event,
        color: Colors.teal,
      );
      expect(event.daysRemaining, 1);
    });
  });

  group('IslamicEventService — hesaplanan tarihler', () {
    test('tarihler bugünden sonra ve asla boş liste dönmez', () {
      final upcoming = IslamicEventService.getUpcomingEvents();
      expect(upcoming, isNotEmpty,
          reason: '2026 sonunda liste boşalmamalı — bu regresyonun '
              'asıl nedeni buydu');
    });

    test('tüm tanımlı etkinlikler her zaman listelenir', () {
      // Sabit 2026 listesinin en büyük riski: Aralık ayında liste boş kalması.
      final events = IslamicEventService.events(reference: DateTime(2026, 12, 25));
      expect(events.length, 9);
    });

    test('Ramazan başlangıcı hicri 1/9 ile tanımlı', () {
      final events = IslamicEventService.events(reference: DateTime(2026, 1, 1));
      final ramadan = events.firstWhere((e) => e.titleTr.contains('Ramazan-ı'));
      expect(ramadan.hijri, contains('Ramazan'));
      // 1 Ramazan 1447 -> Şubat 2026 civarı
      expect(ramadan.gregorianDate.year, 2026);
      expect(ramadan.gregorianDate.month, 2);
    });

    test('her etkinliğin Gregorian tarihi, tanımladığı hicri güne düşer', () {
      // Tarih etiketindeki hicri günü ile hesaplanan Gregorian tarihin
      // gerçekten aynı güne denk geldiğini doğrular.
      final events = IslamicEventService.events(reference: DateTime(2026, 5, 1));
      for (final e in events) {
        final h = HijriService.toHijri(e.gregorianDate);
        final label = '${e.titleTr} (${e.hijri}) -> ${e.gregorianDate}';
        // "10 Zilhicce 1447" gibi etiketten günü çıkar
        final expectedDay = int.parse(e.hijri.split(' ').first);
        expect(h.day, expectedDay, reason: '$label: gün uyuşmuyor');
        // Yıl da aynı olmalı (yılbaşı hariç değil, hepsi için)
        final expectedYear = int.parse(e.hijri.split(' ').last);
        expect(h.year, expectedYear, reason: '$label: yıl uyuşmuyor');
      }
    });

    test('Aşure ve yılbaşı Muharrem ayında', () {
      final events = IslamicEventService.events(reference: DateTime(2026, 7, 1));
      for (final e in events) {
        if (e.titleTr.startsWith('Aşure') ||
            e.titleTr.startsWith('Hicri Yılbaşı')) {
          final h = HijriService.toHijri(e.gregorianDate);
          expect(h.month, 1, reason: '${e.titleTr} Muharrem ayında olmalı');
        }
      }
    });

    test('yılbaşı başlığı hicri yılı içerir', () {
      final events = IslamicEventService.events(reference: DateTime(2026, 1, 1));
      final newYear =
          events.firstWhere((e) => e.titleTr.startsWith('Hicri Yılbaşı'));
      final h = HijriService.toHijri(newYear.gregorianDate);
      expect(newYear.titleTr, contains('${h.year}'));
    });

    test('aynı etkinlik iki kez listelenmez (tek oluşum)', () {
      final events = IslamicEventService.events();
      final titles = events.map((e) => e.titleTr).toList();
      expect(titles.toSet().length, titles.length);
    });
  });

  group('IslamicEventService — sıralama ve ileri kayma', () {
    test('getUpcomingEvents is sorted ascending', () {
      final upcoming = IslamicEventService.getUpcomingEvents();
      for (var i = 1; i < upcoming.length; i++) {
        expect(
          upcoming[i].gregorianDate.isBefore(upcoming[i - 1].gregorianDate),
          isFalse,
        );
      }
    });

    test('getUpcomingEvents never returns past events', () {
      final upcoming = IslamicEventService.getUpcomingEvents();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      for (final e in upcoming) {
        expect(e.gregorianDate.isBefore(today), isFalse);
      }
    });

    test('getNextEvent returns first upcoming', () {
      final next = IslamicEventService.getNextEvent();
      final upcoming = IslamicEventService.getUpcomingEvents();
      expect(next, isNotNull);
      expect(next!.gregorianDate, upcoming.first.gregorianDate);
    });

    test('geçmiş bir yıla referans verilince listede o yılın etkinliği aranır', () {
      // 2026'nın Ramazan'ı Şubat'ta; Ocak'tan bakınca listede görünmeli.
      final events = IslamicEventService.events(reference: DateTime(2026, 1, 5));
      final ramadan =
          events.firstWhere((e) => e.titleTr.contains('Ramazan-ı'));
      expect(ramadan.gregorianDate.isAfter(DateTime(2026, 1, 5)), isTrue);
    });

    test('yıl boyunca ileri kayar (2027 referansı)', () {
      final events = IslamicEventService.events(reference: DateTime(2027, 5, 1));
      expect(events, isNotEmpty);
      // 2027'de Kurban Bayramı Temmuz'da (10 Zilhicce), 2026'da Mayıs'ta.
      final kurban =
          events.firstWhere((e) => e.titleTr.startsWith('Kurban Bayramı'));
      expect(kurban.gregorianDate.year, 2027);
    });
  });
}