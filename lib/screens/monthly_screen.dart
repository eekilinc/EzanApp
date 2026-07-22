import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';

class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final prayerProvider = context.watch<PrayerProvider>();
    final prayerTimes = prayerProvider.prayerTimes;
    final location = prayerProvider.location;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(settingsProvider.tr('monthly_title')),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade900,
              Colors.teal.shade900,
              const Color(0xFF0F1210),
            ],
          ),
        ),
        child: Column(
          children: [
            // City Header Card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_city, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location?.city ?? settingsProvider.tr('unknown'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${now.year} - ${now.month.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      settingsProvider.asrSchool == 'hanafi' ? 'Hanefî' : 'Standart',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.teal.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(settingsProvider.tr('fajr'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                  Expanded(flex: 2, child: Text(settingsProvider.tr('sunrise'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                  Expanded(flex: 2, child: Text(settingsProvider.tr('dhuhr'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                  Expanded(flex: 2, child: Text(settingsProvider.tr('asr'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                  Expanded(flex: 2, child: Text(settingsProvider.tr('maghrib'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                  Expanded(flex: 2, child: Text(settingsProvider.tr('isha'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Timetable Data List
            Expanded(
              child: prayerTimes == null
                  ? Center(child: Text(settingsProvider.tr('prayer_load_error'), style: const TextStyle(color: Colors.white70)))
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.amber, width: 2),
                          ),
                          color: Colors.amber.shade900.withValues(alpha: 0.3),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text(prayerTimes.fajrTime, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                Expanded(flex: 2, child: Text(prayerTimes.sunriseTime, style: const TextStyle(color: Colors.white70))),
                                Expanded(flex: 2, child: Text(prayerTimes.dhuhrTime, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                Expanded(flex: 2, child: Text(prayerTimes.asrTime, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
                                Expanded(flex: 2, child: Text(prayerTimes.maghribTime, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                Expanded(flex: 2, child: Text(prayerTimes.ishaTime, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
