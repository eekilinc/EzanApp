class PrayerTimes {
  final DateTime date;
  final Map<String, DateTime> timings;
  final DateTime createdAt;

  PrayerTimes({
    required this.date,
    required this.timings,
    required this.createdAt,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timingsData = json['timings'] as Map<String, dynamic>;
    final dateStr = json['date']['gregorian']['date'] as String;

    final timings = <String, DateTime>{};
    final baseDateParts = dateStr.split('-');
    final baseDate = DateTime(
      int.parse(baseDateParts[2]),
      int.parse(baseDateParts[1]),
      int.parse(baseDateParts[0]),
    );

    for (final entry in timingsData.entries) {
      final timeStr = entry.value as String;
      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      timings[entry.key] = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hour,
        minute,
      );
    }

    return PrayerTimes(
      date: baseDate,
      timings: timings,
      createdAt: DateTime.now(),
    );
  }

  DateTime? getTimingByName(String name) => timings[name];

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String get fajrTime => _formatTime(timings['Fajr']);
  String get sunriseTime => _formatTime(timings['Sunrise']);
  String get dhuhrTime => _formatTime(timings['Dhuhr']);
  String get asrTime => _formatTime(timings['Asr']);
  String get maghribTime => _formatTime(timings['Maghrib']);
  String get ishaTime => _formatTime(timings['Isha']);

  List<PrayerEntry> getPrayerList() {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return prayers
        .where((prayer) => timings.containsKey(prayer))
        .map((prayer) => PrayerEntry(
              name: prayer,
              time: timings[prayer]!,
            ))
        .toList();
  }
}

class PrayerEntry {
  final String name;
  final DateTime time;

  PrayerEntry({
    required this.name,
    required this.time,
  });

  String getDisplayTime() {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
