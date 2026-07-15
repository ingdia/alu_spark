class Conversation {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantRoles;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCounts;
  final String? opportunityId;
  final String? opportunityTitle;
  final String? applicationId;
  /// userId → last time they were seen active
  final Map<String, DateTime> lastSeen;
  /// userIds currently typing
  final List<String> typingUsers;

  const Conversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantRoles,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCounts = const {},
    this.opportunityId,
    this.opportunityTitle,
    this.applicationId,
    this.lastSeen = const {},
    this.typingUsers = const [],
  });

  int getUnreadCount(String userId) => unreadCounts[userId] ?? 0;

  String getParticipantName(String userId) =>
      participantNames[userId] ?? 'Unknown';

  String otherParticipantId(String myId) =>
      participantIds.firstWhere((id) => id != myId,
          orElse: () => participantIds.first);

  Conversation copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCounts,
    Map<String, DateTime>? lastSeen,
    List<String>? typingUsers,
    Map<String, String>? participantNames,
  }) =>
      Conversation(
        id: id,
        participantIds: participantIds,
        participantNames: participantNames ?? this.participantNames,
        participantRoles: participantRoles,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        unreadCounts: unreadCounts ?? this.unreadCounts,
        opportunityId: opportunityId,
        opportunityTitle: opportunityTitle,
        applicationId: applicationId,
        lastSeen: lastSeen ?? this.lastSeen,
        typingUsers: typingUsers ?? this.typingUsers,
      );
}
