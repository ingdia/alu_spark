import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/messaging/domain/entities/message.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';

final conversationsProvider =
    StreamProvider.family<List<Conversation>, String>((ref, userId) {
  return ref.watch(messageRepositoryProvider).getConversations(userId);
});

final messagesProvider =
    StreamProvider.family<List<Message>, String>((ref, conversationId) {
  return ref.watch(messageRepositoryProvider).getMessages(conversationId);
});

final conversationByIdProvider =
    StreamProvider.family<Conversation?, String>((ref, conversationId) {
  return ref
      .watch(messageRepositoryProvider)
      .getConversationById(conversationId);
});

/// Emits the list of userIds currently typing in a conversation.
final typingUsersProvider =
    StreamProvider.family<List<String>, String>((ref, conversationId) {
  return ref
      .watch(messageRepositoryProvider)
      .getConversationById(conversationId)
      .map((c) => c?.typingUsers ?? const []);
});

/// Total unread message count across all conversations for a user.
final totalUnreadProvider =
    StreamProvider.family<int, String>((ref, userId) {
  return ref.watch(messageRepositoryProvider).getConversations(userId).map(
      (convs) => convs.fold(0, (sum, c) => sum + c.getUnreadCount(userId)));
});
