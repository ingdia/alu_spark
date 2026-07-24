import 'package:alu_spark/features/messaging/domain/entities/message.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';

abstract class MessageRepository {
  Stream<List<Conversation>> getConversations(String userId);
  Stream<List<Message>> getMessages(String conversationId);
  Stream<Conversation?> getConversationById(String conversationId);
  Future<void> sendMessage(Message message);
  /// Sends an attachment message (URL-based, consistent with app-wide media policy).
  Future<void> sendAttachment({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String attachmentUrl,
    required String attachmentName,
  });
  Future<void> markAsRead(String conversationId, String userId);
  /// Called when the recipient's device first receives messages — marks single-tick → double-tick.
  Future<void> markDelivered(String conversationId, String userId);
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
