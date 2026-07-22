import 'package:intl/intl.dart';

class HijriService {
  static const List<String> hijriMonthsTr = [
    'Muharrem',
    'Sefer',
    'Rebiülevvel',
    'Rebiülahir',
    'Cemaziyelevvel',
    'Cemaziyelahir',
    'Recep',
    'Şaban',
    'Ramazan',
    'Şevval',
    'Zilkade',
    'Zilhicce'
  ];

  static const List<String> hijriMonthsEn = [
    'Muharram',
    'Safar',
    'Rabi\' al-Awwal',
    'Rabi\' al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qi\'dah',
    'Dhu al-Hijjah'
  ];

  /// Calculates approximate Hijri Date (Kuwaiti algorithm)
  static String getHijriDate(DateTime date, String langCode) {
    // Julian Day Calculation
    int day = date.day;
    int month = date.month;
    int year = date.year;

    if (month < 3) {
      year -= 1;
      month += 12;
    }

    int a = (year / 100).floor();
    int b = 2 - a + (a / 4).floor();

    int jd = (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524;

    int l = jd - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;

    int j = ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
        ((l / 5670).floor() * ((43 * l) / 15238).floor());
    l = l -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        ((j / 16).floor() * ((15238 * j) / 43).floor()) +
        29;

    int hMonth = ((24 * l) / 709).floor();
    int hDay = l - ((709 * hMonth) / 24).floor();
    int hYear = 30 * n + j - 30;

    if (hMonth < 1) hMonth = 1;
    if (hMonth > 12) hMonth = 12;

    final monthName = (langCode == 'en')
        ? hijriMonthsEn[hMonth - 1]
        : hijriMonthsTr[hMonth - 1];

    return '$hDay $monthName $hYear';
  }

  /// Formats Gregorian Date
  static String getGregorianDate(DateTime date, String langCode) {
    if (langCode == 'en') {
      return DateFormat('EEEE, d MMMM yyyy').format(date);
    } else {
      const dayNames = {
        'Monday': 'Pazartesi',
        'Tuesday': 'Salı',
        'Wednesday': 'Çarşamba',
        'Thursday': 'Perşembe',
        'Friday': 'Cuma',
        'Saturday': 'Cumartesi',
        'Sunday': 'Pazar',
      };
      const monthNames = {
        'January': 'Ocak',
        'February': 'Şubat',
        'March': 'Mart',
        'April': 'Nisan',
        'May': 'Mayıs',
        'June': 'Haziran',
        'July': 'Temmuz',
        'August': 'Ağustos',
        'September': 'Eylül',
        'October': 'Ekim',
        'November': 'Kasım',
        'December': 'Aralık',
      };
      final dayEn = DateFormat('EEEE').format(date);
      final monthEn = DateFormat('MMMM').format(date);
      final dayTr = dayNames[dayEn] ?? dayEn;
      final monthTr = monthNames[monthEn] ?? monthEn;
      return '${date.day} $monthTr ${date.year} $dayTr';
    }
  }
}
