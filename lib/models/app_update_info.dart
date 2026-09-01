class AppUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String releaseTag;
  final String releaseTitle;
  final String releaseNotes;
  final String? apkDownloadUrl;
  final String releaseHtmlUrl;
  final bool isUpdateAvailable;
  final DateTime? publishedAt;

  const AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseTag,
    required this.releaseTitle,
    required this.releaseNotes,
    required this.apkDownloadUrl,
    required this.releaseHtmlUrl,
    required this.isUpdateAvailable,
    this.publishedAt,
  });

  factory AppUpdateInfo.fromJson({
    required Map<String, dynamic> json,
    required String currentVersion,
    required bool Function(String latest, String current) isNewerVersion,
  }) {
    final tagName = (json['tag_name'] as String? ?? '').trim();
    final cleanLatest = tagName.replaceAll(RegExp(r'^[vV]'), '').trim();
    final title = json['name'] as String? ?? tagName;
    final body = json['body'] as String? ?? '';
    final htmlUrl = json['html_url'] as String? ?? 'https://github.com/eekilinc/EzanApp/releases';
    final publishedStr = json['published_at'] as String?;
    final publishedAt = publishedStr != null ? DateTime.tryParse(publishedStr) : null;

    String? apkUrl;
    final assets = json['assets'] as List<dynamic>?;
    if (assets != null) {
      for (final asset in assets) {
        if (asset is Map<String, dynamic>) {
          final name = (asset['name'] as String? ?? '').toLowerCase();
          final downloadUrl = asset['browser_download_url'] as String?;
          if (name.endsWith('.apk') && downloadUrl != null) {
            apkUrl = downloadUrl;
            break;
          }
        }
      }
    }

    // Fallback direct tag link if no asset found
    apkUrl ??= 'https://github.com/eekilinc/EzanApp/releases/download/$tagName/EzanApp-$tagName.apk';

    final isAvailable = isNewerVersion(cleanLatest, currentVersion);

    return AppUpdateInfo(
      currentVersion: currentVersion,
      latestVersion: cleanLatest.isNotEmpty ? cleanLatest : currentVersion,
      releaseTag: tagName,
      releaseTitle: title,
      releaseNotes: body,
      apkDownloadUrl: apkUrl,
      releaseHtmlUrl: htmlUrl,
      isUpdateAvailable: isAvailable,
      publishedAt: publishedAt,
    );
  }
}
