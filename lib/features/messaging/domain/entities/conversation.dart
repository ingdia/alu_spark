class Conversation {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantRoles;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCounts;
  final String? opportunityId;

  Conversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantRoles,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCounts = const {},
    this.opportunityId,
  });

  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  String getParticipantName(String userId) {
    return participantNames[userId] ?? 'Unknown';
  }
}
