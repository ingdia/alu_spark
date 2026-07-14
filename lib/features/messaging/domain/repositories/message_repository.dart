import 'package:alu_spark/features/messaging/domain/entities/message.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';

abstract class MessageRepository {
  Stream<List<Conversation>> getConversations(String userId);
  Stream<List<Message>> getMessages(String conversationId);
  Future<void> sendMessage(Message message);
  Future<void> markAsRead(String conversationId, String userId);
  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
  });
}
