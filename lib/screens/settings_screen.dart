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
          asrSchool: settingsProvider.asrSchool,
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

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    required bool isDark,
  }) {
    final themeColor = context.watch<SettingsProvider>().primaryColor;

    return ChoiceChip(
      label: Center(child: Text(label)),
      selected: selected,
      selectedColor: isDark ? themeColor.withValues(alpha: 0.4) : themeColor.withValues(alpha: 0.15),
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      side: BorderSide(
        color: selected
            ? (isDark ? themeColor : themeColor)
            : (isDark ? Colors.white10 : Colors.black12),
      ),
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.bold : FontWeight.w600,
        color: selected
            ? (isDark ? Colors.white : themeColor)
            : (isDark ? Colors.grey.shade300 : Colors.black87),
      ),
      onSelected: onSelected,
    );
  }

  Widget _buildColorChip({
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onSelected,
    required bool isDark,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color
              : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.white : (isDark ? Colors.white24 : Colors.black12),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.grey.shade300 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = settingsProvider.primaryColor;

    final cardBgColor = isDark ? const Color(0xFF18241B) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(settingsProvider.tr('settings')),
        backgroundColor: isDark ? const Color(0xFF0F1A11) : primaryColor,
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
                    color: cardBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildChoiceChip(
                              label: settingsProvider.tr('turkish'),
                              selected: settingsProvider.appLanguage == 'tr',
                              isDark: isDark,
                              onSelected: (selected) {
                                if (selected) {
                                  settingsProvider.setAppLanguage('tr');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildChoiceChip(
                              label: settingsProvider.tr('english'),
                              selected: settingsProvider.appLanguage == 'en',
                              isDark: isDark,
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

                  // Theme Selection Card (Light/Dark Mode)
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
                    color: cardBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildChoiceChip(
                              label: settingsProvider.tr('theme_system'),
                              selected: settingsProvider.themeMode == ThemeMode.system,
                              isDark: isDark,
                              onSelected: (selected) {
                                if (selected) {
                                  settingsProvider.setThemeMode(ThemeMode.system);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceChip(
                              label: settingsProvider.tr('theme_light'),
                              selected: settingsProvider.themeMode == ThemeMode.light,
                              isDark: isDark,
                              onSelected: (selected) {
                                if (selected) {
                                  settingsProvider.setThemeMode(ThemeMode.light);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildChoiceChip(
                              label: settingsProvider.tr('theme_dark'),
                              selected: settingsProvider.themeMode == ThemeMode.dark,
                              isDark: isDark,
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

                  const SizedBox(height: 16),

                  // Color Theme Selection Card (PRO Palettes)
                  Text(
                    settingsProvider.tr('color_theme'),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    settingsProvider.tr('color_theme_desc'),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    color: cardBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildColorChip(
                              label: settingsProvider.tr('theme_green'),
                              color: Colors.green.shade800,
                              selected: settingsProvider.colorTheme == 'green',
                              isDark: isDark,
                              onSelected: () => settingsProvider.setColorTheme('green'),
                            ),
                            const SizedBox(width: 8),
                            _buildColorChip(
                              label: settingsProvider.tr('theme_blue'),
                              color: Colors.indigo.shade800,
                              selected: settingsProvider.colorTheme == 'blue',
                              isDark: isDark,
                              onSelected: () => settingsProvider.setColorTheme('blue'),
                            ),
                            const SizedBox(width: 8),
                            _buildColorChip(
                              label: settingsProvider.tr('theme_teal'),
                              color: Colors.teal.shade800,
                              selected: settingsProvider.colorTheme == 'teal',
                              isDark: isDark,
                              onSelected: () => settingsProvider.setColorTheme('teal'),
                            ),
                            const SizedBox(width: 8),
                            _buildColorChip(
                              label: settingsProvider.tr('theme_crimson'),
                              color: Colors.red.shade900,
                              selected: settingsProvider.colorTheme == 'crimson',
                              isDark: isDark,
                              onSelected: () => settingsProvider.setColorTheme('crimson'),
                            ),
                            const SizedBox(width: 8),
                            _buildColorChip(
                              label: settingsProvider.tr('theme_amber'),
                              color: const Color(0xFFB78103),
                              selected: settingsProvider.colorTheme == 'amber',
                              isDark: isDark,
                              onSelected: () => settingsProvider.setColorTheme('amber'),
                            ),
                          ],
                        ),
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
                    activeTrackColor: primaryColor,
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
                    activeTrackColor: primaryColor,
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
                                color: isSelected ? primaryColor : Colors.transparent,
                                width: isSelected ? 2 : 0,
                              ),
                            ),
                            color: isSelected
                                ? (isDark ? primaryColor.withValues(alpha: 0.3) : primaryColor.withValues(alpha: 0.1))
                                : cardBgColor,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isDark ? iconColor.shade900.withValues(alpha: 0.5) : iconColor.shade100,
                                child: Icon(soundIcon, color: isDark ? iconColor.shade300 : iconColor.shade800),
                              ),
                              title: Text(
                                settingsProvider.tr(sound['titleKey'] as String),
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected
                                      ? (isDark ? Colors.white : primaryColor)
                                      : (isDark ? Colors.white : Colors.black87),
                                ),
                              ),
                              subtitle: Text(
                                settingsProvider.tr(sound['subKey'] as String),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      (_isPlayingAudio && settingsProvider.notificationSound == soundKey)
                                          ? Icons.stop_circle
                                          : Icons.play_circle_fill,
                                      color: primaryColor,
                                      size: 32,
                                    ),
                                    onPressed: () => _toggleAudioPreview(soundKey),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_off,
                                    color: isSelected
                                        ? primaryColor
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
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await NotificationService().scheduleTestNotificationIn10Seconds(
                                soundEnabled: settingsProvider.soundEnabled,
                                vibrationEnabled: settingsProvider.vibrationEnabled,
                                soundKey: settingsProvider.notificationSound,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      settingsProvider.appLanguage == 'en'
                                          ? 'Scheduled test alarm set for 10 seconds from now! Lock screen to test. ⏱️'
                                          : '10 saniyelik test ezanı kuruldu! Lütfen ekranı kapatıp 10 saniye bekleyin. ⏱️',
                                    ),
                                    duration: const Duration(seconds: 4),
                                    backgroundColor: Colors.amber.shade900,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.timer_outlined, size: 18),
                            label: Text(
                              settingsProvider.appLanguage == 'en'
                                  ? 'Test Scheduled Alarm (10s) ⏱️'
                                  : '10 Saniye Sonra Zamanlanmış Ezanı Test Et ⏱️',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await NotificationService().requestExactAlarmsPermission();
                              final isGranted = await NotificationService().isExactAlarmPermissionGranted();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isGranted
                                          ? (settingsProvider.appLanguage == 'en'
                                              ? 'Exact Alarm Permission is ACTIVE! ⏰'
                                              : 'Tam Vakit Alarm İzni AKTİF! ⏰')
                                          : (settingsProvider.appLanguage == 'en'
                                              ? 'Please enable Alarms & Reminders in system settings.'
                                              : 'Lütfen cihaz ayarlarınızdan Alarmlar ve Hatırlatıcılar iznini açın.'),
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.alarm_on, size: 18),
                            label: Text(settingsProvider.tr('request_exact_alarm')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? primaryColor : primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: primaryColor),
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
                    color: cardBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildChoiceChip(
                              label: settingsProvider.tr('asr_standard'),
                              selected: settingsProvider.asrSchool == 'standard',
                              isDark: isDark,
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
                            child: _buildChoiceChip(
                              label: settingsProvider.tr('asr_hanafi'),
                              selected: settingsProvider.asrSchool == 'hanafi',
                              isDark: isDark,
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
                      color: cardBgColor,
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: currentMinutes < 0
                                        ? (isDark ? Colors.amber.shade900.withValues(alpha: 0.5) : Colors.amber.shade100)
                                        : (isDark ? primaryColor.withValues(alpha: 0.4) : primaryColor.withValues(alpha: 0.1)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: currentMinutes < 0 ? Colors.amber.shade600 : Colors.transparent,
                                      width: currentMinutes < 0 ? 1 : 0,
                                    ),
                                  ),
                                  child: Text(
                                    currentMinutes == 0
                                        ? settingsProvider.tr('on_time')
                                        : (currentMinutes > 0
                                            ? '$currentMinutes ${settingsProvider.tr("min_before")}'
                                            : '${currentMinutes.abs()} ${settingsProvider.tr("min_after")} ⏱️'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: currentMinutes < 0
                                          ? (isDark ? Colors.amber.shade200 : Colors.amber.shade900)
                                          : (isDark ? Colors.white : primaryColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: currentMinutes.toDouble().clamp(-30.0, 60.0),
                              min: -30,
                              max: 60,
                              divisions: 18,
                              activeColor: currentMinutes < 0 ? Colors.amber.shade700 : primaryColor,
                              label: currentMinutes == 0
                                  ? settingsProvider.tr('exact_time')
                                  : (currentMinutes > 0
                                      ? '$currentMinutes dk önce'
                                      : '${currentMinutes.abs()} dk sonra'),
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
                    leading: Icon(Icons.info_outline, color: primaryColor),
                    title: Text(settingsProvider.tr('about'), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text('${settingsProvider.tr("app_title")} ${settingsProvider.tr("version")} 2.2.0', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
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
