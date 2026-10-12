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
    'Zilhicce',
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
    'Dhu al-Hijjah',
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

    int jd =
        (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524;

    int l = jd - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;

    int j =
        ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
        ((l / 5670).floor() * ((43 * l) / 15238).floor());
    l =
        l -
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

  /// Hicri (yıl, ay, gün) → Gregorian tarih (Kuveyt algoritması).
  ///
  /// [getHijriDate]'in ters yönüdür ve aynı Julian Day çekirdeğini kullanır,
  /// bu yüzden iki yön birbirini tutarlı biçimde tersine çevirir.
  ///
  /// NOT: Kuveyt bir aritmetik yaklaşımdır; ay görmesi (ruyet) tabanlı
  /// resmi takvimlerden 0-1 gün sapabilir. Dini günlerde bu fark kabul
  /// edilir; bkz. [IslamicEventService].
  static DateTime hijriToGregorian(int year, int month, int day) {
    final jd =
        (11 * year + 3) ~/ 30 +
        354 * year +
        30 * month -
        (month - 1) ~/ 2 +
        day +
        1948440 -
        385;
    return _gregorianFromJulianDay(jd);
  }

  /// Bugünün üzerine [count] gün ekleyip sonucun hicri (yıl, ay, gün)
  /// bileşenlerini döndürür. Hicri yılı, verilen tarihten türetilir.
  ///
  /// Dini günlerin Gregorian tarihini "bu hicri yılda şu gün" diyerek
  /// tanımlayıp bugünün üzerinden aramak için kullanılır; böylece liste
  /// elle güncellenmeden her yıl kendiliğinden ileri gider.
  static ({int year, int month, int day}) hijriAfterDays(
    DateTime from,
    int count,
  ) {
    final base = DateTime(from.year, from.month, from.day + count);
    return toHijri(base);
  }

  /// Gregorian → Hicri bileşenleri (Kuveyt algoritması).
  static ({int year, int month, int day}) toHijri(DateTime date) {
    var day = date.day;
    var month = date.month;
    var year = date.year;

    if (month < 3) {
      year -= 1;
      month += 12;
    }

    final a = year ~/ 100;
    final b = 2 - a + (a ~/ 4);

    final jd =
        (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524;

    var l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;

    final j =
        (10985 - l) ~/ 5316 * (50 * l) ~/ 17719 +
        (l ~/ 5670) * (43 * l) ~/ 15238;
    l =
        l -
        (30 - j) ~/ 15 * (17719 * j) ~/ 50 -
        (j ~/ 16) * (15238 * j) ~/ 43 +
        29;

    var hMonth = (24 * l) ~/ 709;
    final hDay = l - (709 * hMonth) ~/ 24;
    final hYear = 30 * n + j - 30;

    if (hMonth < 1) hMonth = 1;
    if (hMonth > 12) hMonth = 12;

    return (year: hYear, month: hMonth, day: hDay);
  }

  /// Julian Day Number → Gregorian tarih (JWLD).
  static DateTime _gregorianFromJulianDay(int jd) {
    final a = jd + 32044;
    final b = (4 * a + 3) ~/ 146097;
    final c = a - (146097 * b) ~/ 4;
    final d = (4 * c + 3) ~/ 1461;
    final e = c - (1461 * d) ~/ 4;
    final m = (5 * e + 2) ~/ 153;

    final day = e - (153 * m + 2) ~/ 5 + 1;
    final month = m + 3 - 12 * (m ~/ 10);
    final year = 100 * b + d - 4800 + (m ~/ 10);

    return DateTime(year, month, day);
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
