import 'dart:math' as math;

class QiblaService {
  // Kaaba (Mecca) coordinates
  static const double meccaLatitude = 21.4225;
  static const double meccaLongitude = 39.8262;

  /// Calculates Qibla direction (in degrees from True North 0..360°)
  static double calculateQiblaDirection(double latitude, double longitude) {
    final phi1 = _degreesToRadians(latitude);
    final phi2 = _degreesToRadians(meccaLatitude);
    final deltaLambda = _degreesToRadians(meccaLongitude - longitude);

    final y = math.sin(deltaLambda);
    final x = math.cos(phi1) * math.tan(phi2) - math.sin(phi1) * math.cos(deltaLambda);

    double qiblaAngle = math.atan2(y, x);
    qiblaAngle = _radiansToDegrees(qiblaAngle);

    return (qiblaAngle + 360) % 360;
  }

  /// Calculates distance to Kaaba in kilometers
  static double calculateDistanceToMecca(double latitude, double longitude) {
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
