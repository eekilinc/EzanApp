# Ezan Hatırlatıcı v1.0.0 - Release Notes

**Date**: 2026-07-22

## 🎉 Initial Release

Ezan Hatırlatıcı uygulamasının ilk resmi sürümü.

### ✨ Özellikler

- 📍 **GPS + Şehir Seçimi**: Otomatik konum algılama veya 12+ Türk şehrinden seçim
- 🕌 **5 Vakit Namaz**: Sabah, Öğle, İkindi, Akşam, Yatsı namazlarının saatleri
- 🔔 **Hatırlatma Sistemi**: Her namaz için özelleştirilebilir hatırlatma (0-60 dakika)
- 🎵 **Ezan Sesi**: Namaz saati başında ezan sesi oynatma desteği
- ⚙️ **Ayarlar**: Ses, titreşim, ve hatırlatma sürelerini kişiselleştir
- 🌙 **Kullanıcı Dostu Arayüz**: Temiz, Türkçe arayüz

### 🛠️ Teknik Bilgiler

- **Platform**: Android 5.0+
- **Framework**: Flutter 3.38.5
- **API**: Aladhan (ücretsiz, kimlik doğrulama yok)
- **Varsayılan Hatırlatmalar**:
  - Fajr (Sabah): 20 dakika önce
  - Dhuhr (Öğle): 5 dakika önce
  - Asr (İkindi): 5 dakika önce
  - Maghrib (Akşam): Hemen
  - Isha (Yatsı): 5 dakika önce

### 📥 Kurulum

APK dosyasını indirip Android cihazınıza yükleyin:
```bash
adb install ezan-app-v1.0.0.apk
```

Veya Google Play Store'dan (yakında)

### 🐛 Bilinen Sorunlar

- Ezan sesi dosyası uygulamaya dahil edilmemiş (manuel ekleme gerekli)
- Background execution Windows/Mac'te test edilmemiş

### 🔮 İleriki Sürümler

- [ ] Google Play Store yayını
- [ ] Dark mode tema
- [ ] Widget desteği
- [ ] Hijri takvim entegrasyonu
- [ ] Çoklu dil desteği
- [ ] Background execution optimization

### 📝 Lisans

MIT License - Özgür kullanım, kopyalama, dağıtım

---

**Download**: [ezan-app-v1.0.0.apk](ezan-app-v1.0.0.apk) (51.4 MB)
