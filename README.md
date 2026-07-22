# Ezan Hatırlatıcı - Islamic Prayer Times Reminder

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

1. Uygulamayı açıyor
2. Konum izni veriyor (GPS veya şehir seçimi)
3. Şehrinizi seçip namaz saatlerini görüyor
4. İsteğe bağlı ayarlar panelinden hatırlatmaları kustomize ediyorsunuz

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
- Telefonun kapı olsa bile aktif
- Kişiselleştirilmiş mesajlar

## Lisans 📄

MIT License - Özgür kullanım, kopyalama, dağıtım

## Destek 💬

Sorularınız ve önerileriniz için:
- Issues: [GitHub Issues](https://github.com/your-username/ezan-app/issues)
- Tartışmalar: [GitHub Discussions](https://github.com/your-username/ezan-app/discussions)

## Katkı 🤝

Katkılarınız çok hoş geldiniz! Lütfen bir branch oluşturup pull request gönderin.

## Bilgiler ℹ️

- 🕌 **Namaz Vakitleri Kaynağı**: Aladhan API (İslami kuruluş)
- 📍 **Konumlar**: 12+ Türk şehri (otomatik GPS desteği)
- 🌍 **Dil**: Türkçe arayüz

---

**Version**: 1.0.0  
**Last Updated**: 2026-07-22  
**Developer**: Made with ❤️
