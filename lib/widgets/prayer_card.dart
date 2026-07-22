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
    final reminderText = minutesBefore == 0
        ? 'Hatırlatma: Tam vaktinde'
        : 'Hatırlatma: $minutesBefore dk önce';

    return Card(
      elevation: isNext ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isNext
            ? BorderSide(color: Colors.green.shade400, width: 2)
            : BorderSide.none,
      ),
      color: isNext ? Colors.green.shade50 : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isNext ? Colors.green : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.access_time_filled,
                    color: isNext ? Colors.white : Colors.grey.shade600,
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
                        fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                        color: isNext ? Colors.green.shade900 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reminderText,
                      style: TextStyle(
                        fontSize: 12,
                        color: isNext ? Colors.green.shade700 : Colors.grey.shade600,
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
                  prayer.getDisplayTime(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isNext ? Colors.green.shade700 : Colors.black87,
                  ),
                ),
                if (isNext)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Sıradaki',
                      style: TextStyle(
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
      ),
    );
  }
}
