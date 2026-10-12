import 'package:flutter/material.dart';
import '../services/hijri_service.dart';

class IslamicEvent {
  final String titleTr;
  final String titleEn;
  final String hijri;
  final String dateTr;
  final String dateEn;
  final DateTime gregorianDate;
  final IconData icon;
  final Color color;

  IslamicEvent({
    required this.titleTr,
    required this.titleEn,
    required this.hijri,
    required this.dateTr,
    required this.dateEn,
    required this.gregorianDate,
    required this.icon,
    required this.color,
  });

  String getTitle(bool isEn) => isEn ? titleEn : titleTr;
  String getDate(bool isEn) => isEn ? dateEn : dateTr;

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(
      gregorianDate.year,
      gregorianDate.month,
      gregorianDate.day,
    );
    return eventDay.difference(today).inDays;
  }
}

/// Bir dini günün tanımı: adımlar + hicri ay/günü.
///
/// Gregorian tarihi **sabit yazılmaz**; her çağrıda
/// [HijriService.toHijri] ile "sıradaki oluşumu" bulunur. Böylece liste
/// hiçbir zaman elle güncelleme gerektirmez ve yıl sonunda boşalmaz.
class _EventDefinition {
  final String titleTr;
  final String titleEn;
  final int hijriMonth; // 1 = Muharrem ... 12 = Zilhicce
  final int hijriDay;

  /// Hicri yıl başlığa yansıtılacaksa (ör. "Hicri Yılbaşı (1449)").
  final bool includeHijriYearInTitle;

  final IconData icon;
  final Color color;

  const _EventDefinition({
    required this.titleTr,
    required this.titleEn,
    required this.hijriMonth,
    required this.hijriDay,
    this.includeHijriYearInTitle = false,
    required this.icon,
    required this.color,
  });
}

class IslamicEventService {
  static const List<_EventDefinition> _definitions = [
    _EventDefinition(
      titleTr: 'Aşure Günü',
      titleEn: 'Day of Ashura',
      hijriMonth: 1,
      hijriDay: 10,
      icon: Icons.water_drop,
      color: Colors.cyan,
    ),
    _EventDefinition(
      titleTr: 'Mevlid Kandili',
      titleEn: 'Mawlid al-Nabi',
      hijriMonth: 3,
      hijriDay: 12,
      icon: Icons.stars,
      color: Colors.pink,
    ),
    _EventDefinition(
      titleTr: 'Hicri Yılbaşı',
      titleEn: 'Islamic New Year',
      hijriMonth: 1,
      hijriDay: 1,
      includeHijriYearInTitle: true,
      icon: Icons.update,
      color: Colors.indigo,
    ),
    _EventDefinition(
      titleTr: 'Miraç Kandili',
      titleEn: 'Isra and Miraj Night',
      hijriMonth: 7,
      hijriDay: 27,
      icon: Icons.auto_awesome,
      color: Colors.purple,
    ),
    _EventDefinition(
      titleTr: 'Berat Kandili',
      titleEn: 'Shab-e-Barat',
      hijriMonth: 8,
      hijriDay: 15,
      icon: Icons.brightness_7,
      color: Colors.blue,
    ),
    _EventDefinition(
      titleTr: 'Ramazan-ı Şerif Başlangıcı',
      titleEn: 'First Day of Ramadan',
      hijriMonth: 9,
      hijriDay: 1,
      icon: Icons.mosque,
      color: Colors.green,
    ),
    _EventDefinition(
      titleTr: 'Kadir Gecesi',
      titleEn: 'Laylat al-Qadr',
      hijriMonth: 9,
      hijriDay: 27,
      icon: Icons.star,
      color: Colors.amber,
    ),
    _EventDefinition(
      titleTr: 'Ramazan Bayramı (1. Gün)',
      titleEn: 'Eid al-Fitr (Day 1)',
      hijriMonth: 10,
      hijriDay: 1,
      icon: Icons.celebration,
      color: Colors.teal,
    ),
    _EventDefinition(
      titleTr: 'Kurban Bayramı (1. Gün)',
      titleEn: 'Eid al-Adha (Day 1)',
      hijriMonth: 12,
      hijriDay: 10,
      icon: Icons.favorite,
      color: Colors.deepOrange,
    ),
  ];

  /// [reference] tarihinden itibaren sıradaki oluşumları hesaplanmış,
  /// tarih sırasına dizilmiş tüm dini günler.
  ///
  /// [reference] testler ve önizleme için verilebilir; verilmezse bugün.
  static List<IslamicEvent> events({DateTime? reference}) {
    final ref = reference ?? DateTime.now();
    final list = _definitions.map((d) => _resolve(d, ref)).toList();
    list.sort((a, b) => a.gregorianDate.compareTo(b.gregorianDate));
    return list;
  }

  static List<IslamicEvent> getUpcomingEvents({DateTime? reference}) {
    final ref = reference ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    return events(
      reference: ref,
    ).where((e) => !e.gregorianDate.isBefore(today)).toList();
  }

  /// Hatırlatma için sıradaki etkinlik (bugün dahil), yoksa null.
  static IslamicEvent? getNextEvent({DateTime? reference}) {
    final upcoming = getUpcomingEvents(reference: reference);
    return upcoming.isEmpty ? null : upcoming.first;
  }

  /// Tanımın [reference] tarihinden sonraki ilk oluşumunu bulur.
  static IslamicEvent _resolve(_EventDefinition d, DateTime reference) {
    final start = DateTime(reference.year, reference.month, reference.day);
    var candidate = start;
    var hijriYear = 0;

    // Bir hicri yıl ~354 gün. 380 gün tüm tanımları kapsar: Zilhicce 10'da
    // aranan bir gün, en kötü durumda 1 Muharrem'e denk gelir.
    for (var i = 0; i <= 380; i++) {
      candidate = DateTime(start.year, start.month, start.day + i);
      final h = HijriService.toHijri(candidate);
      if (h.month == d.hijriMonth && h.day == d.hijriDay) {
        hijriYear = h.year;
        break;
      }
    }

    // Tarihi doğrudan o güne bırakmak yerine hicri yıl + ay + günden
    // geri hesapla; iki yol aynı güne düşer ama bu, "tanım = hicri gün"
    // sözleşmesini tek yerde tutar.
    final gregorian = HijriService.hijriToGregorian(
      hijriYear,
      d.hijriMonth,
      d.hijriDay,
    );

    final titleTr = d.includeHijriYearInTitle
        ? '${d.titleTr} ($hijriYear)'
        : d.titleTr;
    final titleEn = d.includeHijriYearInTitle
        ? '${d.titleEn} ($hijriYear)'
        : d.titleEn;

    return IslamicEvent(
      titleTr: titleTr,
      titleEn: titleEn,
      hijri:
          '${d.hijriDay} ${HijriService.hijriMonthsTr[d.hijriMonth - 1]} $hijriYear',
      dateTr: HijriService.getGregorianDate(gregorian, 'tr'),
      dateEn: HijriService.getGregorianDate(gregorian, 'en'),
      gregorianDate: gregorian,
      icon: d.icon,
      color: d.color,
    );
  }
}
