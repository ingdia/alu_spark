import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/notifications/data/models/notification_model.dart';
import 'package:alu_spark/features/notifications/domain/entities/notification.dart';
import 'package:alu_spark/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection('notifications').doc(userId).collection('items');

  @override
  Stream<List<AppNotification>> getNotificationsByUser(String userId) {
    return _col(userId).snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc).toEntity())
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // notificationId format: "{userId}_{docId}"
    final idx = notificationId.indexOf('_');
    final userId = notificationId.substring(0, idx);
    final docId = notificationId.substring(idx + 1);
    await _col(userId).doc(docId).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _col(userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final idx = notificationId.indexOf('_');
    final userId = notificationId.substring(0, idx);
    final docId = notificationId.substring(idx + 1);
    await _col(userId).doc(docId).delete();
  }
}
