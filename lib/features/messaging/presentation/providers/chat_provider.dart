import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';

class ChatNotifier extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() => const AsyncData(null);

  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String contactId,
    required String contactName,
    required String currentUserName,
  }) async {
    state = const AsyncLoading();
    try {
      final conversationId = await ref
          .read(messageRepositoryProvider)
          .getOrCreateConversation(
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            otherUserId: contactId,
            otherUserName: contactName,
          );
      state = AsyncData(conversationId);
      return conversationId;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final chatNotifierProvider =
    NotifierProvider<ChatNotifier, AsyncValue<String?>>(ChatNotifier.new);
