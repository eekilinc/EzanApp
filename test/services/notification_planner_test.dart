import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_app/models/prayer_times.dart';
import 'package:ezan_app/models/islamic_event.dart';
import 'package:ezan_app/services/notification_planner.dart';
import 'package:ezan_app/constants/reminders.dart';

/// Belirli bir gün için altı vakitli zaman çizelgesi üretir.
PrayerTimes dayTimes(DateTime date) {
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

NotificationPlanRequest request({
  required DateTime now,
  List<PrayerTimes>? days,
  Map<String, int>? reminderMinutes,
  Map<String, int>? prayerOffsets,
  bool friday = true,
  bool sahur = false,
  IslamicEvent? nextEvent,
  int horizon = 7,
  bool adhanSound = true,
  bool reminderSound = true,
}) {
  return NotificationPlanRequest(
    days: days ?? [dayTimes(now)],
    now: now,
    reminderMinutes: reminderMinutes ?? defaultReminderMinutes,
    prayerOffsets: prayerOffsets ?? const {},
    adhanSoundKey: 'adhan_makkah',
    adhanSoundEnabled: adhanSound,
    reminderSoundKey: 'beep',
    reminderSoundEnabled: reminderSound,
    vibrationEnabled: true,
    fridayReminderEnabled: friday,
    sahurReminderEnabled: sahur,
    nextEvent: nextEvent,
    horizonDays: horizon,
  );
}

void main() {
  group('NotificationPlanner — kimlik üretimi', () {
    test('aynı girdi aynı kimliği üretir (deterministik)', () {
      final d = DateTime(2026, 3, 15);
      final a = NotificationPlanner.generateId('Fajr', d, 'exact');
      final b = NotificationPlanner.generateId('Fajr', d, 'exact');
      expect(a, b);
    });

    test('farklı vakit/tür/gün farklı kimlik üretir', () {
      final d = DateTime(2026, 3, 15);
      final ids = <int>{
        NotificationPlanner.generateId('Fajr', d, 'exact'),
        NotificationPlanner.generateId('Fajr', d, 'reminder'),
        NotificationPlanner.generateId('Isha', d, 'exact'),
        NotificationPlanner.generateId('Fajr', DateTime(2026, 3, 16), 'exact'),
      };
      expect(ids.length, 4);
    });

    test('kimlik her zaman pozitif 31-bit', () {
      final d = DateTime(2026, 1, 1);
      for (final p in prayerNames) {
        for (final t in ['exact', 'reminder']) {
          final id = NotificationPlanner.generateId(p, d, t);
          expect(id, greaterThanOrEqualTo(0));
          expect(id, lessThan(2147483648));
        }
      }
    });
  });

  group('NotificationPlanner — temel planlama', () {
    test('her ezan vakti için tam vakit bildirimi planlanır', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(now: now));
      final exacts = plan.where((n) => n.id != 666000 && n.title.contains('Vakti Girdi')).length;
      // 5 ezan vakti (Güneş hariç)
      expect(exacts, 5);
    });

    test('planlanan hiçbir bildirim geçmişte değil', () {
      final now = DateTime(2026, 3, 15, 17, 30); // Asr'ın sonrası
      final plan = NotificationPlanner.build(request(now: now));
      for (final n in plan) {
        expect(n.scheduledTime.isAfter(now), isTrue,
            reason: '"${n.title}" gecmişe planlanmış');
      }
    });

    test('geçmiş vakitler planlanmaz', () {
      final now = DateTime(2026, 3, 15, 21, 0); // yatsıdan sonra
      final plan = NotificationPlanner.build(request(now: now));
      expect(plan.where((n) => n.scheduledTime.hour < 21), isEmpty);
    });

    test('tam vakit bildirimi vakit saatinin tam kendisindedir', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(now: now));
      final maghrib = plan.firstWhere(
        (n) => n.title.contains('Akşam') && n.title.contains('Vakti Girdi'),
      );
      expect(maghrib.scheduledTime, DateTime(2026, 3, 15, 19, 0));
    });
  });

  group('NotificationPlanner — hatırlatıcı offsetleri', () {
    test('sıfırdan farklı hatırlatıcı vaktinden önce planlanır', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(
        now: now,
        reminderMinutes: {...defaultReminderMinutes, 'Dhuhr': 10},
      ));
      final reminder = plan.firstWhere(
        (n) => n.title.contains('Öğle') && n.title.contains('Hatırlatması'),
      );
      expect(reminder.scheduledTime, DateTime(2026, 3, 15, 12, 50));
    });

    test('negatif offset vakitten sonraya planlanır', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(
        now: now,
        reminderMinutes: {...defaultReminderMinutes, 'Dhuhr': -10},
      ));
      final reminder = plan.firstWhere(
        (n) => n.title.contains('Öğle') && n.title.contains('Hatırlatması'),
      );
      expect(reminder.scheduledTime, DateTime(2026, 3, 15, 13, 10));
    });

    test('sıfır offset hatırlatıcı üretmez', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(
        now: now,
        reminderMinutes: {...defaultReminderMinutes, 'Isha': 0},
      ));
      expect(plan.where((n) => n.title.contains('Yatsı') && n.title.contains('Hatırlatması')), isEmpty);
    });

    test('Güneş için hatırlatıcı saat 0 (Maghrib gibi) üretilmez', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(
        now: now,
        reminderMinutes: {...defaultReminderMinutes, 'Sunrise': 0},
      ));
      expect(plan.where((n) => n.title.contains('Güneş Hatırlatması')), isEmpty);
      // Ama "Güneş Doğdu" bilgilendirmesi planlanır
      expect(plan.where((n) => n.title.contains('Güneş Doğdu')), isNotEmpty);
    });
  });

  group('NotificationPlanner — Güneş istisnası', () {
    test('Güneş için ezan bildirimi planlanmaz', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(now: now));
      expect(plan.where((n) => n.title.contains('Güneş Vakti Girdi')), isEmpty);
    });

    test('Güneş bildirimi sesi kapalı (ezan okunmaz)', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(now: now));
      final sunrise = plan.firstWhere((n) => n.title.contains('Güneş Doğdu'));
      expect(sunrise.soundEnabled, isFalse);
    });
  });

  group('NotificationPlanner — vakit toleransı (offset)', () {
    test('vakitler manuel toleransa göre kayar', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(
        now: now,
        prayerOffsets: {'Dhuhr': 15},
      ));
      final dhuhr = plan.firstWhere(
        (n) => n.title.contains('Öğle') && n.title.contains('Vakti Girdi'),
      );
      expect(dhuhr.scheduledTime, DateTime(2026, 3, 15, 13, 15));
    });

    test('negatif tolerans vakdi geriye çeker', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(
        now: now,
        prayerOffsets: {'Fajr': -15},
      ));
      final fajr = plan.firstWhere(
        (n) => n.title.contains('Sabah') && n.title.contains('Vakti Girdi'),
      );
      expect(fajr.scheduledTime, DateTime(2026, 3, 15, 4, 45));
    });
  });

  group('NotificationPlanner — pencere (horizon)', () {
    List<PrayerTimes> monthDays(DateTime base) {
      return List.generate(12, (i) => dayTimes(DateTime(base.year, base.month, base.day + i)));
    }

    test('bugün + 7 gün planlanır', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(now: now, days: monthDays(now)));
      final days = plan.map((n) => DateTime(n.scheduledTime.year, n.scheduledTime.month, n.scheduledTime.day)).toSet();
      expect(days.contains(DateTime(2026, 3, 22)), isTrue); // +7
      expect(days.contains(DateTime(2026, 3, 23)), isFalse); // +8 yok
    });

    test('geçmiş günler planlanmaz', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final past = List.generate(5, (i) => dayTimes(DateTime(2026, 3, 10 + i)));
      final plan = NotificationPlanner.build(request(now: now, days: past));
      expect(plan, isEmpty);
    });

    test('özelleştirilebilir pencere', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(now: now, days: monthDays(now), horizon: 2));
      final days = plan.map((n) => DateTime(n.scheduledTime.year, n.scheduledTime.month, n.scheduledTime.day)).toSet();
      expect(days.contains(DateTime(2026, 3, 17)), isTrue);
      expect(days.contains(DateTime(2026, 3, 18)), isFalse);
    });
  });

  group('NotificationPlanner — ay sonu geçişi', () {
    test('ocak ayı için şubat vakitleri kapsama alınır', () {
      // 30 Ocak: +7 gün 6 Şubat'a taşıyor; ikinci ay eklenmezse eksik kalır.
      final now = DateTime(2026, 1, 30, 4, 0);
      final january = [dayTimes(DateTime(2026, 1, 30)), dayTimes(DateTime(2026, 1, 31))];
      final february = List.generate(7, (i) => dayTimes(DateTime(2026, 2, 1 + i)));

      final withoutNext = NotificationPlanner.build(request(now: now, days: january));
      final withNext =
          NotificationPlanner.build(request(now: now, days: [...january, ...february]));

      expect(withoutNext.length, lessThan(withNext.length),
          reason: 'sonraki ay eklenmeden pencere eksik kalır');
      expect(withNext.where((n) => n.scheduledTime.month == 2), isNotEmpty);
    });
  });

  group('NotificationPlanner — Cuma hatırlatması', () {
    test('Cuma günü öğleden 1 saat önce planlanır', () {
      // 13 Mart 2026 Cuma
      final now = DateTime(2026, 3, 13, 4, 0);
      final plan = NotificationPlanner.build(request(now: now));
      final friday = plan.firstWhere((n) => n.title.contains('Cuma Gününüz'));
      expect(friday.scheduledTime, DateTime(2026, 3, 13, 12, 0));
    });

    test('Cuma olmayan günde planlanmaz', () {
      final now = DateTime(2026, 3, 15, 4, 0); // Pazar
      final plan = NotificationPlanner.build(request(now: now));
      expect(plan.where((n) => n.title.contains('Cuma Gününüz')), isEmpty);
    });

    test('ayar kapalıyken planlanmaz', () {
      final now = DateTime(2026, 3, 13, 4, 0);
      final plan = NotificationPlanner.build(request(now: now, friday: false));
      expect(plan.where((n) => n.title.contains('Cuma Gününüz')), isEmpty);
    });
  });

  group('NotificationPlanner — Sahur hatırlatması', () {
    test('sahur açıkken imsaktan 45 dakika önce planlanır', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(now: now, sahur: true));
      final sahur = plan.firstWhere((n) => n.title.contains('Sahur'));
      expect(sahur.scheduledTime, DateTime(2026, 3, 15, 4, 15));
    });

    test('sahur kapalıyken planlanmaz', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(now: now));
      expect(plan.where((n) => n.title.contains('Sahur')), isEmpty);
    });

    test('imsak çok yakınsa geçmiş hatırlatma planlanmaz', () {
      // İmsakın 10 dakika kalmışken 45 dakikalık hatırlatma gelecekte değil.
      final now = DateTime(2026, 3, 15, 4, 30);
      final plan = NotificationPlanner.build(request(now: now, sahur: true));
      expect(plan.where((n) => n.title.contains('Sahur')), isEmpty);
    });
  });

  group('NotificationPlanner — ses tercihleri', () {
    test('ezan sesi açıkken tam vakit bildirimi sesli', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(now: now, adhanSound: true));
      final dhuhr = plan.firstWhere((n) => n.title.contains('Vakti Girdi'));
      expect(dhuhr.soundEnabled, isTrue);
      expect(dhuhr.soundKey, 'adhan_makkah');
    });

    test('ezan sesi kapalıyken tam vakit sessiz', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(now: now, adhanSound: false));
      final dhuhr = plan.firstWhere((n) => n.title.contains('Vakti Girdi'));
      expect(dhuhr.soundEnabled, isFalse);
    });

    test('ezan ve hatırlatıcı sesi ayrı ayrı uygulanır', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(
        now: now,
        adhanSound: true,
        reminderSound: false,
      ));
      final exact = plan.firstWhere((n) => n.title.contains('Vakti Girdi'));
      final reminder = plan.firstWhere((n) => n.title.contains('Hatırlatması'));
      expect(exact.soundEnabled, isTrue);
      expect(exact.soundKey, 'adhan_makkah');
      expect(reminder.soundEnabled, isFalse);
      expect(reminder.soundKey, 'beep');
    });
  });

  group('NotificationPlanner — dini gün hatırlatması', () {
    IslamicEvent eventOn(DateTime d) => IslamicEvent(
          titleTr: 'Ramazan-ı Şerif Başlangıcı',
          titleEn: 'First Day of Ramadan',
          hijri: '1 Ramazan 1448',
          dateTr: 'd.tr',
          dateEn: 'd.en',
          gregorianDate: d,
          icon: Icons.mosque,
          color: Colors.green,
        );

    test('etkinlikten 1 gün önce sabah 09:00 planlanır', () {
      final now = DateTime(2026, 1, 1, 4, 0);
      final event = eventOn(DateTime(2027, 2, 8));
      final plan = NotificationPlanner.build(request(now: now, nextEvent: event));
      final n = plan.firstWhere((p) => p.title.contains('Yarın:'));
      expect(n.scheduledTime, DateTime(2027, 2, 7, 9, 0));
    });

    test('etkinlik verilmezse hatırlatma planlanmaz', () {
      final now = DateTime(2026, 1, 1, 4, 0);
      final plan = NotificationPlanner.build(request(now: now));
      expect(plan.where((n) => n.title.contains('Yarın:')), isEmpty);
    });

    test('geçmiş etkinlik hatırlatması planlanmaz', () {
      final now = DateTime(2027, 3, 1, 4, 0);
      final event = eventOn(DateTime(2027, 2, 8));
      final plan = NotificationPlanner.build(request(now: now, nextEvent: event));
      expect(plan.where((n) => n.title.contains('Yarın:')), isEmpty);
    });
  });

  group('NotificationPlanner — çıktı bütünlüğü', () {
    test('tüm bildirimler payload alarm taşır', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(now: now));
      for (final n in plan) {
        expect(n.payload, 'alarm');
      }
    });

    test('aynı vakit için iki bildirim kimlik çakışmaz', () {
      final now = DateTime(2026, 3, 15, 4, 0);
      final plan = NotificationPlanner.build(request(now: now));
      final ids = plan.map((n) => n.id).toList();
      expect(ids.toSet().length, ids.length,
          reason: 'çakışan kimlik bir bildirimi diğerinin üstüne yazar');
    });

    test('boş gün listesi boş plan üretir (çökmez)', () {
      final plan = NotificationPlanner.build(request(
        now: DateTime(2026, 3, 15, 4, 0),
        days: [],
      ));
      expect(plan, isEmpty);
    });
  });
}