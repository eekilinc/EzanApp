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
      final rawTimeStr = entry.value as String;
      // Strip any trailing timezone strings like " (+03)" or " (EET)"
      final cleanTimeStr = rawTimeStr.split(' ')[0].split('(')[0].trim();
      final timeParts = cleanTimeStr.split(':');
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

  PrayerTimes withOffsets(Map<String, int>? offsets) {
    if (offsets == null || offsets.isEmpty) return this;
    final adjustedTimings = Map<String, DateTime>.from(timings);
    offsets.forEach((prayerName, offsetMinutes) {
      if (offsetMinutes != 0 && adjustedTimings.containsKey(prayerName)) {
        adjustedTimings[prayerName] = adjustedTimings[prayerName]!.add(
          Duration(minutes: offsetMinutes),
        );
      }
    });
    return PrayerTimes(
      date: date,
      timings: adjustedTimings,
      createdAt: createdAt,
    );
  }

  List<PrayerEntry> getPrayerList() {
    // Sadece ezan okunan 5 vakit (Güneş hariç — Güneş'te ezan okunmaz)
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return prayers
        .where((prayer) => timings.containsKey(prayer))
        .map((prayer) => PrayerEntry(name: prayer, time: timings[prayer]!))
        .toList();
  }

  /// Sayaç, ilerleme çubuğu ve kart listesi için 6'lı zaman çizelgesi
  /// (Sabah -> Güneş -> Öğle -> İkindi -> Akşam -> Yatsı).
  List<PrayerEntry> getTimelineList() {
    const timeline = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return timeline
        .where((name) => timings.containsKey(name))
        .map((name) => PrayerEntry(name: name, time: timings[name]!))
        .toList();
  }

  /// [at] anında içinde bulunulan vakit.
  ///
  /// Gece yarısı ile sabah namazı arasında "içinde bulunulan vakit" dünün
  /// Yatsı'sıdır; bu durumda `isFromYesterday` true döner ve vakit tarihi
  /// bir gün geriye çekilir. Aksi hâlde 00:00–sabah arası hiçbir vakit
  /// "geçerli" görünmez ve ilerleme çubuğu yanlış aralığı gösterir.
  ///
  /// Saf fonksiyondur — platforma veya saate bağlı değildir, [at] verilmezse
  /// sistem saati kullanılır.
  ({PrayerEntry prayer, bool isFromYesterday})? currentPrayerAt(DateTime at) {
    final prayers = getTimelineList();
    if (prayers.isEmpty) return null;

    PrayerEntry? current;
    for (final prayer in prayers) {
      if (!prayer.time.isAfter(at)) {
        current = prayer;
      } else {
        break;
      }
    }

    if (current != null) return (prayer: current, isFromYesterday: false);

    // Saat 00:00 – Fajr arası: dünün Yatsı'sındayız. Yalnızca çizelgede
    // Isha varsa anlamlıdır.
    final last = prayers.last;
    if (last.name == 'Isha') {
      return (
        prayer: PrayerEntry(
          name: last.name,
          time: last.time.subtract(const Duration(days: 1)),
        ),
        isFromYesterday: true,
      );
    }

    return null;
  }

  /// [at] anında sıradaki vakit.
  ///
  /// Bugünün tüm vakitleri geçtiyse ertesi günün Sabah'ını döndürür.
  /// [at] verilmezse sistem saati kullanılır.
  PrayerEntry? nextPrayerAt(DateTime at) {
    final prayers = getTimelineList();
    if (prayers.isEmpty) return null;

    for (final prayer in prayers) {
      if (prayer.time.isAfter(at)) return prayer;
    }

    final fajr = prayers.firstWhere(
      (p) => p.name == 'Fajr',
      orElse: () => prayers.first,
    );
    return PrayerEntry(
      name: fajr.name,
      time: fajr.time.add(const Duration(days: 1)),
    );
  }

  /// [at] anında mevcut vakit aralığının ne kadarı geçtiğini döndürür (0..1).
  ///
  /// İlerleme çubuğu için: sıradaki vakde kadar kalan aralığın tamamlanma
  /// oranı. Günün son vakti geçtiyse son vakitten ertesi günün ilk vakde
  /// olan aralık kullanılır.
  double progressAt(DateTime at) {
    final prayers = getTimelineList();
    if (prayers.isEmpty) return 0.0;

    // [at]'dan sonraki ilk vakit; yoksa ertesi günün ilk vakti (Sabah).
    var nextIndex = prayers.length;
    for (var i = 0; i < prayers.length; i++) {
      if (prayers[i].time.isAfter(at)) {
        nextIndex = i;
        break;
      }
    }

    late final DateTime nextTime;
    late final DateTime prevTime;

    if (nextIndex < prayers.length) {
      nextTime = prayers[nextIndex].time;
      // İlk vakdin öncesi için makul bir alt sınır: 4 saat önce.
      prevTime = nextIndex > 0
          ? prayers[nextIndex - 1].time
          : nextTime.subtract(const Duration(hours: 4));
    } else {
      // Günün son vakti de geçti: son vakitten ertesi günün ilk vakde.
      prevTime = prayers.last.time;
      nextTime = prayers.first.time.add(const Duration(days: 1));
    }

    final totalDuration = nextTime.difference(prevTime).inSeconds;
    if (totalDuration <= 0) return 0.0;
    final elapsed = at.difference(prevTime).inSeconds;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  /// Güneş doğumunda ezan okunmaz — sadece sessiz/kısa hatırlatma verilir.
  static bool isAdhanTime(String name) => name != 'Sunrise';
}

class PrayerEntry {
  final String name;
  final DateTime time;

  PrayerEntry({required this.name, required this.time});

  String getDisplayTime() {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
