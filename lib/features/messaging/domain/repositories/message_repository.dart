import 'package:alu_spark/features/messaging/domain/entities/message.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';

abstract class MessageRepository {
  Stream<List<Conversation>> getConversations(String userId);
  Stream<List<Message>> getMessages(String conversationId);
  Stream<Conversation?> getConversationById(String conversationId);
  Future<void> sendMessage(Message message);
  Future<void> markAsRead(String conversationId, String userId);
  Future<void> setTyping(String conversationId, String userId, bool isTyping);
  Future<void> updateLastSeen(String conversationId, String userId);
  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
    String? opportunityId,
    String? opportunityTitle,
    String? applicationId,
  });
  /// Called automatically when an application moves to Interview status.
  /// Creates the conversation and seeds it with a system + interview message.
  Future<String> openConversationForInterview({
    required String founderId,
    required String founderName,
    required String studentId,
    required String studentName,
    required String opportunityTitle,
    required String applicationId,
    String? interviewDate,
    String? meetingLink,
  });
}
