# Ezan Hatırlatıcı v1.4.1 - Release Notes

**Tarih**: 2026-07-22

## 🎉 Sürüm 1.4.1 Güncellemeleri

- 🕌 **Gerçek Ezan Sesleri**: Mekke-i Mükerreme ve Medine-i Münevvere makamlarındaki gerçek melodik ezan okumaları (`adhan_makkah.wav/mp3` ve `adhan_madinah.wav/mp3`) eklendi. Ses oynatma servisindeki format/yol uyumsuzlukları tam olarak çözüldü.
- 🧭 **Hassas Kıble Pusulası & Canlı Hizalama**: Kabe kerte açısı hesaplaması standart küresel trigonometri formülü ile güncellendi. Telefonun tutulduğu yöne göre kadran dönmesi ve tam Kıble açısına çevrildiğinde beliren **"Kıble Yönündesiniz! 🕌"** canlı hizalanma uyarısı eklendi.

---

# Ezan Hatırlatıcı v1.4.0 - Release Notes

**Tarih**: 2026-07-22

## 🎉 Sürüm 1.4.0 Güncellemeleri

- 📱 **Özel Uygulama İkonu (Launcher Icon)**: Telefonunuzda varsayılan Flutter logosu yerine yeni Hilal & Cami temalı `ic_launcher` simgesi tanımlandı.
- 🎵 **Çeşitlendirilmiş MP3 Ses Tonları & Modern Ses Paneli**: Mekke Ezanı, Medine Ezanı, Huzurlu Ney Tonu ve Bip Uyarısı ses seçenekleri eklendi. Ayarlar panelinde her ses için inline oynatma/durdurma ve görsel vurgu kartları tasarlandı.
- 🧭 **Kıble Pusulası (Qibla Compass)**: Konumunuza göre Kabe açısını ve mesafesini hassas matematiksel algoritmalarla hesaplayan interaktif Kıble Pusulası ekranı eklendi.
- 📖 **Günün Ayet & Hadis Kartı**: Ana ekrana her gün yenilenen ilham verici Ayet ve Hadis bölümü eklendi.
- 🎨 **Modern UI Overhaul**: Degrade renk tonları, kart vurguları ve Material 3 tipografisi ile kullanıcı deneyimi iyileştirildi.

---

# Ezan Hatırlatıcı v1.3.1 - Release Notes

**Tarih**: 2026-07-22

## 🎉 Sürüm 1.3.1 Güncellemeleri

- 🎚️ **Slider Düzeltmeleri**: Hatırlatıcı süre slider'larında oluşan sabit harita kilitlenme sorunu çözüldü, süre ayarlamaları artık sorunsuz çalışıyor.
- 🔔 **Bildirim Saat Dilimi ve İzin İyileştirmeleri**: `Europe/Istanbul` saat dilimi ve Android bildirim kanalı ilklendirilerek bildirimlerin tam zamanında tetiklenmesi sağlandı. Ayrıca anında deneme için **"Test Bildirimi"** butonu eklendi.
- 🎵 **Bildirim Sesi Seçeneği ve Ses Önizleme**: Tam Ezan Sesi, Klasik Bildirim Tonu ve Kısa Bip seçenekleri eklendi. Seçilen sesi anında dinlemek için **"Sesi Dinle / Test Et"** butonu entegre edildi.

---

# Ezan Hatırlatıcı v1.3.0 - Release Notes

**Tarih**: 2026-07-22

## 🎉 Sürüm 1.3.0 Güncellemeleri

Ezan Hatırlatıcı uygulamasının en güncel, gelişmiş ve stabil sürümü.

### ✨ Yenilikler ve İyileştirmeler

- ⏱️ **Canlı Geri Sayım Sayacı**: Sonraki vakte kalan süre "Saat:Dakika:Saniye" cinsinden canlı olarak akmaktadır.
- 🔔 **Tam Zamanlı Dinamik Bildirimler**: 0-60 dk arasındaki hatırlatma ve ses/titreşim ayarları değiştirildiği anda bildirimler otomatik yeniden planlanır.
- 🕌 **Yeni Uygulama Logosu & İkonu**: Modern Hilal & Cami temalı yeni logo entegrasyonu.
- 📶 **Çevrimdışı (Offline) Önbellekleme**: İnternet bağlantısı kesildiğinde önbellekteki verilerle çalışmaya devam eder.
- ℹ️ **"Hakkında" Ekranı**: Uygulama sürümü, özellikler ve kaynak bilgisi sunan yeni ekran.
- 🐛 **API Timestamp & İzin Düzeltmeleri**: Android 12+ ve 13+ exact alarm ve bildirim izinleri eklendi, güncel tarih zaman damgası düzeltildi.

---

# Ezan Hatırlatıcı v1.0.0 - Initial Release Notes

- 📍 **GPS + Şehir Seçimi**: Otomatik konum algılama veya 12+ Türk şehrinden seçim
- 🕌 **5 Vakit Namaz**: Sabah, Öğle, İkindi, Akşam, Yatsı namazlarının saatleri
- 🔔 **Hatırlatma Sistemi**: Her namaz için özelleştirilebilir hatırlatma (0-60 dakika)
- 🎵 **Ezan Sesi**: Namaz saati başında ezan sesi oynatma desteği
