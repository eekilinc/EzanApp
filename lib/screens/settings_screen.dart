import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/prayer_provider.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';
import '../constants/reminders.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isPlayingAudio = false;

  void _updateNotifications(SettingsProvider settingsProvider) {
    context.read<PrayerProvider>().scheduleNotifications(
          customReminderMinutes: settingsProvider.reminderMinutes,
          soundEnabled: settingsProvider.soundEnabled,
          vibrationEnabled: settingsProvider.vibrationEnabled,
        );
  }

  Future<void> _toggleAudioPreview(String soundKey) async {
    final audioService = AudioService();
    if (_isPlayingAudio) {
      await audioService.stop();
      setState(() {
        _isPlayingAudio = false;
      });
    } else {
      setState(() {
        _isPlayingAudio = true;
      });
      await audioService.playNotificationSound(soundKey);
    }
  }

  @override
  void dispose() {
    AudioService().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header: Notification Settings
                  Text(
                    'Bildirim Ayarları 🔔',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Sound settings
                  SwitchListTile(
                    title: const Text('Bildirim Sesi'),
                    subtitle: const Text('Vakit yaklaştığında sesli uyarı ver'),
                    value: settingsProvider.soundEnabled,
                    activeTrackColor: Colors.green.shade400,
                    onChanged: (value) async {
                      await settingsProvider.setSoundEnabled(value);
                      _updateNotifications(settingsProvider);
                    },
                  ),
                  const Divider(),

                  // Vibration settings
                  SwitchListTile(
                    title: const Text('Titreşim'),
                    subtitle: const Text('Bildirim geldiğinde cihazı titreştir'),
                    value: settingsProvider.vibrationEnabled,
                    activeTrackColor: Colors.green.shade400,
                    onChanged: (value) async {
                      await settingsProvider.setVibrationEnabled(value);
                      _updateNotifications(settingsProvider);
                    },
                  ),
                  const Divider(),

                  // Notification Sound Selection Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bildirim Sesi Seçimi',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Namaz vakti veya hatırlatmada çalacak olan sesi tercih edin:',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 12),

                        // List of available audio sounds
                        ...[
                          {
                            'key': 'adhan_makkah',
                            'title': 'Mekke Ezanı',
                            'subtitle': 'Klasik ve heybetli Mekke-i Mükerreme Ezanı',
                            'icon': Icons.mosque,
                            'color': Colors.green,
                          },
                          {
                            'key': 'adhan_madinah',
                            'title': 'Medine Ezanı',
                            'subtitle': 'Huzur veren Medine-i Münevvere Ezanı',
                            'icon': Icons.brightness_3,
                            'color': Colors.lightGreen,
                          },
                          {
                            'key': 'ney',
                            'title': 'Huzurlu Ney Tonu',
                            'subtitle': 'Yumuşak ve dinlendirici enstrümantal ses',
                            'icon': Icons.music_note,
                            'color': Colors.teal,
                          },
                          {
                            'key': 'beep',
                            'title': 'Kısa Bip Sesi',
                            'subtitle': 'Sade ve kısa uyarı tonu',
                            'icon': Icons.volume_up,
                            'color': Colors.amber,
                          },
                        ].map((sound) {
                          final soundKey = sound['key'] as String;
                          final isSelected = settingsProvider.notificationSound == soundKey;
                          final soundIcon = sound['icon'] as IconData;
                          final iconColor = sound['color'] as MaterialColor;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: isSelected ? 3 : 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isSelected ? Colors.green.shade600 : Colors.transparent,
                                width: isSelected ? 2 : 0,
                              ),
                            ),
                            color: isSelected ? Colors.green.shade50 : Colors.white,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: iconColor.shade100,
                                child: Icon(soundIcon, color: iconColor.shade800),
                              ),
                              title: Text(
                                sound['title'] as String,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.green.shade900 : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                sound['subtitle'] as String,
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      (_isPlayingAudio && settingsProvider.notificationSound == soundKey)
                                          ? Icons.stop_circle
                                          : Icons.play_circle_fill,
                                      color: Colors.green.shade700,
                                      size: 32,
                                    ),
                                    onPressed: () => _toggleAudioPreview(soundKey),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_off,
                                    color: isSelected
                                        ? Colors.green.shade700
                                        : Colors.grey.shade400,
                                  ),
                                ],
                              ),
                              onTap: () async {
                                await settingsProvider.setNotificationSound(soundKey);
                                _updateNotifications(settingsProvider);
                              },
                            ),
                          );
                        }),

                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await NotificationService().showTestNotification(
                                soundEnabled: settingsProvider.soundEnabled,
                                vibrationEnabled: settingsProvider.vibrationEnabled,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Test bildirimi gönderildi! 🔔'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.send, size: 18),
                            label: const Text('Test Bildirimi Gönder'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 32, thickness: 1.5),

                  // Reminder times section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Hatırlatma Süreleri ⏰',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Text(
                    'Her vakitten ne kadar süre önce bildirim almak istediğinizi belirleyin:',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),

                  ...prayerNames.map((prayer) {
                    final displayName = prayerDisplayNames[prayer] ?? prayer;
                    final currentMinutes =
                        settingsProvider.getReminderMinutes(prayer);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    currentMinutes == 0
                                        ? 'Vakit girince'
                                        : '$currentMinutes dakika önce',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: currentMinutes.toDouble(),
                              min: 0,
                              max: 60,
                              divisions: 12,
                              activeColor: Colors.green.shade700,
                              label: currentMinutes == 0
                                  ? 'Tam Vaktinde'
                                  : '$currentMinutes dk',
                              onChanged: (value) {
                                settingsProvider.setReminderMinutes(
                                  prayer,
                                  value.toInt(),
                                );
                              },
                              onChangeEnd: (value) {
                                _updateNotifications(settingsProvider);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const Divider(height: 32),

                  // About Section Button
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.green),
                    title: const Text('Hakkında'),
                    subtitle: const Text('Uygulama sürümü, kaynaklar ve bilgiler'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/about');
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
