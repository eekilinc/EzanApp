import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../models/daily_content.dart';
import '../widgets/prayer_card.dart';
import '../widgets/location_picker.dart';
import '../constants/reminders.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _initializationFuture;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initialize();
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    final prayerProvider =
        Provider.of<PrayerProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    await settingsProvider.init();
    await prayerProvider.initializeLocation(settingsProvider);
  }

  void _showLocationPicker() {
    final settingsProvider = context.read<SettingsProvider>();
    showModalBottomSheet(
      context: context,
      builder: (context) => LocationPicker(
        cities: context.read<PrayerProvider>().getCityList(),
        onCitySelected: (city) {
          context.read<PrayerProvider>().selectCity(city, settingsProvider);
        },
        onUseGpsPressed: () {
          context.read<PrayerProvider>().useGpsLocation(settingsProvider);
          Navigator.pop(context);
        },
      ),
      isScrollControlled: true,
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final todayContent = DailyContent.getTodayContent();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.mosque, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Ezan Hatırlatıcı',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            tooltip: 'Kıble Pusulası',
            onPressed: () => Navigator.pushNamed(context, '/qibla'),
          ),
        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Consumer2<PrayerProvider, SettingsProvider>(
            builder: (context, prayerProvider, settingsProvider, _) {
              if (prayerProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (prayerProvider.error != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Hata: ${prayerProvider.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => prayerProvider.loadPrayerTimes(settingsProvider),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (prayerProvider.prayerTimes == null) {
                return const Center(
                  child: Text('Namaz saatleri yüklenemedi'),
                );
              }

              final prayers = prayerProvider.prayerTimes!.getPrayerList();
              final nextPrayer = prayerProvider.getNextPrayer();
              final timeUntilNext = prayerProvider.getTimeUntilNextPrayer();
              final nextDisplayName = nextPrayer != null
                  ? (prayerDisplayNames[nextPrayer.name] ?? nextPrayer.name)
                  : 'Günün vakitleri tamamlandı';

              return RefreshIndicator(
                onRefresh: () => prayerProvider.loadPrayerTimes(settingsProvider),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Location Bar
                      Container(
                        color: Colors.green.shade50,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                prayerProvider.location?.city ?? 'Bilinmiyor',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade900,
                                    ),
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.explore_outlined, size: 18),
                              label: const Text('Kıble'),
                              style: TextButton.styleFrom(foregroundColor: Colors.green.shade800),
                              onPressed: () => Navigator.pushNamed(context, '/qibla'),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.edit_location_alt, size: 18),
                              label: const Text('Değiştir'),
                              style: TextButton.styleFrom(foregroundColor: Colors.green.shade800),
                              onPressed: _showLocationPicker,
                            ),
                          ],
                        ),
                      ),

                      // Next prayer countdown card
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade800, Colors.green.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'SONRAKİ VAKİT',
                              style: TextStyle(
                                color: Colors.green.shade100,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              nextDisplayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (nextPrayer != null) ...[
                              Text(
                                nextPrayer.getDisplayTime(),
                                style: TextStyle(
                                  color: Colors.green.shade100,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  timeUntilNext != null
                                      ? 'Kalan Süre: ${_formatDuration(timeUntilNext)}'
                                      : '--:--:--',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),

                      // Daily Verse / Hadith Card
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.format_quote, color: Colors.amber.shade900, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  todayContent.type,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '"${todayContent.text}"',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade900,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '— ${todayContent.source}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Prayer times list header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Bugünün Namaz Saatleri',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      ...prayers.map((prayer) {
                        final minutes = settingsProvider.getReminderMinutes(
                          prayer.name,
                        );
                        return PrayerCard(
                          prayer: prayer,
                          minutesBefore: minutes,
                          isNext: prayer.name == nextPrayer?.name,
                        );
                      }),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/settings');
        },
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.settings),
        label: const Text('Ayarlar'),
      ),
    );
  }
}
