import 'dart:math' as math;

/// World Magnetic Model 2025 (epoch 2025.0, geçerlilik 2025-2030) saf Dart
/// implementasyonu — yalnızca manyetik sapma (deklinasyon) hesabı için.
///
/// NOT: Bu dosyanın katsayı tablosu resmi WMM2025.COF dosyasından otomatik
/// üretilmiştir; elle değiştirmeyin. Yeni model çıktığında tabloyu yenileyip
/// [epoch] değerini güncellemek yeterlidir.
///
/// Kullanım: telefon pusulası manyetik kuzeyi verir, kıble matematiği gerçek
/// (coğrafi) kuzeye göredir. Gerçek başlık = (manyetik + sapma) mod 360.
class Wmm2025 {
  Wmm2025._();

  /// Model referans yılı.
  static const double epoch = 2025.0;

  /// WGS84 elipsoidi (km).
  static const double _a = 6378.137;
  static const double _b = 6356.7523142;

  /// WMM manyetik referans küre yarıçapı (km). Konum hesabı WGS84 ile,
  /// potansiyel güçleri bununla ölçeklenir — karıştırmayın.
  static const double _refR = 6371.2;

  /// COF satırları: [n, m, g, h, dg/dt, dh/dt] (nT, nT/yıl).
  static const List<List<double>> _cof = <List<double>>[
    [1, 0, -29351.8, 0.0, 12.0, 0.0],
    [1, 1, -1410.8, 4545.4, 9.7, -21.5],
    [2, 0, -2556.6, 0.0, -11.6, 0.0],
    [2, 1, 2951.1, -3133.6, -5.2, -27.7],
    [2, 2, 1649.3, -815.1, -8.0, -12.1],
    [3, 0, 1361.0, 0.0, -1.3, 0.0],
    [3, 1, -2404.1, -56.6, -4.2, 4.0],
    [3, 2, 1243.8, 237.5, 0.4, -0.3],
    [3, 3, 453.6, -549.5, -15.6, -4.1],
    [4, 0, 895.0, 0.0, -1.6, 0.0],
    [4, 1, 799.5, 278.6, -2.4, -1.1],
    [4, 2, 55.7, -133.9, -6.0, 4.1],
    [4, 3, -281.1, 212.0, 5.6, 1.6],
    [4, 4, 12.1, -375.6, -7.0, -4.4],
    [5, 0, -233.2, 0.0, 0.6, 0.0],
    [5, 1, 368.9, 45.4, 1.4, -0.5],
    [5, 2, 187.2, 220.2, 0.0, 2.2],
    [5, 3, -138.7, -122.9, 0.6, 0.4],
    [5, 4, -142.0, 43.0, 2.2, 1.7],
    [5, 5, 20.9, 106.1, 0.9, 1.9],
    [6, 0, 64.4, 0.0, -0.2, 0.0],
    [6, 1, 63.8, -18.4, -0.4, 0.3],
    [6, 2, 76.9, 16.8, 0.9, -1.6],
    [6, 3, -115.7, 48.8, 1.2, -0.4],
    [6, 4, -40.9, -59.8, -0.9, 0.9],
    [6, 5, 14.9, 10.9, 0.3, 0.7],
    [6, 6, -60.7, 72.7, 0.9, 0.9],
    [7, 0, 79.5, 0.0, -0.0, 0.0],
    [7, 1, -77.0, -48.9, -0.1, 0.6],
    [7, 2, -8.8, -14.4, -0.1, 0.5],
    [7, 3, 59.3, -1.0, 0.5, -0.8],
    [7, 4, 15.8, 23.4, -0.1, 0.0],
    [7, 5, 2.5, -7.4, -0.8, -1.0],
    [7, 6, -11.1, -25.1, -0.8, 0.6],
    [7, 7, 14.2, -2.3, 0.8, -0.2],
    [8, 0, 23.2, 0.0, -0.1, 0.0],
    [8, 1, 10.8, 7.1, 0.2, -0.2],
    [8, 2, -17.5, -12.6, 0.0, 0.5],
    [8, 3, 2.0, 11.4, 0.5, -0.4],
    [8, 4, -21.7, -9.7, -0.1, 0.4],
    [8, 5, 16.9, 12.7, 0.3, -0.5],
    [8, 6, 15.0, 0.7, 0.2, -0.6],
    [8, 7, -16.8, -5.2, -0.0, 0.3],
    [8, 8, 0.9, 3.9, 0.2, 0.2],
    [9, 0, 4.6, 0.0, -0.0, 0.0],
    [9, 1, 7.8, -24.8, -0.1, -0.3],
    [9, 2, 3.0, 12.2, 0.1, 0.3],
    [9, 3, -0.2, 8.3, 0.3, -0.3],
    [9, 4, -2.5, -3.3, -0.3, 0.3],
    [9, 5, -13.1, -5.2, 0.0, 0.2],
    [9, 6, 2.4, 7.2, 0.3, -0.1],
    [9, 7, 8.6, -0.6, -0.1, -0.2],
    [9, 8, -8.7, 0.8, 0.1, 0.4],
    [9, 9, -12.9, 10.0, -0.1, 0.1],
    [10, 0, -1.3, 0.0, 0.1, 0.0],
    [10, 1, -6.4, 3.3, 0.0, 0.0],
    [10, 2, 0.2, 0.0, 0.1, -0.0],
    [10, 3, 2.0, 2.4, 0.1, -0.2],
    [10, 4, -1.0, 5.3, -0.0, 0.1],
    [10, 5, -0.6, -9.1, -0.3, -0.1],
    [10, 6, -0.9, 0.4, 0.0, 0.1],
    [10, 7, 1.5, -4.2, -0.1, 0.0],
    [10, 8, 0.9, -3.8, -0.1, -0.1],
    [10, 9, -2.7, 0.9, -0.0, 0.2],
    [10, 10, -3.9, -9.1, -0.0, -0.0],
    [11, 0, 2.9, 0.0, 0.0, 0.0],
    [11, 1, -1.5, 0.0, -0.0, -0.0],
    [11, 2, -2.5, 2.9, 0.0, 0.1],
    [11, 3, 2.4, -0.6, 0.0, -0.0],
    [11, 4, -0.6, 0.2, 0.0, 0.1],
    [11, 5, -0.1, 0.5, -0.1, -0.0],
    [11, 6, -0.6, -0.3, 0.0, -0.0],
    [11, 7, -0.1, -1.2, -0.0, 0.1],
    [11, 8, 1.1, -1.7, -0.1, -0.0],
    [11, 9, -1.0, -2.9, -0.1, 0.0],
    [11, 10, -0.2, -1.8, -0.1, 0.0],
    [11, 11, 2.6, -2.3, -0.1, 0.0],
    [12, 0, -2.0, 0.0, 0.0, 0.0],
    [12, 1, -0.2, -1.3, 0.0, -0.0],
    [12, 2, 0.3, 0.7, -0.0, 0.0],
    [12, 3, 1.2, 1.0, -0.0, -0.1],
    [12, 4, -1.3, -1.4, -0.0, 0.1],
    [12, 5, 0.6, -0.0, -0.0, -0.0],
    [12, 6, 0.6, 0.6, 0.1, -0.0],
    [12, 7, 0.5, -0.1, -0.0, -0.0],
    [12, 8, -0.1, 0.8, 0.0, 0.0],
    [12, 9, -0.4, 0.1, 0.0, -0.0],
    [12, 10, -0.2, -1.0, -0.1, -0.0],
    [12, 11, -1.3, 0.1, -0.0, 0.0],
    [12, 12, -0.7, 0.2, -0.1, -0.1],
  ];

