class LocationData {
  final String city;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  LocationData({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      city: json['city'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TurkishCity {
  final String name;
  final double latitude;
  final double longitude;

  TurkishCity({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

// Büyük Türk şehirleri
final turkishCities = [
  TurkishCity(name: 'Istanbul', latitude: 41.0082, longitude: 28.9784),
  TurkishCity(name: 'Ankara', latitude: 39.9334, longitude: 32.8597),
  TurkishCity(name: 'Izmir', latitude: 38.4161, longitude: 27.1302),
  TurkishCity(name: 'Bursa', latitude: 40.1955, longitude: 29.1678),
  TurkishCity(name: 'Antalya', latitude: 36.8969, longitude: 30.7133),
  TurkishCity(name: 'Adana', latitude: 36.9909, longitude: 35.3213),
  TurkishCity(name: 'Diyarbakır', latitude: 37.9144, longitude: 40.2306),
  TurkishCity(name: 'Gaziantep', latitude: 37.0662, longitude: 37.3833),
  TurkishCity(name: 'Konya', latitude: 37.8744, longitude: 32.4856),
  TurkishCity(name: 'Kayseri', latitude: 38.7312, longitude: 35.4787),
  TurkishCity(name: 'Sakarya', latitude: 40.7468, longitude: 30.3949),
  TurkishCity(name: 'Çankırı', latitude: 40.6013, longitude: 33.6134),
];
