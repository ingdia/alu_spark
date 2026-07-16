import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';
import 'package:alu_spark/features/messaging/domain/entities/message.dart';
import 'package:alu_spark/features/messaging/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final FirebaseFirestore _db;

  MessageRepositoryImpl({FirebaseFirestore? firestore})
      : _db = firestore ?? _defaultDb();

  static FirebaseFirestore _defaultDb() {
    final db = FirebaseFirestore.instance;
    db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    return db;
  }

  CollectionReference<Map<String, dynamic>> get _convs =>
      _db.collection('conversations');

  CollectionReference<Map<String, dynamic>> _msgs(String convId) =>
      _convs.doc(convId).collection('messages');

  // ── Reads ─────────────────────────────────────────────────────────────────

  @override
  Stream<List<Conversation>> getConversations(String userId) {
    return _convs
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_convFromDoc).toList());
  }

  @override
  Stream<List<Message>> getMessages(String conversationId) {
    return _msgs(conversationId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(_msgFromDoc).toList());
  }

  @override
  Stream<Conversation?> getConversationById(String conversationId) {
    return _convs
        .doc(conversationId)
        .snapshots()
        .map((doc) => doc.exists ? _convFromDoc(doc) : null);
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  @override
  Future<void> sendMessage(Message message) async {
    final convId = message.conversationId;
    final msgRef = _msgs(convId).doc();
    final convRef = _convs.doc(convId);

    // Use a batch so the message write and conversation update are atomic.
    final batch = _db.batch();

    batch.set(msgRef, _msgToMap(message));

    // Fetch participant list to build unread increments.
    // We read outside the batch (batch doesn't support reads).
    final convSnap = await convRef.get();
    final participants =
        List<String>.from(convSnap.data()?['participantIds'] ?? []);

    final Map<String, dynamic> convUpdate = {
      'lastMessage': _preview(message),
      'lastMessageTime': FieldValue.serverTimestamp(),
    };
    for (final pid in participants) {
      if (pid != message.senderId) {
        convUpdate['unreadCounts.$pid'] = FieldValue.increment(1);
      }
    }
    batch.update(convRef, convUpdate);

    await batch.commit();
  }

  @override
  Future<void> sendAttachment({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String attachmentUrl,
    required String attachmentName,
  }) {
    return sendMessage(Message(
      id: '',
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: '📎 $attachmentName',
      createdAt: DateTime.now(),
      type: MessageType.attachment,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
    ));
  }

  /// Marks all messages not yet in `deliveredTo` for this user as delivered.
  /// Called when the recipient's message list first loads — produces the
  /// single-tick → double-tick transition on the sender's side.
  @override
  Future<void> markDelivered(String conversationId, String userId) async {
    final allSnap = await _msgs(conversationId)
        .get(const GetOptions(source: Source.serverAndCache));

    final batch = _db.batch();
    int ops = 0;
    for (final doc in allSnap.docs) {
      final delivered = List<String>.from(doc.data()['deliveredTo'] ?? []);
      final sender = doc.data()['senderId'] as String? ?? '';
      if (sender != userId && !delivered.contains(userId)) {
        batch.update(doc.reference, {
          'deliveredTo': FieldValue.arrayUnion([userId]),
        });
        ops++;
        // Firestore batch limit is 500
        if (ops == 490) break;
      }
    }
    if (ops > 0) await batch.commit();
  }

  /// Resets unread count and marks all messages as read by this user.
  @override
  Future<void> markAsRead(String conversationId, String userId) async {
    // Reset unread counter on conversation doc immediately.
    await _convs.doc(conversationId).update({'unreadCounts.$userId': 0});

    // Batch-update readBy on individual messages that don't include this user.
    final snap = await _msgs(conversationId)
        .get(const GetOptions(source: Source.serverAndCache));

    final batch = _db.batch();
    int ops = 0;
    for (final doc in snap.docs) {
      final readBy = List<String>.from(doc.data()['readBy'] ?? []);
      final sender = doc.data()['senderId'] as String? ?? '';
      if (sender != userId && !readBy.contains(userId)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userId]),
          'isRead': true,
        });
        ops++;
        if (ops == 490) break;
      }
    }
    if (ops > 0) await batch.commit();
  }

  @override
  Future<void> setTyping(
      String conversationId, String userId, bool isTyping) async {
    await _convs.doc(conversationId).update({
      'typingUsers': isTyping
          ? FieldValue.arrayUnion([userId])
          : FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> updateLastSeen(String conversationId, String userId) async {
    await _convs.doc(conversationId).update({
      'lastSeen.$userId': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
    String? opportunityId,
    String? opportunityTitle,
    String? applicationId,
  }) async {
    final ids = [currentUserId, otherUserId]..sort();
    final convId = '${ids[0]}_${ids[1]}';
    final ref = _convs.doc(convId);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'participantIds': [currentUserId, otherUserId],
        'participantNames': {
          currentUserId: currentUserName,
          otherUserId: otherUserName,
        },
        'participantRoles': {},
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCounts': {currentUserId: 0, otherUserId: 0},
        'opportunityId': opportunityId,
        'opportunityTitle': opportunityTitle,
        'applicationId': applicationId,
        'lastSeen': {},
        'typingUsers': [],
      });
    }
    return convId;
  }

  @override
  Future<String> openConversationForInterview({
    required String founderId,
    required String founderName,
    required String studentId,
    required String studentName,
    required String opportunityTitle,
    required String applicationId,
    String? interviewDate,
    String? meetingLink,
  }) async {
    final ids = [founderId, studentId]..sort();
    final convId = '${ids[0]}_${ids[1]}';
    final ref = _convs.doc(convId);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'participantIds': [founderId, studentId],
        'participantNames': {founderId: founderName, studentId: studentName},
        'participantRoles': {founderId: 'founder', studentId: 'student'},
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCounts': {founderId: 0, studentId: 0},
        'opportunityId': null,
        'opportunityTitle': opportunityTitle,
        'applicationId': applicationId,
        'lastSeen': {},
        'typingUsers': [],
      });
    }

    final now = DateTime.now();

    await sendMessage(Message(
      id: '',
      conversationId: convId,
      senderId: 'system',
      senderName: 'ALU Spark',
      text:
          'This conversation was created because $studentName has been invited to interview for "$opportunityTitle".',
      createdAt: now,
      type: MessageType.system,
      readBy: const [],
    ));

    final details = StringBuffer('📅 Interview Scheduled\n\n');
    if (interviewDate != null) details.write('Date: $interviewDate\n');
    if (meetingLink != null) details.write('Link: $meetingLink\n');
    details.write('\nPlease confirm your availability.');

    await sendMessage(Message(
      id: '',
      conversationId: convId,
      senderId: founderId,
      senderName: founderName,
      text: details.toString(),
      createdAt: now.add(const Duration(seconds: 1)),
      type: MessageType.interview,
      readBy: const [],
    ));

    return convId;
  }

  // ── Serialization ─────────────────────────────────────────────────────────

  Conversation _convFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Conversation(
      id: doc.id,
      participantIds: List<String>.from(d['participantIds'] ?? []),
      participantNames: _toStringMap(d['participantNames']),
      participantRoles: _toStringMap(d['participantRoles']),
      lastMessage: (d['lastMessage'] as String?) ?? '',
      lastMessageTime:
          (d['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCounts: _toIntMap(d['unreadCounts']),
      opportunityId: d['opportunityId'] as String?,
      opportunityTitle: d['opportunityTitle'] as String?,
      applicationId: d['applicationId'] as String?,
      lastSeen: _toDateTimeMap(d['lastSeen']),
      typingUsers: List<String>.from(d['typingUsers'] ?? []),
    );
  }

  Message _msgFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Message(
      id: doc.id,
      conversationId: (d['conversationId'] as String?) ?? '',
      senderId: (d['senderId'] as String?) ?? '',
      senderName: (d['senderName'] as String?) ?? '',
      text: (d['text'] as String?) ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: (d['isRead'] as bool?) ?? false,
      readBy: List<String>.from(d['readBy'] ?? []),
      deliveredTo: List<String>.from(d['deliveredTo'] ?? []),
      type: _msgType(d['type'] as String?),
      attachmentUrl: d['attachmentUrl'] as String?,
      attachmentName: d['attachmentName'] as String?,
    );
  }

  Map<String, dynamic> _msgToMap(Message m) => {
        'conversationId': m.conversationId,
        'senderId': m.senderId,
        'senderName': m.senderName,
        'text': m.text,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'readBy': [if (m.senderId.isNotEmpty) m.senderId],
        'deliveredTo': [if (m.senderId.isNotEmpty) m.senderId],
        'type': m.type.name,
        'attachmentUrl': m.attachmentUrl,
        'attachmentName': m.attachmentName,
      };

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Map<String, String> _toStringMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
    }
    return {};
  }

  static Map<String, int> _toIntMap(dynamic raw) {
    if (raw is Map) {
      return raw.map(
          (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0));
    }
    return {};
  }

  static Map<String, DateTime> _toDateTimeMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((k, v) {
        final dt = v is Timestamp ? v.toDate() : null;
        return MapEntry(k.toString(), dt ?? DateTime.fromMillisecondsSinceEpoch(0));
      });
    }
    return {};
  }

  static MessageType _msgType(String? raw) {
    switch (raw) {
      case 'system':
        return MessageType.system;
      case 'interview':
        return MessageType.interview;
      case 'offer':
        return MessageType.offer;
      case 'attachment':
        return MessageType.attachment;
      default:
        return MessageType.text;
    }
  }

  String _preview(Message m) {
    switch (m.type) {
      case MessageType.system:
        return '🔔 ${m.text.length > 60 ? '${m.text.substring(0, 60)}…' : m.text}';
      case MessageType.interview:
        return '📅 Interview details';
      case MessageType.offer:
        return '🎉 Offer extended';
      case MessageType.attachment:
        return '📎 ${m.attachmentName ?? 'Attachment'}';
      case MessageType.text:
        return m.text.length > 60 ? '${m.text.substring(0, 60)}…' : m.text;
    }
  }
}
