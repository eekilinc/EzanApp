# Ezan Hatırlatıcı v1.7.0 - Release Notes

**Tarih**: 2026-07-22

## 🎉 Sürüm 1.7.0 Güncellemeleri

- 🕌 **2 Farklı Özgün İnsan Sesli Ezan Kaydı**: Mekke Ezanı (`adhan_makkah.mp3` - 259KB) ve Medine Ezanı (`adhan_madinah.mp3` - 668KB) olarak tamamen farklı iki makamda canlı ezan ses kaydı entegre edildi.
- 🔔 **Android Ses Kanalı Kilidi & Test Bildirimi Düzeltmesi**: Android 8.0+ bildirim kanalı kilitlenme sorunu çözüldü. Her ses seçeneği için özel güncel kanal ID'leri (`ezan_channel_makkah_v3`, `ezan_channel_madinah_v3` vb.) ve raw kaynak bağlandı. Test bildirimi ve zamanlanmış bildirimler cihazda anında seçilen ezan sesiyle çalışmaktadır.
- 🌍 **"Current Location" Türkçe Dil Çeviri Düzeltmesi**: GPS konumundan gelen `'Current Location'` ifadesi tespit edilerek Türkçe modda **"Mevcut Konum"**, İngilizce modda **"Current Location"** olarak dinamik çevrilmesi sağlandı.

---

# Ezan Hatırlatıcı v1.6.0 - Release Notes

**Tarih**: 2026-07-22

## 🎉 Sürüm 1.6.0 Güncellemeleri

- 🕌 **Gerçek İnsan Sesli Ezan & Android Native Raw Kaynağı**: `.wav` önceliği kaldırıldı, birincil oynatma hedefleri doğrudan Mekke ve Medine insan sesli MP3 kayıtları olarak sabitlendi. Ayrıca Android zamanlanmış bildirimlerinde seslerin varsayılana düşmemesi için `android/app/src/main/res/raw/` dizinine MP3 kaynakları tanımlandı.
- 📱 **Taşmasız Esnek Konum Çubuğu (Responsive Bar)**: Ana ekrandaki `Konum | Kıble | Değiştir` alanı responsive (`Flexible`, sıkı dolgulu butonlar & `TextOverflow.ellipsis`) yapıya geçirilerek küçük ekranlarda ve İngilizce metinlerde yaşanan `RenderFlex` taşmaları tamamen engellendi.
- 🎨 **Aydınlık ☀️ & Karanlık 🌙 Tema Desteği**: `SettingsProvider` altyapısına Tema Modu (`Sistem 📱`, `Aydınlık ☀️`, `Karanlık 🌙`) seçeneği eklendi. Ayarlar ekranından anında tema değiştirilebilir.
- 🌍 **Kusursuz Dil Çevirileri**: Ana Ekran, Vakit Kartları, Kıble Pusulası, Ayarlar ve Hakkında ekranındaki tüm metinler Türkçe 🇹🇷 ve İngilizce 🇬🇧 olarak kusursuzlaştırıldı.

---

# Ezan Hatırlatıcı v1.5.0 - Release Notes

**Tarih**: 2026-07-22

## 🎉 Sürüm 1.5.0 Güncellemeleri

- 🕌 **Gerçek İnsan Sesli Ezan Kayıtları**: Yapay tonlar yerine `assets/sounds/` içerisindeki gerçek Mekke-i Mükerreme ve Medine-i Münevvere insan sesli ezan okumaları (`adhan_makkah.mp3` & `adhan_madinah.mp3`) bağlandı.
- 🌍 **Türkçe & İngilizce Çift Dil Desteği**: `SettingsProvider` altyapısı ile Türkçe 🇹🇷 ve İngilizce 🇬🇧 dil desteği entegre edildi. Tüm namaz vakitleri, sayaçlar, ayarlar, bildirimler ve Hakkında ekranı seçilen dile göre anında güncellenir.
- ℹ️ **Yenilenen & Zenginleştirilmiş Hakkında Ekranı**: Sürüm rozetleri (`v1.5.0`), öne çıkan özellikler kartları, Aladhan API & Haramain Audio veri kaynağı bilgileri ve kullanıcı değerlendirme butonları ile Hakkında ekranı baştan tasarlandı.
- 🎨 **Göz Alıcı Arayüz Yenilemesi**: Yeşil degrade tonlar, cam efektli (glassmorphism) sayaç kartları ve yenilenen modern Material 3 tipografisi ile kullanıcı deneyimi en üst seviyeye taşındı.

---

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
