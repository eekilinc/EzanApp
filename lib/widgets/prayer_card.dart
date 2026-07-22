import 'package:flutter/material.dart';
import '../models/prayer_times.dart';
import '../constants/reminders.dart';

class PrayerCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final displayName = prayerDisplayNames[prayer.name] ?? prayer.name;

    return Card(
      elevation: isNext ? 8 : 2,
      color: isNext ? Colors.green[100] : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hatırlatma: $minutesBefore dakika önce',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  prayer.getDisplayTime(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isNext ? Colors.green : Colors.black,
                  ),
                ),
                if (isNext)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Sonraki →',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
