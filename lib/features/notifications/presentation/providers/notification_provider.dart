import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/notifications/domain/entities/notification.dart';

final notificationsProvider =
    StreamProvider.family<List<AppNotification>, String>((ref, userId) {
  return ref
      .watch(notificationRepositoryProvider)
      .getNotificationsByUser(userId);
});

final unreadCountProvider =
    StreamProvider.family<int, String>((ref, userId) {
  return ref
      .watch(notificationRepositoryProvider)
      .getNotificationsByUser(userId)
      .map((list) => list.where((n) => !n.isRead).length);
});
