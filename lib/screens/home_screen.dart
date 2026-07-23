import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../services/audio_service.dart';
import '../models/daily_content.dart';
import '../widgets/prayer_card.dart';
import '../widgets/location_picker.dart';
import '../services/hijri_service.dart';

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
      backgroundColor: Colors.transparent,
      isDismissible: true,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber.shade300, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.mosque_rounded, color: Colors.amber, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  settingsProvider.tr('app_title'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'Namaz Vakitleri & İslami Yardımcı 🕌',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green.shade100,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: settingsProvider.tr('settings'),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          const SizedBox(width: 4),
        ],
        elevation: 2,
        shadowColor: Colors.black38,
        backgroundColor: isDark ? const Color(0xFF0F1A11) : Colors.green.shade800,
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
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          prayerProvider.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => prayerProvider.loadPrayerTimes(settingsProvider),
                          icon: const Icon(Icons.refresh),
                          label: Text(settingsProvider.tr('retry')),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (prayerProvider.prayerTimes == null) {
                return Center(
                  child: Text(settingsProvider.tr('prayer_load_error')),
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
                      // Date Banner (Gregorian & Hijri Calendar)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF142217) : Colors.green.shade900,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_month, color: Colors.amber, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  HijriService.getGregorianDate(DateTime.now(), settingsProvider.appLanguage),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade700,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                HijriService.getHijriDate(DateTime.now(), settingsProvider.appLanguage),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Location Bar (Overflow-safe & Responsive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
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
                                (prayerProvider.location?.city == 'Current Location' ||
                                        prayerProvider.location?.city == 'current_location')
                                    ? settingsProvider.tr('current_location')
                                    : (prayerProvider.location?.city ?? settingsProvider.tr('unknown')),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Change Location Button
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: _showLocationPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.green.shade900.withValues(alpha: 0.4) : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? Colors.green.shade700 : Colors.green.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_location_alt, size: 16, color: isDark ? Colors.green.shade300 : Colors.green.shade800),
                                    const SizedBox(width: 4),
                                    Text(
                                      settingsProvider.tr('change'),
                                      style: TextStyle(
                                        color: isDark ? Colors.green.shade200 : Colors.green.shade900,
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

                      // Quick Action Bar (2x2 Grid with Dark/Light Mode Adaptability)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickTile(
                                    context: context,
                                    icon: Icons.explore_rounded,
                                    label: settingsProvider.tr('qibla'),
                                    color: Colors.green,
                                    route: '/qibla',
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildQuickTile(
                                    context: context,
                                    icon: Icons.touch_app_rounded,
                                    label: settingsProvider.appLanguage == 'en' ? 'Dhikr 📿' : 'Zikirmatik 📿',
                                    color: Colors.teal,
                                    route: '/dhikr',
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickTile(
                                    context: context,
                                    icon: Icons.calendar_month_rounded,
                                    label: settingsProvider.appLanguage == 'en' ? 'Events 📅' : 'Dini Günler 📅',
                                    color: Colors.amber,
                                    route: '/calendar',
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildQuickTile(
                                    context: context,
                                    icon: Icons.calendar_today_rounded,
                                    label: settingsProvider.tr('monthly_times'),
                                    color: Colors.blue,
                                    route: '/monthly',
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Next Prayer Live Countdown Banner
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF0F2617), const Color(0xFF143B22)]
                                : [Colors.green.shade900, Colors.green.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: isDark ? 0.2 : 0.35),
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
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Daily Verse / Hadith Card (Theme Adaptive)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF262014) : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.amber.shade700.withValues(alpha: 0.5) : Colors.amber.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.format_quote, color: isDark ? Colors.amber.shade300 : Colors.amber.shade900, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      todayContent.type,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy, size: 18, color: isDark ? Colors.amber.shade300 : Colors.amber.shade900),
                                  tooltip: settingsProvider.appLanguage == 'en' ? 'Copy Text' : 'Metni Kopyala',
                                  onPressed: () {
                                    final shareText = '"${todayContent.text}" — ${todayContent.source}';
                                    Clipboard.setData(ClipboardData(text: shareText));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(settingsProvider.appLanguage == 'en'
                                            ? 'Text copied to clipboard! 📋'
                                            : 'Ayet/Hadis metni panoya kopyalandı! 📋'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '"${todayContent.text}"',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: isDark ? Colors.amber.shade50 : Colors.grey.shade900,
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
                                  color: isDark ? Colors.amber.shade200 : Colors.grey.shade700,
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
                              settingsProvider.tr('todays_prayers'),
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
          if (AudioService().isPlaying) {
            AudioService().stop();
            setState(() {});
          } else {
            Navigator.pushNamed(context, '/settings');
          }
        },
        backgroundColor: AudioService().isPlaying ? Colors.red.shade700 : Colors.green.shade700,
        foregroundColor: Colors.white,
        icon: Icon(AudioService().isPlaying ? Icons.stop_circle : Icons.settings),
        label: Text(AudioService().isPlaying
            ? context.watch<SettingsProvider>().tr('stop_audio')
            : context.watch<SettingsProvider>().tr('settings')),
      ),
    );
  }

  Widget _buildQuickTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required MaterialColor color,
    required String route,
    required bool isDark,
  }) {
    final tileBg = isDark
        ? Color.alphaBlend(color.withValues(alpha: 0.15), const Color(0xFF1C271E))
        : color.shade50;
    final borderColor = isDark
        ? color.withValues(alpha: 0.3)
        : color.shade200;
    final iconColor = isDark ? color.shade300 : color.shade700;
    final textColor = isDark ? Colors.white : color.shade900;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
