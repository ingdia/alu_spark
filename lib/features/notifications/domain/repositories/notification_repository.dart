import 'package:alu_spark/features/notifications/domain/entities/notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> getNotificationsByUser(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String notificationId);
}
