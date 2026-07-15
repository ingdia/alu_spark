import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/router/app_router.dart';
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
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(context, ref, user?.id),
      body: user == null
          ? const EmptyStateWidget(
              icon: Icons.lock_outline,
              title: 'Not Logged In',
              description: 'Please log in to view notifications.',
            )
          : ref.watch(notificationsProvider(user.id)).when(
                loading: () =>
                    const LoadingWidget(message: 'Loading notifications...'),
                error: (e, _) => ErrorStateWidget(
                  message: e.toString(),
                  onRetry: () =>
                      ref.invalidate(notificationsProvider(user.id)),
                ),
                data: (notifications) =>
                    _buildBody(context, ref, notifications),
              ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, String? userId) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(12),
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 12,
          padding: EdgeInsets.zero,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: Text('Notifications',
          style:
              AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
      centerTitle: true,
      actions: [
        if (userId != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () async {
                await ref
                    .read(notificationRepositoryProvider)
                    .markAllAsRead(userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('All notifications marked as read'),
                      backgroundColor: AppColors.darkBlueLight,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              },
              child: Text('Mark All Read',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.darkRedLight, fontSize: 13)),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref,
      List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.notifications_none_outlined,
        title: 'All Caught Up',
        description: 'No notifications yet. Check back later.',
      );
    }

    // Group into Today / Yesterday / Earlier
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayList = notifications
        .where((n) => _dateOnly(n.createdAt).isAtSameMomentAs(today))
        .toList();
    final yesterdayList = notifications
        .where((n) => _dateOnly(n.createdAt).isAtSameMomentAs(yesterday))
        .toList();
    final earlierList = notifications
        .where((n) => _dateOnly(n.createdAt).isBefore(yesterday))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        if (todayList.isNotEmpty) ...[
          _groupHeader('Today'),
          ...todayList.map((n) => _NotifCard(notif: n)),
        ],
        if (yesterdayList.isNotEmpty) ...[
          _groupHeader('Yesterday'),
          ...yesterdayList.map((n) => _NotifCard(notif: n)),
        ],
        if (earlierList.isNotEmpty) ...[
          _groupHeader('Earlier'),
          ...earlierList.map((n) => _NotifCard(notif: n)),
        ],
      ],
    );
  }

  Widget _groupHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(label,
          style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12)),
    );
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}

// ─── Individual notification card ────────────────────────────────────────────

class _NotifCard extends ConsumerWidget {
  final AppNotification notif;

  const _NotifCard({required this.notif});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnread = !notif.isRead;
    final (icon, accent) = _iconAndColor(notif.type, notif.title);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(notif.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
        ),
        onDismissed: (_) {
          ref
              .read(notificationRepositoryProvider)
              .deleteNotification(notif.id);
        },
        child: GestureDetector(
          onTap: () {
            if (isUnread) {
              ref
                  .read(notificationRepositoryProvider)
                  .markAsRead(notif.id);
            }
            _navigate(context, notif.type);
          },
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 16,
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon badge
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.white,
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8, top: 4),
                              decoration: const BoxDecoration(
                                color: AppColors.darkRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _relativeTime(notif.createdAt),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isUnread
                              ? AppColors.darkRedLight
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: isUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String type) {
    switch (type) {
      case 'application':
        Navigator.of(context).pushNamed(RouteNames.applicationTracking);
      case 'message':
        Navigator.of(context).pushNamed(RouteNames.chatList);
      default:
        break;
    }
  }

  /// Returns the right icon and accent colour based on notification type
  /// and title keywords.
  (IconData, Color) _iconAndColor(String type, String title) {
    if (type == 'message') {
      return (Icons.chat_bubble_outline, const Color(0xFF60A5FA));
    }
    final t = title.toLowerCase();
    if (t.contains('accepted') || t.contains('congratulations')) {
      return (Icons.check_circle_outline, const Color(0xFF34D399));
    }
    if (t.contains('rejected') || t.contains('unsuccessful')) {
      return (Icons.cancel_outlined, AppColors.textSecondary);
    }
    if (t.contains('interview')) {
      return (Icons.event_outlined, AppColors.darkRedLight);
    }
    if (t.contains('review')) {
      return (Icons.rate_review_outlined, const Color(0xFFFBBF24));
    }
    if (t.contains('withdrawn')) {
      return (Icons.undo_outlined, AppColors.textSecondary);
    }
    if (t.contains('closed')) {
      return (Icons.lock_outline, AppColors.textSecondary);
    }
    if (t.contains('approved')) {
      return (Icons.verified_outlined, const Color(0xFF34D399));
    }
    if (t.contains('new application')) {
      return (Icons.person_add_outlined, AppColors.darkRed);
    }
    return (Icons.notifications_outlined, AppColors.darkRed);
  }

  /// Human-readable relative timestamp.
  String _relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    }
    if (diff.inDays < 14) return '1 week ago';
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return '$w weeks ago';
    }
    // Fallback: absolute date
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}
