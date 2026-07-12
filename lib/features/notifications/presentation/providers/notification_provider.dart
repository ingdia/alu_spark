import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/notifications/domain/entities/notification.dart';

final notificationsProvider = StreamProvider.family<List<AppNotification>, String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotificationsByUser(userId);
});
