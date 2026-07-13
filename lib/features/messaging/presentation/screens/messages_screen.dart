import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/features/messaging/presentation/providers/message_provider.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Messages', style: AppTextStyles.headingLarge.copyWith(color: AppColors.white)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Connect with founders and students',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: authState.when(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Conversation> conversations) {
    if (conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.chat_bubble_rounded, size: 40, color: AppColors.darkRed),
              ),
              const SizedBox(height: 24),
              Text(
                'No Conversations Yet',
                style: AppTextStyles.headingMedium.copyWith(color: AppColors.white, fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text(
                'Start a conversation by applying to an opportunity or connecting with a founder.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(RouteNames.discover),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppColors.redGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Browse Opportunities',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: conversations.length,
      itemBuilder: (context, index) => _buildConversationCard(context, conversations[index]),
    );
  }

  Widget _buildConversationCard(BuildContext context, Conversation conv) {
    final bool hasUnread = conv.unreadCount > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            RouteNames.chatDetail,
            arguments: {'contactId': conv.participantIds.first, 'contactName': conv.participantName},
          );
        },
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.darkRed.withValues(alpha: 0.2),
                child: Text(
                  conv.participantName.isNotEmpty ? conv.participantName[0].toUpperCase() : '?',
                  style: AppTextStyles.headingMedium.copyWith(color: AppColors.darkRed),
                ),
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
                            conv.participantName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Now',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: hasUnread ? AppColors.darkRed : AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      conv.lastMessage,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: hasUnread ? AppColors.white : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (hasUnread)
                Container(
                  margin: const EdgeInsets.only(left: 8),
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
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}