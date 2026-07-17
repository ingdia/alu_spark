import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/messaging/domain/entities/room.dart';
import 'package:alu_spark/features/messaging/domain/entities/room_message.dart';
import 'package:alu_spark/features/messaging/domain/repositories/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  final FirebaseFirestore _db;

  RoomRepositoryImpl({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _db.collection('rooms');

  CollectionReference<Map<String, dynamic>> _msgs(String roomId) =>
      _rooms.doc(roomId).collection('messages');

  @override
  Stream<List<Room>> getRooms() {
    return _rooms
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_roomFromDoc).toList());
  }

  @override
  Stream<List<RoomMessage>> getRoomMessages(String roomId) {
    return _msgs(roomId)
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map(_msgFromDoc).toList());
  }

  @override
  Future<String> createRoom({
    required String title,
    required String description,
    required String createdBy,
    required String createdByName,
  }) async {
    final ref = _rooms.doc();
    await ref.set({
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': FieldValue.serverTimestamp(),
      'memberIds': [createdBy],
      'memberCount': 1,
      'lastMessage': '$createdByName created this room',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  @override
  Future<void> joinRoom(String roomId, String userId) async {
    await _rooms.doc(roomId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
      'memberCount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> leaveRoom(String roomId, String userId) async {
    await _rooms.doc(roomId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'memberCount': FieldValue.increment(-1),
    });
  }

  @override
  Future<void> sendRoomMessage(RoomMessage message) async {
    final msgRef = _msgs(message.roomId).doc();
    final batch = _db.batch();
    batch.set(msgRef, {
      'roomId': message.roomId,
      'senderId': message.senderId,
      'senderName': message.senderName,
      'text': message.text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(_rooms.doc(message.roomId), {
      'lastMessage': '${message.senderName}: ${message.text.length > 50 ? '${message.text.substring(0, 50)}…' : message.text}',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Room _roomFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Room(
      id: doc.id,
      title: (d['title'] as String?) ?? '',
      description: (d['description'] as String?) ?? '',
      createdBy: (d['createdBy'] as String?) ?? '',
      createdByName: (d['createdByName'] as String?) ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      memberIds: List<String>.from(d['memberIds'] ?? []),
      lastMessage: (d['lastMessage'] as String?) ?? '',
      lastMessageTime:
          (d['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      memberCount: (d['memberCount'] as int?) ?? 0,
    );
  }

  RoomMessage _msgFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return RoomMessage(
      id: doc.id,
      roomId: (d['roomId'] as String?) ?? '',
      senderId: (d['senderId'] as String?) ?? '',
      senderName: (d['senderName'] as String?) ?? '',
      text: (d['text'] as String?) ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
