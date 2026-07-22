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

// All 81 Provinces of Turkey
final turkishCities = [
  TurkishCity(name: 'Adana', latitude: 36.9909, longitude: 35.3213),
  TurkishCity(name: 'Adıyaman', latitude: 37.7644, longitude: 38.2786),
  TurkishCity(name: 'Afyonkarahisar', latitude: 38.7507, longitude: 30.5567),
  TurkishCity(name: 'Ağrı', latitude: 39.7191, longitude: 43.0503),
  TurkishCity(name: 'Aksaray', latitude: 38.3687, longitude: 34.0370),
  TurkishCity(name: 'Amasya', latitude: 40.6499, longitude: 35.8353),
  TurkishCity(name: 'Ankara', latitude: 39.9334, longitude: 32.8597),
  TurkishCity(name: 'Antalya', latitude: 36.8969, longitude: 30.7133),
  TurkishCity(name: 'Ardahan', latitude: 41.1105, longitude: 42.7022),
  TurkishCity(name: 'Artvin', latitude: 41.1828, longitude: 41.8183),
  TurkishCity(name: 'Aydın', latitude: 37.8560, longitude: 27.8416),
  TurkishCity(name: 'Balıkesir', latitude: 39.6484, longitude: 27.8826),
  TurkishCity(name: 'Bartın', latitude: 41.6358, longitude: 32.3375),
  TurkishCity(name: 'Batman', latitude: 37.8812, longitude: 41.1351),
  TurkishCity(name: 'Bayburt', latitude: 40.2552, longitude: 40.2249),
  TurkishCity(name: 'Bilecik', latitude: 40.1506, longitude: 29.9792),
  TurkishCity(name: 'Bingöl', latitude: 38.8853, longitude: 40.4980),
  TurkishCity(name: 'Bitlis', latitude: 38.4006, longitude: 42.1095),
  TurkishCity(name: 'Bolu', latitude: 40.7358, longitude: 31.6061),
  TurkishCity(name: 'Burdur', latitude: 37.7203, longitude: 30.2908),
  TurkishCity(name: 'Bursa', latitude: 40.1955, longitude: 29.1678),
  TurkishCity(name: 'Çanakkale', latitude: 40.1553, longitude: 26.4142),
  TurkishCity(name: 'Çankırı', latitude: 40.6013, longitude: 33.6134),
  TurkishCity(name: 'Çorum', latitude: 40.5506, longitude: 34.9556),
  TurkishCity(name: 'Denizli', latitude: 37.7765, longitude: 29.0864),
  TurkishCity(name: 'Diyarbakır', latitude: 37.9144, longitude: 40.2306),
  TurkishCity(name: 'Düzce', latitude: 40.8438, longitude: 31.1565),
  TurkishCity(name: 'Edirne', latitude: 41.6772, longitude: 26.5557),
  TurkishCity(name: 'Elazığ', latitude: 38.6810, longitude: 39.2264),
  TurkishCity(name: 'Erzincan', latitude: 39.7500, longitude: 39.5000),
  TurkishCity(name: 'Erzurum', latitude: 39.9000, longitude: 41.2700),
  TurkishCity(name: 'Eskişehir', latitude: 39.7767, longitude: 30.5206),
  TurkishCity(name: 'Gaziantep', latitude: 37.0662, longitude: 37.3833),
  TurkishCity(name: 'Giresun', latitude: 40.9128, longitude: 38.3895),
  TurkishCity(name: 'Gümüşhane', latitude: 40.4600, longitude: 39.4700),
  TurkishCity(name: 'Hakkari', latitude: 37.5833, longitude: 43.7333),
  TurkishCity(name: 'Hatay', latitude: 36.4018, longitude: 36.3498),
  TurkishCity(name: 'Iğdır', latitude: 39.9167, longitude: 44.0333),
  TurkishCity(name: 'Isparta', latitude: 37.7648, longitude: 30.5566),
  TurkishCity(name: 'Istanbul', latitude: 41.0082, longitude: 28.9784),
  TurkishCity(name: 'Izmir', latitude: 38.4161, longitude: 27.1302),
  TurkishCity(name: 'Kahramanmaraş', latitude: 37.5858, longitude: 36.9371),
  TurkishCity(name: 'Karabük', latitude: 41.2000, longitude: 32.6267),
  TurkishCity(name: 'Karaman', latitude: 37.1759, longitude: 33.2287),
  TurkishCity(name: 'Kars', latitude: 40.6012, longitude: 43.0975),
  TurkishCity(name: 'Kastamonu', latitude: 41.3887, longitude: 33.7827),
  TurkishCity(name: 'Kayseri', latitude: 38.7312, longitude: 35.4787),
  TurkishCity(name: 'Kırıkkale', latitude: 39.8468, longitude: 33.5153),
  TurkishCity(name: 'Kırklareli', latitude: 41.7333, longitude: 27.2167),
  TurkishCity(name: 'Kırşehir', latitude: 39.1425, longitude: 34.1709),
  TurkishCity(name: 'Kilis', latitude: 36.7184, longitude: 37.1147),
  TurkishCity(name: 'Kocaeli', latitude: 40.8533, longitude: 29.8815),
  TurkishCity(name: 'Konya', latitude: 37.8744, longitude: 32.4856),
  TurkishCity(name: 'Kütahya', latitude: 39.4167, longitude: 29.9833),
  TurkishCity(name: 'Malatya', latitude: 38.3552, longitude: 38.3095),
  TurkishCity(name: 'Manisa', latitude: 38.6191, longitude: 27.4289),
  TurkishCity(name: 'Mardin', latitude: 37.3212, longitude: 40.7245),
  TurkishCity(name: 'Mersin', latitude: 36.8000, longitude: 34.6333),
  TurkishCity(name: 'Muğla', latitude: 37.2153, longitude: 28.3636),
  TurkishCity(name: 'Muş', latitude: 38.7432, longitude: 41.5064),
  TurkishCity(name: 'Nevşehir', latitude: 38.6244, longitude: 34.7144),
  TurkishCity(name: 'Niğde', latitude: 37.9667, longitude: 34.6833),
  TurkishCity(name: 'Ordu', latitude: 40.9839, longitude: 37.8764),
  TurkishCity(name: 'Osmaniye', latitude: 37.0742, longitude: 36.2477),
  TurkishCity(name: 'Rize', latitude: 41.0201, longitude: 40.5234),
  TurkishCity(name: 'Sakarya', latitude: 40.7468, longitude: 30.3949),
  TurkishCity(name: 'Samsun', latitude: 41.2928, longitude: 36.3313),
  TurkishCity(name: 'Siirt', latitude: 37.9333, longitude: 41.9500),
  TurkishCity(name: 'Sinop', latitude: 42.0231, longitude: 35.1531),
  TurkishCity(name: 'Sivas', latitude: 39.7477, longitude: 37.0179),
  TurkishCity(name: 'Şanlıurfa', latitude: 37.1674, longitude: 38.7955),
  TurkishCity(name: 'Şırnak', latitude: 37.5164, longitude: 42.4611),
  TurkishCity(name: 'Tekirdağ', latitude: 40.9833, longitude: 27.5167),
  TurkishCity(name: 'Tokat', latitude: 40.3167, longitude: 36.5500),
  TurkishCity(name: 'Trabzon', latitude: 41.0027, longitude: 39.7168),
  TurkishCity(name: 'Tunceli', latitude: 39.1079, longitude: 39.5401),
  TurkishCity(name: 'Uşak', latitude: 38.6823, longitude: 29.4082),
  TurkishCity(name: 'Van', latitude: 38.4891, longitude: 43.4089),
  TurkishCity(name: 'Yalova', latitude: 40.6500, longitude: 29.2667),
  TurkishCity(name: 'Yozgat', latitude: 39.8181, longitude: 34.8147),
  TurkishCity(name: 'Zonguldak', latitude: 41.4564, longitude: 31.7987),
];
