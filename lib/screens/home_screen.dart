import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/prayer_times.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../services/audio_service.dart';
import '../models/daily_content.dart';
import '../models/islamic_event.dart';
import '../widgets/prayer_card.dart';
import '../widgets/location_picker.dart';
import '../widgets/islamic_pattern_painter.dart';
import '../services/hijri_service.dart';
import '../widgets/animated_countdown.dart';
import '../services/widget_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late Future<void> _initializationFuture;
  Timer? _countdownTimer;
  int _widgetUpdateCounter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializationFuture = _initialize();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {});
        _updateHomeWidget();
      }
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
        // Update home widget & ongoing status notification every 30 seconds
        _widgetUpdateCounter++;
        if (_widgetUpdateCounter >= 30) {
          _widgetUpdateCounter = 0;
          _updateHomeWidget();
        }
      }
    });
  }

  String _lastOngoingTitle = '';
  String _lastOngoingBody = '';

  String _formatOngoingDuration(Duration duration, bool isEn) {
    if (duration.isNegative) return '00:00';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours ${isEn ? 'h' : 'sa'} ${minutes.toString().padLeft(2, '0')} ${isEn ? 'm' : 'dk'}';
    } else {
      return '$minutes ${isEn ? 'm' : 'dk'}';
    }
  }

  void _updateHomeWidget() {
    try {
      final prayerProvider = context.read<PrayerProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      final nextPrayer = prayerProvider.getNextPrayer();
      final timeUntilNext = prayerProvider.getTimeUntilNextPrayer();

      if (nextPrayer != null) {
        final displayName = settingsProvider.tr(nextPrayer.name.toLowerCase());
        final isEn = settingsProvider.appLanguage == 'en';
        final countdownStr = timeUntilNext != null ? _formatDuration(timeUntilNext) : '--:--:--';
        final ongoingCountdownStr = timeUntilNext != null ? _formatOngoingDuration(timeUntilNext, isEn) : '--:--';

        WidgetService.updateWidget(
          prayerName: displayName,
          prayerTime: nextPrayer.getDisplayTime(),
          countdown: countdownStr,
          appTitle: settingsProvider.tr('app_title'),
        );

        if (settingsProvider.ongoingNotificationEnabled) {
          String rawCity = prayerProvider.location?.city ?? '';
          if (rawCity == 'Current Location' || rawCity == 'current_location' || rawCity == 'Mevcut Konum') {
            rawCity = settingsProvider.tr('current_location');
          }
          final citySuffix = rawCity.isNotEmpty ? ' | 📍 $rawCity' : '';

          final title = isEn
              ? '🕌 Next Prayer: $displayName (${nextPrayer.getDisplayTime()})'
              : '🕌 Sıradaki Vakit: $displayName (${nextPrayer.getDisplayTime()})';
          final body = isEn
              ? '⏳ $ongoingCountdownStr remaining$citySuffix'
              : '⏳ $ongoingCountdownStr kaldı$citySuffix';

          if (title != _lastOngoingTitle || body != _lastOngoingBody) {
            _lastOngoingTitle = title;
            _lastOngoingBody = body;
            NotificationService().showOngoingNotification(
              title: title,
              body: body,
            );
          }
        } else {
          if (_lastOngoingTitle.isNotEmpty || _lastOngoingBody.isNotEmpty) {
            _lastOngoingTitle = '';
            _lastOngoingBody = '';
            NotificationService().cancelOngoingNotification();
          }
        }
      }
    } catch (_) {}
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

  void _showCalendarModal(BuildContext context, SettingsProvider settingsProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = settingsProvider.primaryColor;
    final isEn = settingsProvider.appLanguage == 'en';
    final now = DateTime.now();

    final upcomingEvents = IslamicEventService.getUpcomingEvents().take(3).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162218) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.calendar_month_rounded, color: primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settingsProvider.tr('calendar_dialog_title'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        settingsProvider.tr('calendar_dialog_desc'),
                        style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date Cards Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.today, color: Colors.blue, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            isEn ? 'Gregorian Date' : 'Miladi Tarih',
                            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            HijriService.getGregorianDate(now, settingsProvider.appLanguage),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade400),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.brightness_3, color: Colors.amber, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            isEn ? 'Hijri Date' : 'Hicri Tarih',
                            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            HijriService.getHijriDate(now, settingsProvider.appLanguage),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Upcoming Islamic Events Preview
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isEn ? 'Upcoming Islamic Holidays 🕌' : 'Yaklaşan Dini Günler & Kandiller 🕌',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(height: 8),

              ...upcomingEvents.map((event) {
                final daysLeft = event.daysRemaining;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: isDark ? const Color(0xFF1F2B21) : Colors.green.shade50.withValues(alpha: 0.5),
                  child: ListTile(
                    dense: true,
                    leading: Icon(event.icon, color: event.color, size: 20),
                    title: Text(event.getTitle(isEn), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(event.getDate(isEn), style: const TextStyle(fontSize: 11)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: daysLeft <= 10 ? Colors.red.shade700 : primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        daysLeft == 0
                            ? (isEn ? 'TODAY' : 'BUGÜN')
                            : (isEn ? '$daysLeft days left' : '$daysLeft gün kaldı'),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/monthly');
                      },
                      icon: const Icon(Icons.calendar_month, size: 16),
                      label: Text(settingsProvider.tr('monthly_times')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/calendar');
                      },
                      icon: const Icon(Icons.event, size: 16),
                      label: Text(isEn ? 'Events' : 'Dini Günler'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
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
    final primaryColor = settingsProvider.primaryColor;

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
                    color: Colors.white.withValues(alpha: 0.8),
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
        backgroundColor: isDark ? const Color(0xFF0F1A11) : primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(
                color: primaryColor,
                isDark: isDark,
              ),
            ),
          ),
          FutureBuilder(
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
                      // Date Banner (Gregorian & Hijri Calendar - Interactive Button)
                      InkWell(
                        onTap: () => _showCalendarModal(context, settingsProvider),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF142217) : primaryColor.withValues(alpha: 0.95),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month, color: Colors.amber, size: 18),
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
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                                  const SizedBox(width: 4),
                                  const Icon(Icons.touch_app, color: Colors.amber, size: 14),
                                ],
                              ),
                            ],
                          ),
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
                            Icon(Icons.location_on, color: primaryColor, size: 22),
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
                                  color: isDark ? primaryColor.withValues(alpha: 0.3) : primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_location_alt, size: 16, color: isDark ? Colors.white : primaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      settingsProvider.tr('change'),
                                      style: TextStyle(
                                        color: isDark ? Colors.white : primaryColor,
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

                      // Single-Row 5-Item Compact Quick Action Bar (Ultra-efficient 70px height)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF18241B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCompactQuickAction(
                              context: context,
                              icon: Icons.explore_rounded,
                              label: settingsProvider.tr('qibla'),
                              color: Colors.green,
                              route: '/qibla',
                              isDark: isDark,
                            ),
                            _buildCompactQuickAction(
                              context: context,
                              icon: Icons.touch_app_rounded,
                              label: settingsProvider.appLanguage == 'en' ? 'Dhikr' : 'Zikirmatik',
                              color: Colors.teal,
                              route: '/dhikr',
                              isDark: isDark,
                            ),
                            _buildCompactQuickAction(
                              context: context,
                              icon: Icons.calendar_month_rounded,
                              label: settingsProvider.appLanguage == 'en' ? 'Events' : 'Dini Günler',
                              color: Colors.amber,
                              route: '/calendar',
                              isDark: isDark,
                            ),
                            _buildCompactQuickAction(
                              context: context,
                              icon: Icons.calendar_today_rounded,
                              label: settingsProvider.tr('monthly_times'),
                              color: Colors.blue,
                              route: '/monthly',
                              isDark: isDark,
                            ),
                            _buildCompactQuickAction(
                              context: context,
                              icon: Icons.menu_book_rounded,
                              label: settingsProvider.appLanguage == 'en' ? 'Duas' : 'Dualar',
                              color: Colors.purple,
                              route: '/duas',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),

                      // Next Prayer Live Countdown Banner
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF0F2617), const Color(0xFF143B22)]
                                : [primaryColor, settingsProvider.secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.alarm_on_rounded, size: 14, color: Colors.amberAccent),
                                      const SizedBox(width: 4),
                                      Text(
                                        settingsProvider.tr('next_prayer'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (settingsProvider.prayerTimeOffsets.values.any((v) => v != 0))
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.amber.shade300, width: 0.8),
                                    ),
                                    child: const Text(
                                      '⏱️ Offset',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              nextDisplayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (nextPrayer != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                nextPrayer.getDisplayTime(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: timeUntilNext != null
                                    ? AnimatedCountdown(
                                        timeString: _formatDuration(timeUntilNext),
                                      )
                                    : const Text(
                                        '--:--:--',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 14),
                              // Live Prayer Interval Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: prayerProvider.getPrayerProgress(),
                                  minHeight: 5,
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
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

                      // Prayer times list header (with View Mode Toggle: Card View vs Compact Grid)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_filled, size: 20, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      settingsProvider.tr('todays_prayers'),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Toggle View Mode Button
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () async {
                                final newMode = settingsProvider.prayerTimesViewMode == 'compact'
                                    ? 'standard'
                                    : 'compact';
                                await settingsProvider.setPrayerTimesViewMode(newMode);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? primaryColor.withValues(alpha: 0.25)
                                      : primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      settingsProvider.prayerTimesViewMode == 'compact'
                                          ? Icons.view_agenda_outlined
                                          : Icons.grid_view_rounded,
                                      size: 15,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      settingsProvider.prayerTimesViewMode == 'compact'
                                          ? settingsProvider.tr('view_standard')
                                          : settingsProvider.tr('view_compact'),
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (settingsProvider.prayerTimesViewMode == 'compact')
                        _buildCompactPrayerGrid(prayers, nextPrayer, settingsProvider, primaryColor, isDark)
                      else
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
    ],
  ),
      floatingActionButton: ListenableBuilder(
        listenable: AudioService(),
        builder: (context, _) {
          if (!AudioService().isPlaying) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              AudioService().stop();
            },
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            elevation: 6,
            icon: const Icon(Icons.volume_off_rounded),
            label: Text(
              settingsProvider.tr('stop_audio'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required MaterialColor color,
    required String route,
    required bool isDark,
  }) {
    final bgCircle = isDark
        ? color.withValues(alpha: 0.25)
        : color.shade100;
    final iconColor = isDark ? color.shade200 : color.shade800;
    final textColor = isDark ? Colors.grey.shade300 : Colors.grey.shade800;

    return Expanded(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgCircle,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: isDark ? 0.4 : 0.3),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: isDark ? 0.2 : 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return Icons.dark_mode_outlined;
      case 'sunrise':
        return Icons.wb_sunny_outlined;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.wb_twilight;
      case 'maghrib':
        return Icons.nightlight_round;
      case 'isha':
        return Icons.nights_stay;
      default:
        return Icons.access_time_filled;
    }
  }

  Widget _buildCompactPrayerGrid(
    List<PrayerEntry> prayers,
    PrayerEntry? nextPrayer,
    SettingsProvider settingsProvider,
    Color primaryColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF142016) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: prayers.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.15,
        ),
        itemBuilder: (context, index) {
          final prayer = prayers[index];
          final isNext = prayer.name == nextPrayer?.name;
          final displayName = settingsProvider.tr(prayer.name.toLowerCase());
          final iconData = _getPrayerIcon(prayer.name);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isNext
                  ? LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E3A27), const Color(0xFF0F2D1C)]
                          : [primaryColor.withValues(alpha: 0.9), primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isNext
                  ? null
                  : (isDark ? const Color(0xFF1F2E22) : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isNext
                    ? Colors.amber.shade400
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade300),
                width: isNext ? 1.8 : 1.0,
              ),
              boxShadow: isNext
                  ? [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData,
                  size: 20,
                  color: isNext
                      ? Colors.amber.shade300
                      : (isDark ? Colors.amber.shade400 : primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                    color: isNext
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  prayer.getDisplayTime(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isNext
                        ? Colors.amber.shade200
                        : (isDark ? Colors.white : primaryColor),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
