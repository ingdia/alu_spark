class UrlUtils {
  /// Converts share URLs from common providers into direct-access URLs.
  ///
  /// Supported:
  /// - Google Drive: /file/d/{id}/view  →  /uc?export=view&id={id}
  /// - Dropbox: ?dl=0  →  ?raw=1
  /// - OneDrive: 1drv.ms / onedrive.live.com share links  →  embed direct
  /// - GitHub: /blob/ paths  →  raw.githubusercontent.com
  /// - Everything else: returned as-is.
  static String normalizeImageUrl(String url) {
    return _normalize(url, forDownload: false);
  }

  /// Same normalization but forces download mode where applicable (for CVs).
  static String normalizeCvUrl(String url) {
    return _normalize(url, forDownload: true);
  }

  static String _normalize(String url, {required bool forDownload}) {
    final trimmed = url.trim();

    // Google Drive: https://drive.google.com/file/d/{id}/view?...
    final driveMatch = RegExp(
            r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)')
        .firstMatch(trimmed);
    if (driveMatch != null) {
      final id = driveMatch.group(1)!;
      return forDownload
          ? 'https://drive.google.com/uc?export=download&id=$id'
          : 'https://drive.google.com/uc?export=view&id=$id';
    }

    // Dropbox: ?dl=0 or ?dl=1  →  ?raw=1
    if (trimmed.contains('dropbox.com')) {
      return trimmed
          .replaceAll('?dl=0', '?raw=1')
          .replaceAll('?dl=1', '?raw=1')
          .replaceAll('&dl=0', '&raw=1')
          .replaceAll('&dl=1', '&raw=1');
    }

    // GitHub blob: /blob/  →  raw.githubusercontent.com
    if (trimmed.contains('github.com') && trimmed.contains('/blob/')) {
      return trimmed
          .replaceFirst('github.com', 'raw.githubusercontent.com')
          .replaceFirst('/blob/', '/');
    }

    // OneDrive: already works as-is for embed; return unchanged
    return trimmed;
  }
}
