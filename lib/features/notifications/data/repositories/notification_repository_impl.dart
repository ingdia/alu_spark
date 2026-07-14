import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/notifications/data/models/notification_model.dart';
import 'package:alu_spark/features/notifications/domain/entities/notification.dart';
import 'package:alu_spark/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'notifications';

  NotificationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<AppNotification>> getNotificationsByUser(String userId) {
    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc).toEntity())
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection(_collectionPath).doc(notificationId).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection(_collectionPath).doc(notificationId).delete();
  }
}
