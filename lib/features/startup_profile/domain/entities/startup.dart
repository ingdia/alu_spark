class Startup {
  final String id;
  final String name;
  final String tagline;
  final String industry;
  final String description;
  final String founderId;
  final String founderName;
  final List<Map<String, String>> teamMembers;
  final int openRolesCount;
  final bool isVerified;
  final DateTime createdAt;

  Startup({
    required this.id,
    required this.name,
    required this.tagline,
    required this.industry,
    required this.description,
    required this.founderId,
    required this.founderName,
    required this.teamMembers,
    this.openRolesCount = 0,
    this.isVerified = false,
    required this.createdAt,
  });
}
