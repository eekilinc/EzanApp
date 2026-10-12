import '../models/prayer_times.dart';
import '../models/islamic_event.dart';
import '../constants/reminders.dart';

/// Planlanmış tek bir bildirim. Saf veri — henüz platforma yazılmamış.
class PlannedNotification {
  /// Android/Darwin tarafında benzersiz olması gereken tamsayı kimlik.
  final int id;
  final String title;
  final String body;

  /// [now]'dan sonra olmalı; geçmişe düşen bildirim planlanmaz.
  final DateTime scheduledTime;

  final bool soundEnabled;
  final bool vibrationEnabled;
  final String soundKey;

  /// 'alarm' bildirimleri dokununca alarm ekranını açar.
  final String payload;

  const PlannedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.soundKey,
    this.payload = 'alarm',
  });

  @override
  String toString() => 'PlannedNotification($id, $scheduledTime, "$title")';
}

/// Bildirim planlamasının tüm girdileri.
///
/// [PrayerProvider.scheduleNotifications]'ın uzun parametre listesini tek
/// bir değer objesine toplar; saf [NotificationPlanner.build] yalnızca
/// veri okur ve veri döndürür — saat/Platform/IO yoktur.
class NotificationPlanRequest {
  /// İçinde bu ve sonraki 7 gün bulunması beklenen günlük vakit listesi.
  /// Ay sonunda bir sonraki ayın başı da eklenmiş olabilir.
  final List<PrayerTimes> days;

  /// Bildirim penceresi kaç gün ileriye bakmalı.
  ///
  /// Varsayılan 7: bu, "bugün + 7 gün" demek. Kasıtlı bir trade-off —
  /// Android AlarmManager kuyruğu her gün ~12 bildirim biriktirir (6 vakit
  /// + hatırlatıcıları); pencereyi büyütmek pil/bellek maliyetini
  /// doğrudan artırır, kazancı yoktur. Kullanıcı uygulamayı her açtığında
  /// plan yeniden yazıldığı için bu pencere "ne kadar süre açılmadan
  /// kalabilir" sınırıdır (bkz. aşağıdaki not).
  ///
  /// NOT: Kullanıcı bu pencere boyunca (8+ gün) uygulamayı hiç açmazsa
  /// bildirimler durur. Bu kabul edilmiş bir davranıştır; artırmak istenirse
  /// tek yapılacak değişiklik bu sayıdır.
  final int horizonDays;

  final DateTime now;
  final Map<String, int> reminderMinutes;
  final Map<String, int> prayerOffsets;

  final String adhanSoundKey;
  final bool adhanSoundEnabled;
  final String reminderSoundKey;
  final bool reminderSoundEnabled;
  final bool vibrationEnabled;

  final bool fridayReminderEnabled;
  final bool sahurReminderEnabled;

  /// Sıradaki dini gün hatırlatması için (yoksa null).
  final IslamicEvent? nextEvent;

  const NotificationPlanRequest({
    required this.days,
    required this.now,
    required this.reminderMinutes,
    required this.prayerOffsets,
    required this.adhanSoundKey,
    required this.adhanSoundEnabled,
    required this.reminderSoundKey,
    required this.reminderSoundEnabled,
    required this.vibrationEnabled,
    required this.fridayReminderEnabled,
    required this.sahurReminderEnabled,
    this.horizonDays = 7,
    this.nextEvent,
  });
}

