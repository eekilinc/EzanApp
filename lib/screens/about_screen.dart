import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchGitHubUrl(BuildContext context) async {
    final Uri url = Uri.parse('https://github.com/eekilinc/EzanApp');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('https://github.com/eekilinc/EzanApp')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('https://github.com/eekilinc/EzanApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final primaryColor = settingsProvider.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(settingsProvider.tr('about')),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header Gradient Container with Glowing Mosque Logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [primaryColor.withValues(alpha: 0.9), const Color(0xFF0F172A)]
                      : [primaryColor, primaryColor.withValues(alpha: 0.8)],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // App Icon with Glowing Ambient Shadow
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: primaryColor,
                        child: const Icon(
                          Icons.mosque,
                          size: 48,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    settingsProvider.tr('app_title'),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${settingsProvider.tr('version')} 3.3.0 ULTIMATE',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // App Overview Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.verified, color: primaryColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  settingsProvider.tr('app_title'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            settingsProvider.appLanguage == 'en'
                                ? 'EzanApp is a state-of-the-art, 100% offline-ready Islamic prayer assistant. Designed with rich modern aesthetics, precision Qibla compass, vocal Haramain Adhans, full-screen lock screen alarm interface, and zero-delay local notifications.'
                                : 'Ezan Vakti & İslami Hatırlatıcı, modern tasarımı, hassas Kıble pusulası, kilit ekranı ezan uyarısı, özgürce ayarlanabilen hatırlatıcı sesleri, sesli Zikirmatik ve 81 il için 0ms hızlı çevrimdışı vakit desteği ile geliştirilmiş eksiksiz dijital ibadet rehberinizdir.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: isDark ? Colors.grey.shade300 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Interactive Feature Showcase Grid
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settingsProvider.tr('features'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildModernFeatureTile(
                            icon: Icons.alarm_on,
                            color: Colors.amber.shade800,
                            title: 'Tam Ekran Kilit Ekranı Ezan Uyarısı',
                            desc: 'Vakit geldiğinde kilitli ekranda bile otomatik uyanan özel alarm ekranı.',
                            isDark: isDark,
                          ),
                          _buildModernFeatureTile(
                            icon: Icons.mosque,
                            color: Colors.green.shade700,
                            title: 'Mekke & Medine Orijinal Ezan Kayıtları',
                            desc: 'Mekke, Medine, Mescid-i Aksa, Kahire ve İstanbul makamlarında ezan sesleri.',
                            isDark: isDark,
                          ),
                          _buildModernFeatureTile(
                            icon: Icons.compass_calibration,
                            color: Colors.teal.shade700,
                            title: 'İpek Yumuşaklığında Hassas Kıble Pusulası',
                            desc: 'Sensör filtreli, titremeyen ve dokunsal titreşimle yön bulan pusula.',
                            isDark: isDark,
                          ),
                          _buildModernFeatureTile(
                            icon: Icons.fingerprint,
                            color: Colors.purple.shade700,
                            title: 'Sesli Zikirmatik & Esmaül Hüsna',
                            desc: 'Allah\'ın 99 ismi, sesli sayıcı, hedef belirleme ve kaydetme modu.',
                            isDark: isDark,
                          ),
                          _buildModernFeatureTile(
                            icon: Icons.widgets,
                            color: Colors.blue.shade700,
                            title: 'Android Ana Ekran Canlı Widget\'ı',
                            desc: 'Telefon ana ekranında sonraki vakit ve canlı geri sayım takibi.',
                            isDark: isDark,
                          ),
                          _buildModernFeatureTile(
                            icon: Icons.offline_pin,
                            color: Colors.indigo.shade700,
                            title: '0ms Anında Çevrimdışı Önbellek Desteği',
                            desc: 'İnternet olmasa dahi tüm yıllık vakitleri diskte saklar ve anında yükler.',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Open Source & GitHub Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settingsProvider.tr('data_source'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.cloud_sync, color: Colors.blue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  settingsProvider.tr('aladhan_api'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.grey.shade300 : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () => _launchGitHubUrl(context),
                              icon: const Icon(Icons.code, size: 22),
                              label: Text(
                                settingsProvider.tr('github_repo'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                                foregroundColor: Colors.amber,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(color: Colors.amber, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Blessings Footer
                  Column(
                    children: [
                      const Icon(Icons.favorite, color: Colors.redAccent, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        settingsProvider.appLanguage == 'en'
                            ? 'May Allah accept your prayers and good deeds. 🤲'
                            : 'Rabbim kılacağınız namazları ve dualarınızı kabul eylesin. 🤲',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '© 2026 EzanApp Team • All Rights Reserved',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFeatureTile({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
