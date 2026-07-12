import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/notifications/presentation/providers/notification_provider.dart';
import 'package:alu_spark/features/notifications/domain/entities/notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.all(0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassmorphicContainer(
              blur: 10,
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: TextButton(
                onPressed: () {
                  final user = ref.read(authStateProvider).value;
                  if (user != null) {
                    ref.read(notificationRepositoryProvider).markAllAsRead(user.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All notifications marked as read'),
                        backgroundColor: AppColors.darkRed,
                      ),
                    );
                  }
                },
                child: Text(
                  'Mark All Read',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: authState.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => ErrorStateWidget(message: error.toString()),
        data: (user) {
          if (user == null) {
            return const EmptyStateWidget(
              icon: Icons.lock,
              title: 'Not Logged In',
              description: 'Please log in to view notifications.',
            );
          }
          
          final notificationsAsync = ref.watch(notificationsProvider(user.id));
          
          return notificationsAsync.when(
            loading: () => const LoadingWidget(message: 'Loading notifications...'),
            error: (error, _) => ErrorStateWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(notificationsProvider(user.id)),
            ),
            data: (notifications) => _buildContent(context, ref, notifications),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.notifications_none,
        title: 'No Notifications',
        description: 'You are all caught up! Check back later for updates.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: notifications.length,
      itemBuilder: (context, index) => _buildNotificationCard(context, ref, notifications[index]),
    );
  }

  Widget _buildNotificationCard(BuildContext context, WidgetRef ref, AppNotification notif) {
    final bool isUnread = !notif.isRead;
    IconData iconData = Icons.info_outline;
    if (notif.type == 'application') iconData = Icons.work_outline;
    if (notif.type == 'message') iconData = Icons.message_outlined;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          if (isUnread) {
            ref.read(notificationRepositoryProvider).markAsRead(notif.id);
          }
        },
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: AppColors.darkRed, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.darkRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Just now',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isUnread ? AppColors.darkRed : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
