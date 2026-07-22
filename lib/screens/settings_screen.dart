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
          soundKey: settingsProvider.notificationSound,
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
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settingsProvider.tr('settings')),
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
                  // Language Selection Card
                  Text(
                    '${settingsProvider.tr('language')} 🌍',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: Center(child: Text(settingsProvider.tr('turkish'))),
                              selected: settingsProvider.appLanguage == 'tr',
                              selectedColor: Colors.green.shade100,
                              labelStyle: TextStyle(
                                fontWeight: settingsProvider.appLanguage == 'tr'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: settingsProvider.appLanguage == 'tr'
                                    ? Colors.green.shade900
                                    : Colors.black87,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  settingsProvider.setAppLanguage('tr');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ChoiceChip(
                              label: Center(child: Text(settingsProvider.tr('english'))),
                              selected: settingsProvider.appLanguage == 'en',
                              selectedColor: Colors.green.shade100,
                              labelStyle: TextStyle(
                                fontWeight: settingsProvider.appLanguage == 'en'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: settingsProvider.appLanguage == 'en'
                                    ? Colors.green.shade900
                                    : Colors.black87,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  settingsProvider.setAppLanguage('en');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Theme Selection Card
                  Text(
                    settingsProvider.tr('theme_selection'),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: Center(child: Text(settingsProvider.tr('theme_system'))),
                              selected: settingsProvider.themeMode == ThemeMode.system,
                              selectedColor: Colors.green.shade100,
                              onSelected: (selected) {
                                if (selected) {
                                  settingsProvider.setThemeMode(ThemeMode.system);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: Center(child: Text(settingsProvider.tr('theme_light'))),
                              selected: settingsProvider.themeMode == ThemeMode.light,
                              selectedColor: Colors.green.shade100,
                              onSelected: (selected) {
                                if (selected) {
                                  settingsProvider.setThemeMode(ThemeMode.light);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: Center(child: Text(settingsProvider.tr('theme_dark'))),
                              selected: settingsProvider.themeMode == ThemeMode.dark,
                              selectedColor: Colors.green.shade100,
                              onSelected: (selected) {
                                if (selected) {
                                  settingsProvider.setThemeMode(ThemeMode.dark);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 28),

                  // Section Header: Notification Settings
                  Text(
                    settingsProvider.tr('notification_settings'),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Sound settings
                  SwitchListTile(
                    title: Text(settingsProvider.tr('notification_sound')),
                    subtitle: Text(settingsProvider.tr('notification_sound_desc')),
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
                    title: Text(settingsProvider.tr('vibration')),
                    subtitle: Text(settingsProvider.tr('vibration_desc')),
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
                        Text(
                          settingsProvider.tr('select_notification_sound'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settingsProvider.tr('select_sound_sub'),
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 12),

                        // List of available audio sounds
                        ...[
                          {
                            'key': 'adhan_makkah',
                            'titleKey': 'sound_makkah',
                            'subKey': 'sound_makkah_sub',
                            'icon': Icons.mosque,
                            'color': Colors.green,
                          },
                          {
                            'key': 'adhan_madinah',
                            'titleKey': 'sound_madinah',
                            'subKey': 'sound_madinah_sub',
                            'icon': Icons.brightness_3,
                            'color': Colors.lightGreen,
                          },
                          {
                            'key': 'adhan_istanbul',
                            'titleKey': 'sound_istanbul',
                            'subKey': 'sound_istanbul_sub',
                            'icon': Icons.account_balance,
                            'color': Colors.red,
                          },
                          {
                            'key': 'adhan_cairo',
                            'titleKey': 'sound_cairo',
                            'subKey': 'sound_cairo_sub',
                            'icon': Icons.explore,
                            'color': Colors.orange,
                          },
                          {
                            'key': 'adhan_aqsa',
                            'titleKey': 'sound_aqsa',
                            'subKey': 'sound_aqsa_sub',
                            'icon': Icons.location_city,
                            'color': Colors.cyan,
                          },
                          {
                            'key': 'ney',
                            'titleKey': 'sound_ney',
                            'subKey': 'sound_ney_sub',
                            'icon': Icons.music_note,
                            'color': Colors.teal,
                          },
                          {
                            'key': 'beep',
                            'titleKey': 'sound_beep',
                            'subKey': 'sound_beep_sub',
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
                                settingsProvider.tr(sound['titleKey'] as String),
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.green.shade900 : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                settingsProvider.tr(sound['subKey'] as String),
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
                              final success = await NotificationService().showTestNotification(
                                soundEnabled: settingsProvider.soundEnabled,
                                vibrationEnabled: settingsProvider.vibrationEnabled,
                                soundKey: settingsProvider.notificationSound,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? settingsProvider.tr('test_notification_sent')
                                          : (settingsProvider.appLanguage == 'en'
                                              ? 'Notification permission denied. Please enable notifications in Android Settings.'
                                              : 'Bildirim izni kapalı. Lütfen cihaz ayarlarınızdan izin verin.'),
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.send, size: 18),
                            label: Text(settingsProvider.tr('test_notification')),
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

                  // Asr School Selection Card
                  const SizedBox(height: 16),
                  Text(
                    settingsProvider.tr('asr_school'),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    settingsProvider.tr('asr_school_desc'),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: Center(child: Text(settingsProvider.tr('asr_standard'))),
                              selected: settingsProvider.asrSchool == 'standard',
                              selectedColor: Colors.green.shade100,
                              onSelected: (selected) {
                                if (selected) {
                                  settingsProvider.setAsrSchool('standard');
                                  context.read<PrayerProvider>().loadPrayerTimes(settingsProvider);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: Center(child: Text(settingsProvider.tr('asr_hanafi'))),
                              selected: settingsProvider.asrSchool == 'hanafi',
                              selectedColor: Colors.green.shade100,
                              onSelected: (selected) {
                                if (selected) {
                                  settingsProvider.setAsrSchool('hanafi');
                                  context.read<PrayerProvider>().loadPrayerTimes(settingsProvider);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 32, thickness: 1.5),

                  // Reminder times section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      settingsProvider.tr('reminder_times'),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    settingsProvider.tr('reminder_times_desc'),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),

                  ...prayerNames.map((prayer) {
                    final displayName = settingsProvider.tr(prayer.toLowerCase());
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
                                        ? settingsProvider.tr('on_time')
                                        : '$currentMinutes ${settingsProvider.tr("min_before")}',
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
                                  ? settingsProvider.tr('exact_time')
                                  : '$currentMinutes min',
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
                    title: Text(settingsProvider.tr('about')),
                    subtitle: Text('${settingsProvider.tr("app_title")} ${settingsProvider.tr("version")} 2.1.1'),
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
