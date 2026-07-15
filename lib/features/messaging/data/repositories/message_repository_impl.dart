import 'package:alu_spark/features/messaging/data/repositories/local_message_store.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';
import 'package:alu_spark/features/messaging/domain/entities/message.dart';
import 'package:alu_spark/features/messaging/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final LocalMessageStore _store;

  MessageRepositoryImpl(this._store);

  /// Emits the current state immediately, then every subsequent update.
  Stream<MessagingState> get _states async* {
    yield _store.state;
    yield* _store.stateStream;
  }

  @override
  Stream<List<Conversation>> getConversations(String userId) {
    return _states.map((s) => s.conversations
        .where((c) => c.participantIds.contains(userId))
        .toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime)));
  }

  @override
  Stream<List<Message>> getMessages(String conversationId) {
    return _states.map((s) => s.messages[conversationId] ?? const []);
  }

  @override
  Stream<Conversation?> getConversationById(String conversationId) {
    return _states.map((s) {
      try {
        return s.conversations.firstWhere((c) => c.id == conversationId);
      } catch (_) {
        return null;
      }
    });
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  @override
  Future<void> sendMessage(Message message) async {
    final id = 'msg_${DateTime.now().microsecondsSinceEpoch}';
    final stamped = Message(
      id: id,
      conversationId: message.conversationId,
      senderId: message.senderId,
      senderName: message.senderName,
      text: message.text,
      createdAt: message.createdAt,
      isRead: false,
      readBy: [message.senderId],
      type: message.type,
      attachmentUrl: message.attachmentUrl,
      attachmentName: message.attachmentName,
    );
    _store.addMessage(stamped);
  }

  @override
  Future<void> markAsRead(String conversationId, String userId) async {
    _store.markRead(conversationId, userId);
  }

  @override
  Future<void> setTyping(
      String conversationId, String userId, bool isTyping) async {
    _store.setTyping(conversationId, userId, isTyping);
  }

  @override
  Future<void> updateLastSeen(String conversationId, String userId) async {
    _store.updateLastSeen(conversationId, userId);
  }

  @override
  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
    String? opportunityId,
    String? opportunityTitle,
    String? applicationId,
  }) async {
    return _store.upsertConversation(
      userId1: currentUserId,
      name1: currentUserName,
      userId2: otherUserId,
      name2: otherUserName,
      opportunityId: opportunityId,
      opportunityTitle: opportunityTitle,
      applicationId: applicationId,
    );
  }

  @override
  Future<String> openConversationForInterview({
    required String founderId,
    required String founderName,
    required String studentId,
    required String studentName,
    required String opportunityTitle,
    required String applicationId,
    String? interviewDate,
    String? meetingLink,
  }) async {
    final convId = _store.upsertConversation(
      userId1: founderId,
      name1: founderName,
      userId2: studentId,
      name2: studentName,
      opportunityTitle: opportunityTitle,
      applicationId: applicationId,
      role1: 'founder',
      role2: 'student',
    );

    final now = DateTime.now();

    // System message
    await sendMessage(Message(
      id: '',
      conversationId: convId,
      senderId: 'system',
      senderName: 'ALU Spark',
      text:
          'This conversation was created because $studentName has been invited to interview for "$opportunityTitle".',
      createdAt: now,
      type: MessageType.system,
      readBy: const [],
    ));

    // Interview details message from founder
    final details = StringBuffer('📅 Interview Scheduled\n\n');
    if (interviewDate != null) details.write('Date: $interviewDate\n');
    if (meetingLink != null) details.write('Link: $meetingLink\n');
    details.write('\nPlease confirm your availability.');

    await sendMessage(Message(
      id: '',
      conversationId: convId,
      senderId: founderId,
      senderName: founderName,
      text: details.toString(),
      createdAt: now.add(const Duration(seconds: 1)),
      type: MessageType.interview,
      readBy: const [],
    ));

    return convId;
  }
}
