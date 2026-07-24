class PlatformStats {
  final int totalStudents;
  final int totalFounders;
  final int totalOpportunities;
  final int totalApplications;
  final Map<String, int> applicationsByStatus;
  final Map<String, int> opportunitiesByCategory;

  PlatformStats({
    required this.totalStudents,
    required this.totalFounders,
    required this.totalOpportunities,
    required this.totalApplications,
    required this.applicationsByStatus,
    required this.opportunitiesByCategory,
  });
}
