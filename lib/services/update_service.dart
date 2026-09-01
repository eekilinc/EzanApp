import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_version.dart';
import '../models/app_update_info.dart';
import '../providers/settings_provider.dart';

class UpdateService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'EzanApp-${AppVersion.version}',
      },
    ),
  );

  static const String _keyLastCheckTimestamp = 'last_update_check_time';
  static const int _checkIntervalHours = 6;

  /// Compares two semantic version strings (e.g. "5.1.0" vs "5.0.0").
  /// Returns true if [latest] is strictly greater than [current].
  static bool isNewerVersion(String latest, String current) {
    if (latest.isEmpty || current.isEmpty) return false;

    // Clean any leading 'v' or build metadata like '+80'
    final cleanLatest = latest.replaceAll(RegExp(r'^[vV]'), '').split('+').first.trim();
    final cleanCurrent = current.replaceAll(RegExp(r'^[vV]'), '').split('+').first.trim();

    final latestParts = cleanLatest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLen = latestParts.length > currentParts.length ? latestParts.length : currentParts.length;

    while (latestParts.length < maxLen) {
      latestParts.add(0);
    }
    while (currentParts.length < maxLen) {
      currentParts.add(0);
    }

    for (int i = 0; i < maxLen; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }

    return false;
  }

  /// Checks GitHub Releases API for new updates.
  /// If [force] is false, throttles requests to at most once every 6 hours.
  static Future<AppUpdateInfo?> checkForUpdates({bool force = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!force) {
        final lastCheck = prefs.getInt(_keyLastCheckTimestamp) ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        final hoursSinceLastCheck = (now - lastCheck) / (1000 * 60 * 60);

        if (hoursSinceLastCheck < _checkIntervalHours) {
          return null; // Throttled
        }
      }

      final response = await _dio.get<Map<String, dynamic>>(
        AppVersion.latestReleaseApiUrl,
      );

      if (response.statusCode == 200 && response.data != null) {
        await prefs.setInt(_keyLastCheckTimestamp, DateTime.now().millisecondsSinceEpoch);

        final updateInfo = AppUpdateInfo.fromJson(
          json: response.data!,
          currentVersion: AppVersion.version,
          isNewerVersion: isNewerVersion,
        );

        return updateInfo;
      }
    } catch (_) {
      // Network failure or rate limit
    }
    return null;
  }

  /// Opens the APK download URL or GitHub Release page in browser/system installer.
  static Future<bool> launchDownload(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }

  /// Displays the interactive "New Version Available" dialog.
  static void showUpdateDialog({
    required BuildContext context,
    required AppUpdateInfo updateInfo,
    required SettingsProvider settingsProvider,
  }) {
    final primaryColor = settingsProvider.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.system_update_alt, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    settingsProvider.tr('new_version_available'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        'v${updateInfo.latestVersion}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${settingsProvider.tr('current_version')}: v${updateInfo.currentVersion})',
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (updateInfo.releaseNotes.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    settingsProvider.tr('update_notes'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        updateInfo.releaseNotes,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                settingsProvider.tr('later'),
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final targetUrl = updateInfo.apkDownloadUrl ?? updateInfo.releaseHtmlUrl;
                await launchDownload(targetUrl);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(
                settingsProvider.tr('update_now'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Manually checks for updates with a loading overlay and shows result.
  static Future<void> performManualUpdateCheck({
    required BuildContext context,
    required SettingsProvider settingsProvider,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final checkingText = settingsProvider.tr('checking_for_updates');
    final upToDateText = settingsProvider.tr('app_is_up_to_date').replaceAll('{version}', AppVersion.version);
    final errorText = settingsProvider.tr('update_check_error');

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(checkingText)),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    final updateInfo = await checkForUpdates(force: true);

    if (context.mounted) {
      if (updateInfo != null && updateInfo.isUpdateAvailable) {
        showUpdateDialog(
          context: context,
          updateInfo: updateInfo,
          settingsProvider: settingsProvider,
        );
      } else if (updateInfo != null && !updateInfo.isUpdateAvailable) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(upToDateText),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorText),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
