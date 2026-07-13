import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/features/messaging/presentation/providers/message_provider.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';
import 'package:alu_spark/app/router/app_router.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlueLight,
        elevation: 0,
        title: Text(
          'Chats',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.white),
            onPressed: () {},
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
              description: 'Please log in to view your messages.',
            );
          }
          
          final conversationsAsync = ref.watch(conversationsProvider(user.id));
          
          return conversationsAsync.when(
            loading: () => const LoadingWidget(message: 'Loading conversations...'),
            error: (error, _) => ErrorStateWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(conversationsProvider(user.id)),
            ),
            data: (conversations) => _buildContent(context, conversations),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Conversation> conversations) {
    if (conversations.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.chat_bubble_outline,
        title: 'No Conversations',
        description: 'Start a chat with a founder or student!',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4),
      itemCount: conversations.length,
      itemBuilder: (context, index) => _buildConversationCard(context, conversations[index]),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays < 7) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildConversationCard(BuildContext context, Conversation conv) {
    final bool hasUnread = conv.unreadCount > 0;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          RouteNames.chatDetail,
          arguments: {'contactId': conv.participantIds.first, 'contactName': conv.participantName},
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderGlass, width: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.darkRed.withValues(alpha: 0.2),
                  child: Text(
                    conv.participantName.isNotEmpty ? conv.participantName[0].toUpperCase() : '?',
                    style: AppTextStyles.headingMedium.copyWith(color: AppColors.darkRed),
                  ),
                ),
                // Online indicator
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.darkBlue, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conv.participantName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(conv.lastMessageTime),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: hasUnread ? AppColors.darkRed : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.lastMessage,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: hasUnread ? AppColors.white : AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.darkRed,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${conv.unreadCount}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}