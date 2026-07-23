import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prayer_times.dart';
import '../providers/settings_provider.dart';

class PrayerCard extends StatefulWidget {
  final PrayerEntry prayer;
  final int minutesBefore;
  final bool isNext;

  const PrayerCard({
    super.key,
    required this.prayer,
    required this.minutesBefore,
    this.isNext = false,
  });

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _glowController;
  Animation<double>? _glowAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isNext) {
      _glowController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      )..repeat(reverse: true);
      _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _glowController!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void didUpdateWidget(covariant PrayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNext && _glowController == null) {
      _glowController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      )..repeat(reverse: true);
      _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _glowController!, curve: Curves.easeInOut),
      );
    } else if (!widget.isNext && _glowController != null) {
      _glowController!.dispose();
      _glowController = null;
      _glowAnimation = null;
    }
  }

  @override
  void dispose() {
    _glowController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final displayName = settingsProvider.tr(widget.prayer.name.toLowerCase());
    final String reminderText;
    if (widget.minutesBefore == 0) {
      reminderText = settingsProvider.tr('exact_time');
    } else if (widget.minutesBefore > 0) {
      reminderText = '${widget.minutesBefore} ${settingsProvider.tr("min_before")}';
    } else {
      reminderText = '${widget.minutesBefore.abs()} ${settingsProvider.tr("min_after")}';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = settingsProvider.primaryColor;

    final cardContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.isNext
                      ? primaryColor
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getPrayerIcon(widget.prayer.name),
                  color: widget.isNext
                      ? Colors.white
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight:
                              widget.isNext ? FontWeight.bold : FontWeight.w600,
                          color: widget.isNext
                              ? (isDark
                                  ? Colors.green.shade200
                                  : Colors.green.shade900)
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reminderText,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isNext
                          ? (isDark
                              ? Colors.green.shade300
                              : Colors.green.shade700)
                          : (isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.prayer.getDisplayTime(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.isNext
                          ? (isDark
                              ? Colors.green.shade300
                              : Colors.green.shade700)
                          : (isDark ? Colors.white : Colors.black87),
                    ),
              ),
              if (widget.isNext)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    settingsProvider.tr('next_prayer'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    if (widget.isNext && _glowAnimation != null) {
      return AnimatedBuilder(
        animation: _glowAnimation!,
        builder: (context, child) {
          return Card(
            elevation: 2 + (_glowAnimation!.value * 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.green.shade400
                    .withValues(alpha: 0.4 + (_glowAnimation!.value * 0.6)),
                width: 2,
              ),
            ),
            color: isDark
                ? Colors.green.shade900.withValues(alpha: 0.5)
                : Colors.green.shade50,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green
                        .withValues(alpha: 0.15 * _glowAnimation!.value),
                    blurRadius: 12 * _glowAnimation!.value,
                    spreadRadius: 2 * _glowAnimation!.value,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: cardContent,
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none,
      ),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: cardContent,
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
}
