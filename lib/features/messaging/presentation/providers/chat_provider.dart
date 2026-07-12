import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatNotifier extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() => const AsyncData(null);

  /// Creates or retrieves an existing conversation between [currentUserId] and [contactId].
  /// Returns the conversation document ID.
  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String contactId,
    required String contactName,
    required String currentUserName,
  }) async {
    state = const AsyncLoading();
    try {
      final ids = [currentUserId, contactId]..sort();
      final conversationId = '${ids[0]}_${ids[1]}';
      final ref = FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId);

      final doc = await ref.get();
      if (!doc.exists) {
        await ref.set({
          'participantIds': [currentUserId, contactId],
          'participantName': contactName,
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

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
