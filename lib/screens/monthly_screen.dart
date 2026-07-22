import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../models/prayer_times.dart';
import '../services/api_service.dart';

class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  bool _isLoading = true;
  String? _error;
  List<PrayerTimes> _monthlyTimes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthlyData();
    });
  }

  Future<void> _loadMonthlyData() async {
    final prayerProvider = context.read<PrayerProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final location = prayerProvider.location;

    if (location == null) {
      setState(() {
        _isLoading = false;
        _error = settingsProvider.tr('prayer_load_error');
      });
      return;
    }

    try {
      final now = DateTime.now();
      final apiService = ApiService();
      final list = await apiService.getMonthlyPrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
        year: now.year,
        month: now.month,
        school: settingsProvider.asrSchool,
      );

      if (mounted) {
        setState(() {
          _monthlyTimes = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final prayerProvider = context.watch<PrayerProvider>();
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
                          (location?.city == 'Current Location' || location?.city == 'current_location')
                              ? settingsProvider.tr('current_location')
                              : (location?.city ?? settingsProvider.tr('unknown')),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${now.year} - ${now.month.toString().padLeft(2, '0')} (${settingsProvider.tr("monthly_times")})',
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

            // Table Column Headers
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.teal.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      settingsProvider.tr('day'),
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(settingsProvider.tr('fajr'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                  Expanded(child: Text(settingsProvider.tr('sunrise'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                  Expanded(child: Text(settingsProvider.tr('dhuhr'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                  Expanded(child: Text(settingsProvider.tr('asr'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                  Expanded(child: Text(settingsProvider.tr('maghrib'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                  Expanded(child: Text(settingsProvider.tr('isha'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 30-Day Timetable Data List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_error!, style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() => _isLoading = true);
                                  _loadMonthlyData();
                                },
                                child: Text(settingsProvider.tr('retry')),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: _monthlyTimes.length,
                          itemBuilder: (context, index) {
                            final item = _monthlyTimes[index];
                            final isToday = item.date.day == now.day && item.date.month == now.month && item.date.year == now.year;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? Colors.amber.shade800.withValues(alpha: 0.35)
                                    : (index % 2 == 0 ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03)),
                                borderRadius: BorderRadius.circular(10),
                                border: isToday ? Border.all(color: Colors.amber, width: 1.5) : null,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 32,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isToday ? Colors.amber : Colors.green.shade800.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.date.day.toString().padLeft(2, '0'),
                                        style: TextStyle(
                                          color: isToday ? Colors.black : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(item.fajrTime, style: TextStyle(color: isToday ? Colors.amber : Colors.white, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, fontSize: 12), textAlign: TextAlign.center)),
                                  Expanded(child: Text(item.sunriseTime, style: TextStyle(color: Colors.white70, fontSize: 11), textAlign: TextAlign.center)),
                                  Expanded(child: Text(item.dhuhrTime, style: TextStyle(color: isToday ? Colors.amber : Colors.white, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, fontSize: 12), textAlign: TextAlign.center)),
                                  Expanded(child: Text(item.asrTime, style: TextStyle(color: isToday ? Colors.amber : Colors.amber.shade200, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, fontSize: 12), textAlign: TextAlign.center)),
                                  Expanded(child: Text(item.maghribTime, style: TextStyle(color: isToday ? Colors.amber : Colors.white, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, fontSize: 12), textAlign: TextAlign.center)),
                                  Expanded(child: Text(item.ishaTime, style: TextStyle(color: isToday ? Colors.amber : Colors.white, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, fontSize: 12), textAlign: TextAlign.center)),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
