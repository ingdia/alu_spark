import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/messaging/domain/entities/message.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';
import 'package:alu_spark/features/messaging/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final FirebaseFirestore _firestore;
  final String _conversationsPath = 'conversations';

  MessageRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Conversation>> getConversations(String userId) {
    return _firestore
        .collection(_conversationsPath)
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return Conversation(
          id: doc.id,
          participantIds: List<String>.from(data['participantIds'] ?? []),
          lastMessage: data['lastMessage'] ?? '',
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          unreadCount: data['unreadCount'] ?? 0,
          participantName: data['participantName'] ?? 'Unknown',
        );
      }).toList();
      list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return list;
    });
  }

  @override
  Stream<List<Message>> getMessages(String conversationId) {
    return _firestore
        .collection(_conversationsPath)
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Message(
          id: doc.id,
          conversationId: conversationId,
          senderId: data['senderId'] ?? '',
          text: data['text'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isRead: data['isRead'] ?? false,
        );
      }).toList();
    });
  }

  @override
  Future<void> sendMessage(Message message) async {
    final docRef = _firestore
        .collection(_conversationsPath)
        .doc(message.conversationId)
        .collection('messages')
        .doc();

    await docRef.set({
      'senderId': message.senderId,
      'text': message.text,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Update conversation metadata
    await _firestore.collection(_conversationsPath).doc(message.conversationId).update({
      'lastMessage': message.text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    await _firestore.collection(_conversationsPath).doc(conversationId).update({
      'unreadCount': 0,
    });
  }
}