  static double _fact(int n) {
    var r = 1.0;
    for (var i = 2; i <= n; i++) {
      r *= i;
    }
    return r;
  }

  /// Schmidt yarı-normalizasyon çarpanı.
  static double _schmidt(int n, int m) {
    if (m == 0) return 1.0;
    return math.sqrt(2.0 * _fact(n - m) / _fact(n + m));
  }

  /// Verilen konum ve tarihte manyetik sapmayı (deklinasyon, derece) döner.
  /// Doğu pozitif: örn. İstanbul için ~+5 (pusula gerçek kuzeyin 5° batısını
  /// gösterir, düzeltme = manyetik + sapma).
  static double declination(
    double latitude,
    double longitude, [
    DateTime? date,
  ]) {
    final f = field(latitude, longitude, date);
    return _deg(math.atan2(f[1], f[0]));
  }

  /// Manyetik alan vektörünü coğrafi bileşenlerle döner: [X kuzey, Y doğu,
  /// Z aşağı] (nT).
  static List<double> field(
    double latitude,
    double longitude, [
    DateTime? date,
  ]) {
    const maxN = 12;
    final now = date ?? DateTime.now();
    final t = _decimalYear(now) - epoch;

    final latR = _rad(latitude);
    final lonR = _rad(longitude);
    final sinLat = math.sin(latR);
    final cosLat = math.cos(latR);

    // Jeodezik -> küresel (h = 0 km, yeryüzü).
    const h = 0.0;
    final e2 = 1.0 - (_b * _b) / (_a * _a);
    final nPhi = _a / math.sqrt(1.0 - e2 * sinLat * sinLat);
    final rho = (nPhi + h) * cosLat;
    final z = (nPhi * (1.0 - e2) + h) * sinLat;
    final r = math.sqrt(rho * rho + z * z);
    final cosTheta = (z / r).clamp(-1.0, 1.0);
    final theta = math.acos(cosTheta);
    var sinTheta = math.sin(theta);
    if (sinTheta.abs() < 1e-10) sinTheta = 1e-10;

    // Normalize edilmemiş Legendre P(n,m) ve dP/dθ (0 <= m <= n <= 12).
    final p = List.generate(maxN + 1, (_) => List.filled(maxN + 1, 0.0));
    final dp = List.generate(maxN + 1, (_) => List.filled(maxN + 1, 0.0));
    p[0][0] = 1.0;
    for (var m = 0; m <= maxN; m++) {
      if (m > 0) {
        p[m][m] = sinTheta * (2 * m - 1) * p[m - 1][m - 1];
        dp[m][m] = cosTheta * (2 * m - 1) * p[m - 1][m - 1] +
            sinTheta * (2 * m - 1) * dp[m - 1][m - 1];
      }
      if (m < maxN) {
        p[m + 1][m] = cosTheta * (2 * m + 1) * p[m][m];
        dp[m + 1][m] = -sinTheta * (2 * m + 1) * p[m][m] +
            cosTheta * (2 * m + 1) * dp[m][m];
      }
      for (var nn = m + 2; nn <= maxN; nn++) {
        p[nn][m] = (cosTheta * (2 * nn - 1) * p[nn - 1][m] -
                (nn + m - 1) * p[nn - 2][m]) /
            (nn - m);
        dp[nn][m] = (-sinTheta * (2 * nn - 1) * p[nn - 1][m] +
                cosTheta * (2 * nn - 1) * dp[nn - 1][m] -
                (nn + m - 1) * dp[nn - 2][m]) /
            (nn - m);
      }
    }

    // Küresel bileşenler: Br (dışa), Bt (güneye), Bp (doğuya).
    var br = 0.0, bt = 0.0, bp = 0.0;
    var ar = (_refR / r) * (_refR / r);
    for (var nn = 1; nn <= maxN; nn++) {
      ar *= _refR / r; // (a/r)^(n+2)
      for (final row in _cof) {
        if (row[0].toInt() != nn) continue;
        final m = row[1].toInt();
        final g = row[2] + t * row[4];
        final hh = row[3] + t * row[5];
        final s = _schmidt(nn, m);
        final ps = s * p[nn][m];
        final dps = s * dp[nn][m];
        final cosML = math.cos(m * lonR);
        final sinML = math.sin(m * lonR);
        final gh = g * cosML + hh * sinML;
        br += ar * (nn + 1) * gh * ps;
        bt += -ar * gh * dps;
        bp += -ar * m * (-g * sinML + hh * cosML) * ps / sinTheta;
      }
    }

    // Küresel -> ECEF -> yerel coğrafi (kuzey, doğu, yukarı).
    final st = sinTheta, ct = cosTheta;
    final sl = math.sin(lonR), cl = math.cos(lonR);
    final bx = br * st * cl + bt * ct * cl + bp * -sl;
    final by = br * st * sl + bt * ct * sl + bp * cl;
    final bz = br * ct + bt * -st;
    final ex = -sl, ey = cl, ez = 0.0;
    final nx = -sinLat * cl, ny = -sinLat * sl, nz = cosLat;
    final ux = cosLat * cl, uy = cosLat * sl, uz = sinLat;
    final x = bx * nx + by * ny + bz * nz;
    final y = bx * ex + by * ey + bz * ez;
    final zu = bx * ux + by * uy + bz * uz;
    return [x, y, -zu];
  }

  static double _decimalYear(DateTime d) {
    final start = DateTime(d.year, 1, 1);
    final doy = d.difference(start).inDays + 1;
    return d.year + (doy - 1) / 365.0;
  }

  static double _rad(double d) => d * math.pi / 180.0;
  static double _deg(double r) => r * 180.0 / math.pi;
}
