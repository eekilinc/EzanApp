import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkında'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Logo Image
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.mosque,
                    size: 64,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ezan Hatırlatıcı',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sürüm 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Feature Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uygulama Hakkında',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ezan Hatırlatıcı, bulunduğunuz konuma veya seçeceğiniz şehre göre namaz vakitlerini tam zamanında öğrenmenizi ve vakit girmeden önce özelleştirilebilir bildirimler almanızı sağlayan kullanıcı dostu bir Flutter uygulamasıdır.',
                      style: TextStyle(height: 1.4),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Key features list
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Öne Çıkan Özellikler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureRow(Icons.my_location, 'Otomatik GPS & Şehir Seçimi'),
                    _buildFeatureRow(Icons.timer, 'Canlı Geri Sayım Sayacı'),
                    _buildFeatureRow(Icons.notifications_active, 'Özelleştirilebilir Hatırlatıcılar (0-60 dk)'),
                    _buildFeatureRow(Icons.wifi_off, 'Çevrimdışı (Offline) Önbellekleme'),
                    _buildFeatureRow(Icons.volume_up, 'Ezan & Uyarı Sesi Desteği'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Source & Credits Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Namaz vakitleri Aladhan API altyapısı kullanılarak hesaplanmaktadır.',
                        style: TextStyle(fontSize: 13, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              '© 2026 Ezan Hatırlatıcı. Tüm Hakları Saklıdır.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
