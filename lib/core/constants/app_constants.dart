class AppConstants {
  AppConstants._();

  static const String appName = 'ALU Spark';
  static const String appTagline = 'Ignite Your Career Journey';

  /// The platform administrator email address.
  static const String adminEmail = 'ngabirediane02@gmail.com';

  /// Official ALU email domains. All registrations must use one of these.
  static const List<String> aluEmailDomains = [
    'alustudent.com',
    'alueducation.com',
  ];

  static bool isAluEmail(String email) {
    final lower = email.trim().toLowerCase();
    return aluEmailDomains.any((d) => lower.endsWith('@$d'));
  }

  static bool isAdminEmail(String email) =>
      email.trim().toLowerCase() == adminEmail.toLowerCase();

  /// Validates a URL string (must start with http:// or https://).
  static bool isValidUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}
