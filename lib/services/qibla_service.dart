import 'dart:math' as math;

class QiblaService {
  // Kaaba (Mecca) coordinates
  static const double meccaLatitude = 21.4225;
  static const double meccaLongitude = 39.8262;

  /// Geçerli WGS84 koordinat aralığını doğrular.
  static void validateCoordinates(double latitude, double longitude) {
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw ArgumentError(
          'Geçersiz koordinat: ($latitude, $longitude)');
    }
  }

  /// Calculates Qibla direction (in degrees from True North 0..360°).
  ///
  /// NOT: Telefon pusulası manyetik kuzeyi verir, bu formül gerçek
  /// (coğrafi) kuzeye göre açı hesaplar. Aradaki manyetik sapma
  /// (deklinasyon, Türkiye'de ~+5°) cihaza ve konuma göre değişir;
  /// hassas hizalama için ekrandaki manuel kalibrasyon kaydırıcısı
  /// bu farkı kapatmak içindir.
  static double calculateQiblaDirection(double latitude, double longitude) {
    validateCoordinates(latitude, longitude);
    final phi1 = _degreesToRadians(latitude);
    final phi2 = _degreesToRadians(meccaLatitude);
    final deltaLambda = _degreesToRadians(meccaLongitude - longitude);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    double qiblaAngle = math.atan2(y, x);
    qiblaAngle = _radiansToDegrees(qiblaAngle);

    return (qiblaAngle + 360) % 360;
  }

  /// Calculates distance to Kaaba in kilometers
  static double calculateDistanceToMecca(double latitude, double longitude) {
    validateCoordinates(latitude, longitude);
    const double earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(meccaLatitude - latitude);
    final dLon = _degreesToRadians(meccaLongitude - longitude);

    final lat1 = _degreesToRadians(latitude);
    final lat2 = _degreesToRadians(meccaLatitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  static double _radiansToDegrees(double radians) {
    return radians * (180.0 / math.pi);
  }
}
