import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../models/daily_content.dart';
import '../widgets/prayer_card.dart';
import '../widgets/location_picker.dart';

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
                  ? settingsProvider.tr(nextPrayer.name.toLowerCase())
                  : settingsProvider.tr('on_time');

              return RefreshIndicator(
                onRefresh: () => prayerProvider.loadPrayerTimes(settingsProvider),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Location Bar (Overflow-safe & Responsive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.green, size: 22),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                prayerProvider.location?.city ?? settingsProvider.tr('unknown'),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Qibla Button
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => Navigator.pushNamed(context, '/qibla'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.explore_outlined, size: 16, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text(
                                      settingsProvider.tr('qibla'),
                                      style: TextStyle(
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Change Location Button
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: _showLocationPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.edit_location_alt, size: 16, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text(
                                      settingsProvider.tr('change'),
                                      style: TextStyle(
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                            colors: [Colors.green.shade900, Colors.green.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              settingsProvider.tr('next_prayer'),
                              style: TextStyle(
                                color: Colors.green.shade100,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              nextDisplayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
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
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  timeUntilNext != null
                                      ? '${settingsProvider.tr("time_remaining")}: ${_formatDuration(timeUntilNext)}'
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
