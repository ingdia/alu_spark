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

final typingUsersProvider =
    StreamProvider.family<List<String>, String>((ref, conversationId) {
  return ref
      .watch(messageRepositoryProvider)
      .getConversationById(conversationId)
      .map((c) => c?.typingUsers ?? const []);
});

final totalUnreadProvider =
    StreamProvider.family<int, String>((ref, userId) {
  return ref.watch(messageRepositoryProvider).getConversations(userId).map(
      (convs) => convs.fold(0, (sum, c) => sum + c.getUnreadCount(userId)));
});

/// Holds the current conversation search query.
class _SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
}

final conversationSearchQueryProvider =
    NotifierProvider.autoDispose<_SearchQueryNotifier, String>(
        _SearchQueryNotifier.new);

/// Conversations filtered by the search query (name, opportunity title, last message).
final filteredConversationsProvider =
    Provider.family.autoDispose<AsyncValue<List<Conversation>>, String>(
        (ref, userId) {
  final convAsync = ref.watch(conversationsProvider(userId));
  final query = ref.watch(conversationSearchQueryProvider).toLowerCase().trim();

  return convAsync.whenData((convs) {
    if (query.isEmpty) return convs;
    return convs.where((c) {
      final names =
          c.participantNames.values.any((n) => n.toLowerCase().contains(query));
      final opp = c.opportunityTitle?.toLowerCase().contains(query) ?? false;
      final last = c.lastMessage.toLowerCase().contains(query);
      return names || opp || last;
    }).toList();
  });
});
