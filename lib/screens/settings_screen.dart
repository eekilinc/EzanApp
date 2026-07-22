import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/prayer_provider.dart';
import '../constants/reminders.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _updateNotifications(SettingsProvider settingsProvider) {
    context.read<PrayerProvider>().scheduleNotifications(
          customReminderMinutes: settingsProvider.reminderMinutes,
          soundEnabled: settingsProvider.soundEnabled,
          vibrationEnabled: settingsProvider.vibrationEnabled,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.green,
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
                  // Sound settings
                  SwitchListTile(
                    title: const Text('Ses'),
                    subtitle: const Text('Bildirim sesini oynat'),
                    value: settingsProvider.soundEnabled,
                    onChanged: (value) async {
                      await settingsProvider.setSoundEnabled(value);
                      _updateNotifications(settingsProvider);
                    },
                  ),
                  const Divider(),

                  // Vibration settings
                  SwitchListTile(
                    title: const Text('Titreşim'),
                    subtitle: const Text('Bildirim titreşimini etkinleştir'),
                    value: settingsProvider.vibrationEnabled,
                    onChanged: (value) async {
                      await settingsProvider.setVibrationEnabled(value);
                      _updateNotifications(settingsProvider);
                    },
                  ),
                  const Divider(),

                  // Reminder times
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Hatırlatma Süreleri',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...prayerNames.map((prayer) {
                    final displayName = prayerDisplayNames[prayer] ?? prayer;
                    final currentMinutes =
                        settingsProvider.getReminderMinutes(prayer);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(displayName),
                              Text(
                                currentMinutes == 0 ? 'Vakit girince' : '$currentMinutes dakika önce',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: currentMinutes.toDouble(),
                            min: 0,
                            max: 60,
                            divisions: 12,
                            label: currentMinutes == 0 ? 'Tam Vaktinde' : '$currentMinutes dk',
                            onChanged: (value) async {
                              await settingsProvider.setReminderMinutes(
                                prayer,
                                value.toInt(),
                              );
                              _updateNotifications(settingsProvider);
                            },
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(),
                  const SizedBox(height: 8),

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