/// Bildirim zamanlamasının saf hesap katmanı.
///
/// Buradaki her şey deterministiktir: aynı girdi → aynı çıktı. Bu sayede
/// ay sonu geçişi, gece yarısı ve pencere sınırları gibi kenar durumlar
/// platform bağımsız olarak test edilebilir.
class NotificationPlanner {
  /// Bildirim kimlikleri: tarih + vakit + tür üçlüsünden türetilir ki
  /// yeniden planlama aynı kaydın üstüne yazsın, mükerrer oluşmasın.
  ///
  /// Dart `String.hashCode` çalıştırma arasında sabit değildir; kimliğin
  /// uygulama yeniden başlatmaları arasında da korunması gerektiği için
  /// FNV-1a kullanılır.
  static int generateId(String prayer, DateTime date, String type) {
    final key =
        '${date.year}${_two(date.month)}${_two(date.day)}${prayer}_$type';
    return _fnv1a(key) & 0x7FFFFFFF;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// 32-bit FNV-1a — kısa, bağımlılıksız, çalıştırma arasında kararlı.
  static int _fnv1a(String s) {
    var hash = 0x811c9dc5;
    for (var i = 0; i < s.length; i++) {
      hash ^= s.codeUnitAt(i);
      // 32-bit taşma: Dart tamsayıları 64-bit, bu yüzden maskeliyoruz.
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }

  static List<PlannedNotification> build(NotificationPlanRequest request) {
    final out = <PlannedNotification>[];
    final now = request.now;
    final today = DateTime(now.year, now.month, now.day);

    for (final rawDay in request.days) {
      final dayTimes = rawDay.withOffsets(request.prayerOffsets);
      final dayDiff = dayTimes.date.difference(today).inDays;

      // Geçmiş günler ve pencere dışı günler planlanmaz. Bu hem performans
      // hem de bellek gerekçesiyle kasıtlı; bkz. README.
      if (dayDiff < 0 || dayDiff > request.horizonDays) continue;

      for (final prayer in dayTimes.getTimelineList()) {
        final reminderMinutes =
            request.reminderMinutes[prayer.name] ??
            defaultReminderMinutes[prayer.name] ??
            5;

        if (prayer.name == 'Sunrise') {
          // Güneş doğumunda ezan okunmaz — yalnızca bilgilendirme.
          out.add(
            PlannedNotification(
              id: generateId('Sunrise', prayer.time, 'exact'),
              title: '🌅 Güneş Doğdu',
              body: 'Kerahat vakti çıktı. Sabah namazı vakti sona erdi.',
              scheduledTime: prayer.time,
              soundEnabled: false,
              vibrationEnabled: request.vibrationEnabled,
              soundKey: request.reminderSoundKey,
            ),
          );

          if (reminderMinutes != 0) {
            final at = reminderMinutes > 0
                ? prayer.time.subtract(Duration(minutes: reminderMinutes))
                : prayer.time.add(Duration(minutes: reminderMinutes.abs()));
            out.add(
              PlannedNotification(
                id: generateId('Sunrise', prayer.time, 'reminder'),
                title: '🌅 Güneş Hatırlatması ⏰',
                body: reminderMinutes > 0
                    ? 'Güneş doğumuna $reminderMinutes dakika kaldı.'
                    : 'Güneş doğalı ${reminderMinutes.abs()} dakika oldu.',
                scheduledTime: at,
                soundEnabled: request.reminderSoundEnabled,
                vibrationEnabled: request.vibrationEnabled,
                soundKey: request.reminderSoundKey,
              ),
            );
          }
          continue;
        }

        out.add(
          PlannedNotification(
            id: generateId(prayer.name, prayer.time, 'exact'),
            title:
                '${prayerDisplayNames[prayer.name] ?? prayer.name} Vakti Girdi 🕌',
            body:
                '${prayerDisplayNames[prayer.name] ?? prayer.name} ezanı okunuyor. Haydi namaza! 🕌',
            scheduledTime: prayer.time,
            soundEnabled: request.adhanSoundEnabled,
            vibrationEnabled: request.vibrationEnabled,
            soundKey: request.adhanSoundKey,
          ),
        );

        if (reminderMinutes != 0) {
          final at = reminderMinutes > 0
              ? prayer.time.subtract(Duration(minutes: reminderMinutes))
              : prayer.time.add(Duration(minutes: reminderMinutes.abs()));
          out.add(
            PlannedNotification(
              id: generateId(prayer.name, prayer.time, 'reminder'),
              title:
                  '${prayerDisplayNames[prayer.name] ?? prayer.name} Hatırlatması ⏰',
              body: reminderMinutes > 0
                  ? '${prayerDisplayNames[prayer.name] ?? prayer.name} vakit girmesine $reminderMinutes dakika kaldı.'
                  : '${prayerDisplayNames[prayer.name] ?? prayer.name} vakti gireli ${reminderMinutes.abs()} dakika oldu.',
              scheduledTime: at,
              soundEnabled: request.reminderSoundEnabled,
              vibrationEnabled: request.vibrationEnabled,
              soundKey: request.reminderSoundKey,
            ),
          );
        }

        // Cuma: öğle namazından 1 saat önce.
        if (request.fridayReminderEnabled &&
            prayer.name == 'Dhuhr' &&
            prayer.time.weekday == DateTime.friday) {
          out.add(
            PlannedNotification(
              id: 666000 + dayDiff,
              title: '🕌 Cuma Gününüz Mübarek Olsun!',
              body:
                  'Cuma Namazı vaktine 1 saat kaldı. Dualarınız kabul olsun. 🤲',
              scheduledTime: prayer.time.subtract(const Duration(minutes: 60)),
              soundEnabled: request.reminderSoundEnabled,
              vibrationEnabled: request.vibrationEnabled,
              soundKey: request.reminderSoundKey,
            ),
          );
        }

        // Sahur & Teheccüd: imsaka 45 dakika.
        if (request.sahurReminderEnabled && prayer.name == 'Fajr') {
          out.add(
            PlannedNotification(
              id: 555000 + dayDiff,
              title: '🌙 Sahur & Teheccüd Uyarısı',
              body: 'İmsak vaktine 45 dakika kaldı. Hayırlı Sahurlar! 🌙',
              scheduledTime: prayer.time.subtract(const Duration(minutes: 45)),
              soundEnabled: request.reminderSoundEnabled,
              vibrationEnabled: request.vibrationEnabled,
              soundKey: request.reminderSoundKey,
            ),
          );
        }
      }
    }

    // Dini gün hatırlatması: sıradaki etkinlikten 1 gün önce, sabah 09:00.
    final event = request.nextEvent;
    if (event != null) {
      final at = DateTime(
        event.gregorianDate.year,
        event.gregorianDate.month,
        event.gregorianDate.day,
      ).subtract(const Duration(days: 1));
      final reminderTime = DateTime(at.year, at.month, at.day, 9);
      out.add(
        PlannedNotification(
          id: 777001,
          title: '🕌 Yarın: ${event.titleTr}',
          body: '${event.hijri} — ${event.dateTr}. Mübarek olsun! 🤲',
          scheduledTime: reminderTime,
          soundEnabled: request.reminderSoundEnabled,
          vibrationEnabled: request.vibrationEnabled,
          soundKey: request.reminderSoundKey,
        ),
      );
    }

    // Geçmişe düşenleri ele — platforma yazılırken zaten atlanırdı, ama
    // planı tek noktada temiz tutmak hem testi hem gözü rahatlatıyor.
    return out
        .where((n) => n.scheduledTime.isAfter(now))
        .toList(growable: false);
  }
}
