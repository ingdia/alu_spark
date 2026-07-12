class Bookmark {
  final String id;
  final String userId;
  final String opportunityId;
  final String opportunityTitle;
  final String startupName;
  final String category;
  final String location;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.userId,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupName,
    required this.category,
    required this.location,
    required this.createdAt,
  });
}
