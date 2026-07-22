import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../constants/reminders.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
                    onChanged: (value) {
                      settingsProvider.setSoundEnabled(value);
                    },
                  ),
                  const Divider(),

                  // Vibration settings
                  SwitchListTile(
                    title: const Text('Titreşim'),
                    subtitle: const Text('Bildirim titreşimini etkinleştir'),
                    value: settingsProvider.vibrationEnabled,
                    onChanged: (value) {
                      settingsProvider.setVibrationEnabled(value);
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
                                '$currentMinutes dakika',
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
                            onChanged: (value) {
                              settingsProvider.setReminderMinutes(
                                prayer,
                                value.toInt(),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),

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
