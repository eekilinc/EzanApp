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
    final offset = settingsProvider.getPrayerTimeOffset(widget.prayer.name);

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
                      : (isDark ? Colors.white.withValues(alpha: 0.08) : primaryColor.withValues(alpha: 0.08)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getPrayerIcon(widget.prayer.name),
                  color: widget.isNext
                      ? Colors.white
                      : (isDark ? Colors.grey.shade300 : primaryColor),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: widget.isNext ? FontWeight.bold : FontWeight.w600,
                              color: widget.isNext
                                  ? (isDark ? Colors.white : primaryColor)
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                      ),
                      if (offset != 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: (offset > 0 ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${offset > 0 ? '+' : ''}$offset m',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: offset > 0 ? (isDark ? Colors.greenAccent : Colors.green.shade800) : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reminderText,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isNext
                          ? (isDark ? Colors.white70 : primaryColor.withValues(alpha: 0.8))
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
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
                          ? (isDark ? Colors.white : primaryColor)
                          : (isDark ? Colors.white : Colors.black87),
                    ),
              ),
              if (widget.isNext)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
            elevation: 2 + (_glowAnimation!.value * 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: primaryColor.withValues(alpha: 0.3 + (_glowAnimation!.value * 0.5)),
                width: 1.8,
              ),
            ),
            color: isDark
                ? primaryColor.withValues(alpha: 0.25)
                : primaryColor.withValues(alpha: 0.08),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.12 * _glowAnimation!.value),
                    blurRadius: 10 * _glowAnimation!.value,
                    spreadRadius: 1 * _glowAnimation!.value,
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
