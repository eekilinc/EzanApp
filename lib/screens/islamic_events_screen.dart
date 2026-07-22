import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class IslamicEventsScreen extends StatelessWidget {
  const IslamicEventsScreen({super.key});

  static final List<Map<String, dynamic>> _events2026 = [
    {
      'title_tr': 'Üç Ayların Başlangıcı',
      'title_en': 'Beginning of Sacred Three Months',
      'hijri': '1 Recep 1447',
      'date_tr': '20 Aralık 2025 Cumartesi',
      'date_en': '20 Dec 2025 Saturday',
      'gregorian_date': DateTime(2025, 12, 20),
      'icon': Icons.brightness_3,
      'color': Colors.indigo,
    },
    {
      'title_tr': 'Regaip Kandili',
      'title_en': 'Regaip Night (Ragaib)',
      'hijri': '6 Recep 1447',
      'date_tr': '25 Aralık 2025 Perşembe',
      'date_en': '25 Dec 2025 Thursday',
      'gregorian_date': DateTime(2025, 12, 25),
      'icon': Icons.star,
      'color': Colors.amber,
    },
    {
      'title_tr': 'Miraç Kandili',
      'title_en': 'Isra and Miraj Night',
      'hijri': '27 Recep 1447',
      'date_tr': '15 Ocak 2026 Perşembe',
      'date_en': '15 Jan 2026 Thursday',
      'gregorian_date': DateTime(2026, 1, 15),
      'icon': Icons.auto_awesome,
      'color': Colors.purple,
    },
    {
      'title_tr': 'Berat Kandili',
      'title_en': 'Shab-e-Barat (Nisfu Sya\'ban)',
      'hijri': '15 Şaban 1447',
      'date_tr': '2 Şubat 2026 Pazartesi',
      'date_en': '2 Feb 2026 Monday',
      'gregorian_date': DateTime(2026, 2, 2),
      'icon': Icons.brightness_7,
      'color': Colors.blue,
    },
    {
      'title_tr': 'Ramazan-ı Şerif Başlangıcı',
      'title_en': 'First Day of Ramadan',
      'hijri': '1 Ramazan 1447',
      'date_tr': '18 Şubat 2026 Çarşamba',
      'date_en': '18 Feb 2026 Wednesday',
      'gregorian_date': DateTime(2026, 2, 18),
      'icon': Icons.mosque,
      'color': Colors.green,
    },
    {
      'title_tr': 'Kadir Gecesi',
      'title_en': 'Laylat al-Qadr (Night of Power)',
      'hijri': '27 Ramazan 1447',
      'date_tr': '15 Mart 2026 Pazar',
      'date_en': '15 Mar 2026 Sunday',
      'gregorian_date': DateTime(2026, 3, 15),
      'icon': Icons.wb_twilight,
      'color': Colors.orange,
    },
    {
      'title_tr': 'Ramazan Bayramı (1. Gün)',
      'title_en': 'Eid al-Fitr (Day 1)',
      'hijri': '1 Şevval 1447',
      'date_tr': '20 Mart 2026 Cuma',
      'date_en': '20 Mar 2026 Friday',
      'gregorian_date': DateTime(2026, 3, 20),
      'icon': Icons.celebration,
      'color': Colors.teal,
    },
    {
      'title_tr': 'Kurban Bayramı (1. Gün)',
      'title_en': 'Eid al-Adha (Day 1)',
      'hijri': '10 Zilhicce 1447',
      'date_tr': '27 Mayıs 2026 Çarşamba',
      'date_en': '27 May 2026 Wednesday',
      'gregorian_date': DateTime(2026, 5, 27),
      'icon': Icons.card_giftcard,
      'color': Colors.deepOrange,
    },
    {
      'title_tr': 'Hicri Yılbaşı (1448)',
      'title_en': 'Islamic New Year (1448 AH)',
      'hijri': '1 Muharrem 1448',
      'date_tr': '16 Haziran 2026 Salı',
      'date_en': '16 Jun 2026 Tuesday',
      'gregorian_date': DateTime(2026, 6, 16),
      'icon': Icons.calendar_month,
      'color': Colors.cyan,
    },
    {
      'title_tr': 'Aşure Günü',
      'title_en': 'Day of Ashura',
      'hijri': '10 Muharrem 1448',
      'date_tr': '25 Haziran 2026 Perşembe',
      'date_en': '25 Jun 2026 Thursday',
      'gregorian_date': DateTime(2026, 6, 25),
      'icon': Icons.water_drop,
      'color': Colors.lightBlue,
    },
    {
      'title_tr': 'Mevlid Kandili',
      'title_en': 'Mawlid an-Nabi (Prophet\'s Birthday)',
      'hijri': '12 Rebiülevvel 1448',
      'date_tr': '24 Ağustos 2026 Pazartesi',
      'date_en': '24 Aug 2026 Monday',
      'gregorian_date': DateTime(2026, 8, 24),
      'icon': Icons.favorite,
      'color': Colors.pink,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isEn = settingsProvider.appLanguage == 'en';
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEn ? 'Islamic Calendar & Events 📅' : 'Dini Günler & Kandiller 📅'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade900,
              Colors.green.shade900,
              const Color(0xFF0F1210),
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _events2026.length,
          itemBuilder: (context, index) {
            final event = _events2026[index];
            final title = isEn ? event['title_en'] : event['title_tr'];
            final dateStr = isEn ? event['date_en'] : event['date_tr'];
            final eventDate = event['gregorian_date'] as DateTime;
            final daysDiff = eventDate.difference(now).inDays;

            final isPast = daysDiff < 0;
            final isToday = daysDiff == 0;

            String statusLabel;
            if (isToday) {
              statusLabel = isEn ? 'TODAY 🎉' : 'BUGÜN 🎉';
            } else if (isPast) {
              statusLabel = isEn ? 'Passed' : 'Geçti';
            } else {
              statusLabel = isEn ? '$daysDiff days left' : '$daysDiff gün kaldı';
            }

            final iconColor = event['color'] as Color;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: isToday ? 4 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isToday
                      ? Colors.amber
                      : (isPast ? Colors.transparent : Colors.teal.shade300.withValues(alpha: 0.4)),
                  width: isToday ? 2 : 1,
                ),
              ),
              color: isPast
                  ? Colors.black.withValues(alpha: 0.3)
                  : (isToday ? Colors.teal.shade800 : Colors.white.withValues(alpha: 0.12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: isPast ? Colors.grey.shade800 : iconColor.withValues(alpha: 0.25),
                  child: Icon(
                    event['icon'] as IconData,
                    color: isPast ? Colors.grey : (isToday ? Colors.amber : iconColor),
                    size: 26,
                  ),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isPast ? Colors.grey.shade400 : Colors.white,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 13,
                          color: isPast ? Colors.grey.shade500 : Colors.amber.shade200,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event['hijri'] as String,
                        style: const TextStyle(fontSize: 11, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.amber
                        : (isPast
                            ? Colors.white10
                            : Colors.teal.shade600.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.black : (isPast ? Colors.grey : Colors.white),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
