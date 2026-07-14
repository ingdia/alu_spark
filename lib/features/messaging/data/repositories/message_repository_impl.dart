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
          participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
          participantRoles: Map<String, String>.from(data['participantRoles'] ?? {}),
          lastMessage: data['lastMessage'] ?? '',
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
          opportunityId: data['opportunityId'],
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
          senderName: data['senderName'] ?? '',
          text: data['text'] ?? '',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isRead: data['isRead'] ?? false,
          readBy: List<String>.from(data['readBy'] ?? []),
        );
      }).toList();
    });
  }

  @override
  Future<void> sendMessage(Message message) async {
    final convRef = _firestore.collection(_conversationsPath).doc(message.conversationId);
    final convDoc = await convRef.get();

    if (!convDoc.exists) {
      final parts = message.conversationId.split('_');
      await convRef.set({
        'participantIds': parts,
        'participantNames': {parts[0]: 'Me', parts[1]: 'User'},
        'participantRoles': {},
        'lastMessage': message.text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCounts': {parts[0]: 0, parts[1]: 1},
        'opportunityId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await convRef.collection('messages').doc().set({
      'senderId': message.senderId,
      'senderName': message.senderName,
      'text': message.text,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'readBy': [],
    });

    await convRef.update({
      'lastMessage': message.text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markAsRead(String conversationId, String userId) async {
    await _firestore.collection(_conversationsPath).doc(conversationId).update({
      'unreadCounts.$userId': 0,
    });
  }

  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
  }) async {
    final ids = [currentUserId, otherUserId]..sort();
    final conversationId = '${ids[0]}_${ids[1]}';

    final convRef = _firestore.collection(_conversationsPath).doc(conversationId);
    final doc = await convRef.get();

    if (!doc.exists) {
      await convRef.set({
        'participantIds': ids,
        'participantNames': {ids[0]: 'User', ids[1]: otherUserName},
        'participantRoles': {},
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCounts': {ids[0]: 0, ids[1]: 0},
        'opportunityId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await convRef.update({'participantNames.${ids[1]}': otherUserName});
    }

    return conversationId;
  }
}