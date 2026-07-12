class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String type; // 'application', 'message', 'system'
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}
