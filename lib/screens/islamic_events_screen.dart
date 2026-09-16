import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/islamic_event.dart';
import '../providers/settings_provider.dart';

class IslamicEventsScreen extends StatelessWidget {
  const IslamicEventsScreen({super.key});

  // Tek kaynak: IslamicEventService.events (tarih kaymasını önler).
  List<IslamicEvent> get _events => IslamicEventService.events;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isEn = settingsProvider.appLanguage == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEn ? 'Islamic Calendar & Events 📅' : 'Dini Günler & Kandiller 📅'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade900,
              Colors.green.shade900,
              const Color(0xFF0F1210),
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _events.length,
          itemBuilder: (context, index) {
            final event = _events[index];
            final title = event.getTitle(isEn);
            final dateStr = event.getDate(isEn);
            final daysDiff = event.daysRemaining;

            final isPast = daysDiff < 0;
            final isToday = daysDiff == 0;

            String statusLabel;
            if (isToday) {
              statusLabel = isEn ? 'TODAY 🎉' : 'BUGÜN 🎉';
            } else if (isPast) {
              statusLabel = isEn ? 'Passed' : 'Geçti';
            } else {
              statusLabel = isEn ? '$daysDiff days left' : '$daysDiff gün kaldı';
            }

            final iconColor = event.color;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: isToday ? 4 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isToday
                      ? Colors.amber
                      : (isPast ? Colors.transparent : Colors.teal.shade300.withValues(alpha: 0.4)),
                  width: isToday ? 2 : 1,
                ),
              ),
              color: isPast
                  ? Colors.black.withValues(alpha: 0.3)
                  : (isToday ? Colors.teal.shade800 : Colors.white.withValues(alpha: 0.12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: isPast ? Colors.grey.shade800 : iconColor.withValues(alpha: 0.25),
                  child: Icon(
                    event.icon,
                    color: isPast ? Colors.grey : (isToday ? Colors.amber : iconColor),
                    size: 26,
                  ),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isPast ? Colors.grey.shade400 : Colors.white,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 13,
                          color: isPast ? Colors.grey.shade500 : Colors.amber.shade200,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.hijri,
                        style: const TextStyle(fontSize: 11, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.amber
                        : (isPast
                            ? Colors.white10
                            : Colors.teal.shade600.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.black : (isPast ? Colors.grey : Colors.white),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
