import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/features/opportunities/data/repositories/opportunity_repository_impl.dart';
import 'package:alu_spark/features/opportunities/domain/repositories/opportunity_repository.dart';
import 'package:alu_spark/features/applications/data/repositories/application_repository_impl.dart';
import 'package:alu_spark/features/applications/domain/repositories/application_repository.dart';
import 'package:alu_spark/features/startup_profile/data/repositories/startup_repository_impl.dart';
import 'package:alu_spark/features/startup_profile/domain/repositories/startup_repository.dart';
import 'package:alu_spark/features/admin_user_management/data/repositories/user_repository_impl.dart';
import 'package:alu_spark/features/admin_user_management/domain/repositories/user_repository.dart';
import 'package:alu_spark/features/admin_analytics/data/repositories/analytics_repository_impl.dart';
import 'package:alu_spark/features/admin_analytics/domain/repositories/analytics_repository.dart';
import 'package:alu_spark/features/messaging/data/repositories/message_repository_impl.dart';
import 'package:alu_spark/features/messaging/data/repositories/local_message_store.dart';
import 'package:alu_spark/features/messaging/domain/repositories/message_repository.dart';
import 'package:alu_spark/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:alu_spark/features/notifications/domain/repositories/notification_repository.dart';
import 'package:alu_spark/features/student_profile/data/repositories/student_repository_impl.dart';
import 'package:alu_spark/features/student_profile/domain/repositories/student_repository.dart';
import 'package:alu_spark/features/bookmarks/data/repositories/bookmark_repository_impl.dart';
import 'package:alu_spark/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:alu_spark/core/services/notification_service.dart';
import 'package:alu_spark/core/services/messaging_service.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) => OpportunityRepositoryImpl());
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());
final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  final messaging = ref.watch(messageRepositoryProvider);
  return ApplicationRepositoryImpl(messaging: messaging);
});
final startupRepositoryProvider = Provider<StartupRepository>((ref) => StartupRepositoryImpl());
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepositoryImpl());
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) => AnalyticsRepositoryImpl());
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final store = ref.watch(localMessageStoreProvider.notifier);
  return MessageRepositoryImpl(store);
});
final messagingServiceProvider = Provider<MessagingService>((ref) => MessagingService());
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => NotificationRepositoryImpl());

final studentRepositoryProvider = Provider<StudentRepository>((ref) => StudentRepositoryImpl());

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepositoryImpl();
});
