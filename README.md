# Ezan Hatırlatıcı - Islamic Prayer Times Reminder

<div align="center">

[![Sürüm](https://img.shields.io/github/v/release/eekilinc/EzanApp?style=for-the-badge&label=S%C3%BCr%C3%BCm&color=3DDC84)](https://github.com/eekilinc/EzanApp/releases/latest)
[![APK İndir](https://img.shields.io/badge/APK_%C4%B0ndir-Son_S%C3%BCr%C3%BCm-34A853?style=for-the-badge&logo=android&logoColor=white)](https://github.com/eekilinc/EzanApp/releases/latest)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue?style=for-the-badge&logo=flutter)](#kurulum)

</div>

Namaz vakitlerini görüp, özelleştirilebilir hatırlatmalar almak için bir Flutter uygulaması.

## Özellikler ✨

- 📍 **Konum Tabanlı**: GPS ile otomatik konum algılama veya şehir seçimi
- 🕌 **5 Vakit Namaz**: Sabah, Öğle, İkindi, Akşam, Yatsı namazlarının saatleri
- 🔔 **Özelleştirilebilir Hatırlatmalar**: Her namaz için farklı hatırlatma süresi (0-60 dakika)
- 🎵 **Ezan Sesi**: Namaz saati başında ezan sesi oynatma
- 🔊 **Bildirim Ayarları**: Ses ve titreşim kontrolü
- 🌙 **Hafif Tasarım**: Kullanıcı dostu, temiz arayüz
- ⚙️ **Ayarlar Paneli**: Tüm ayarlar bir yerde

## Teknik Stack 🛠️

- **Framework**: Flutter 3.38.5
- **Language**: Dart 3.10.4
- **API**: [Aladhan API](https://aladhan.com) - Dünyadaki namaz saatleri
- **State Management**: Provider
- **Storage**: SharedPreferences
- **Location**: Geolocator
- **Notifications**: flutter_local_notifications
- **Audio**: audioplayers
- **HTTP Client**: dio
- **Home Screen Widget**: home_widget
- **Compass**: flutter_compass

## Kurulum 📦

### Android

```bash
flutter pub get
flutter build apk --release
```

**Sistem Gereksinimleri**:
- Android 5.0+
- İnternet bağlantısı

**İzinler**:
- 📍 Konum (opsiyonel, GPS kullanmak için)
- 🔔 Bildirimler
- 🌐 İnternet

### iOS

```bash
flutter build ios --release
```

**Sistem Gereksinimleri**:
- iOS 11.0+
- CocoaPods

## Kullanım 🚀

1. Uygulamayı açın
2. Konum izni verin (GPS veya şehir seçimi)
3. Şehrinizi seçip namaz saatlerini görün
4. İsteğe bağlı ayarlar panelinden hatırlatmaları özelleştirin

### Hatırlatma Saatleri (Varsayılan)
- **Sabah (Fajr)**: 20 dakika önce
- **Öğle (Dhuhr)**: 5 dakika önce  
- **İkindi (Asr)**: 5 dakika önce
- **Akşam (Maghrib)**: Hemen
- **Yatsı (Isha)**: 5 dakika önce

## Proje Yapısı 📁

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── prayer_times.dart
│   └── location_data.dart
├── services/                 # Business logic
│   ├── api_service.dart
│   ├── location_service.dart
│   ├── notification_service.dart
│   └── audio_service.dart
├── providers/                # State management
│   ├── prayer_provider.dart
│   └── settings_provider.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Reusable widgets
│   ├── prayer_card.dart
│   └── location_picker.dart
└── constants/                # Constants
    └── reminders.dart
```

## API Entegrasyonu 🌐

Uygulama, ücretsiz [Aladhan API](https://aladhan.com/api) kullanarak namaz saatlerini çeker:

```
GET https://api.aladhan.com/v1/timings/{timestamp}
    ?latitude={lat}
    &longitude={lng}
    &method=2
```

**Cevap örneği**:
```json
{
  "data": {
    "timings": {
      "Fajr": "05:30",
      "Dhuhr": "12:30",
      "Asr": "15:45",
      "Maghrib": "18:15",
      "Isha": "19:30"
    }
  }
}
```

## Bildirim Sistemi 🔔

- Zamanlanmış yerel bildirimler (device'da çalışır)
- Arka planda çalışır
- Telefonun kapalı olsa bile aktif
- Kişiselleştirilmiş mesajlar

## Lisans 📄

MIT License - Özgür kullanım, kopyalama, dağıtım

## Destek 💬

Sorularınız ve önerileriniz için:
- Issues: [GitHub Issues](https://github.com/eekilinc/EzanApp/issues)

## Katkı 🤝

Katkılarınız çok hoş geldiniz! Lütfen bir branch oluşturup pull request gönderin.

## Bilgiler ℹ️

- 🕌 **Namaz Vakitleri Kaynağı**: Aladhan API (İslami kuruluş)
- 📍 **Konumlar**: 12+ Türk şehri (otomatik GPS desteği)
- 🌍 **Dil**: Türkçe arayüz

---

**Version**: 4.0.4  
**Last Updated**: 2026-08-24  
**Developer**: Made with ❤️ by [eekilinc](https://github.com/eekilinc)
