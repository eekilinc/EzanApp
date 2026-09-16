const Map<String, int> defaultReminderMinutes = {
  'Fajr': 20,
  'Sunrise': 0,
  'Dhuhr': 5,
  'Asr': 5,
  'Maghrib': 0,
  'Isha': 5,
};

const List<String> prayerNames = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

/// Sadece ezan okunan vakitler (bildirim planlama için).
const List<String> adhanPrayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

const Map<String, String> prayerDisplayNames = {
  'Fajr': 'Sabah Namazı',
  'Sunrise': 'Güneş',
  'Dhuhr': 'Öğle Namazı',
  'Asr': 'İkindi Namazı',
  'Maghrib': 'Akşam Namazı',
  'Isha': 'Yatsı Namazı',
};
