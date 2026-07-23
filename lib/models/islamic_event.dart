import 'package:flutter/material.dart';

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
    final eventDay = DateTime(gregorianDate.year, gregorianDate.month, gregorianDate.day);
    return eventDay.difference(today).inDays;
  }
}

class IslamicEventService {
  static final List<IslamicEvent> events = [
    IslamicEvent(
      titleTr: 'Miraç Kandili',
      titleEn: 'Isra and Miraj Night',
      hijri: '27 Recep 1447',
      dateTr: '15 Ocak 2026 Perşembe',
      dateEn: '15 Jan 2026 Thursday',
      gregorianDate: DateTime(2026, 1, 15),
      icon: Icons.auto_awesome,
      color: Colors.purple,
    ),
    IslamicEvent(
      titleTr: 'Berat Kandili',
      titleEn: 'Shab-e-Barat',
      hijri: '15 Şaban 1447',
      dateTr: '2 Şubat 2026 Pazartesi',
      dateEn: '2 Feb 2026 Monday',
      gregorianDate: DateTime(2026, 2, 2),
      icon: Icons.brightness_7,
      color: Colors.blue,
    ),
    IslamicEvent(
      titleTr: 'Ramazan-ı Şerif Başlangıcı',
      titleEn: 'First Day of Ramadan',
      hijri: '1 Ramazan 1447',
      dateTr: '18 Şubat 2026 Çarşamba',
      dateEn: '18 Feb 2026 Wednesday',
      gregorianDate: DateTime(2026, 2, 18),
      icon: Icons.mosque,
      color: Colors.green,
    ),
    IslamicEvent(
      titleTr: 'Kadir Gecesi',
      titleEn: 'Laylat al-Qadr',
      hijri: '27 Ramazan 1447',
      dateTr: '15 Mart 2026 Pazar',
      dateEn: '15 Mar 2026 Sunday',
      gregorianDate: DateTime(2026, 3, 15),
      icon: Icons.star,
      color: Colors.amber,
    ),
    IslamicEvent(
      titleTr: 'Ramazan Bayramı (1. Gün)',
      titleEn: 'Eid al-Fitr (Day 1)',
      hijri: '1 Şevval 1447',
      dateTr: '20 Mart 2026 Cuma',
      dateEn: '20 Mar 2026 Friday',
      gregorianDate: DateTime(2026, 3, 20),
      icon: Icons.celebration,
      color: Colors.teal,
    ),
    IslamicEvent(
      titleTr: 'Kurban Bayramı (1. Gün)',
      titleEn: 'Eid al-Adha (Day 1)',
      hijri: '10 Zilhicce 1447',
      dateTr: '27 Mayıs 2026 Çarşamba',
      dateEn: '27 May 2026 Wednesday',
      gregorianDate: DateTime(2026, 5, 27),
      icon: Icons.favorite,
      color: Colors.deepOrange,
    ),
    IslamicEvent(
      titleTr: 'Hicri Yılbaşı (1448)',
      titleEn: 'Islamic New Year (1448)',
      hijri: '1 Muharrem 1448',
      dateTr: '16 Haziran 2026 Salı',
      dateEn: '16 Jun 2026 Tuesday',
      gregorianDate: DateTime(2026, 6, 16),
      icon: Icons.update,
      color: Colors.indigo,
    ),
    IslamicEvent(
      titleTr: 'Aşure Günü',
      titleEn: 'Day of Ashura',
      hijri: '10 Muharrem 1448',
      dateTr: '25 Haziran 2026 Perşembe',
      dateEn: '25 Jun 2026 Thursday',
      gregorianDate: DateTime(2026, 6, 25),
      icon: Icons.water_drop,
      color: Colors.cyan,
    ),
    IslamicEvent(
      titleTr: 'Mevlid Kandili',
      titleEn: 'Mawlid al-Nabi',
      hijri: '12 Rebiülevvel 1448',
      dateTr: '25 Ağustos 2026 Salı',
      dateEn: '25 Aug 2026 Tuesday',
      gregorianDate: DateTime(2026, 8, 25),
      icon: Icons.stars,
      color: Colors.pink,
    ),
  ];

  static List<IslamicEvent> getUpcomingEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = events.where((e) => e.gregorianDate.isAfter(today) || e.gregorianDate.isAtSameMomentAs(today)).toList();
    if (upcoming.isEmpty) {
      return events;
    }
    return upcoming;
  }
}
