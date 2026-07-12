import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/messaging/domain/entities/message.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';

final conversationsProvider = StreamProvider.family<List<Conversation>, String>((ref, userId) {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getConversations(userId);
});

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, conversationId) {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getMessages(conversationId);
});
