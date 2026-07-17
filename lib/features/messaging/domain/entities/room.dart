class Room {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final List<String> memberIds;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int memberCount;

  const Room({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.memberIds,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.memberCount,
  });

  bool isMember(String userId) => memberIds.contains(userId);
}
