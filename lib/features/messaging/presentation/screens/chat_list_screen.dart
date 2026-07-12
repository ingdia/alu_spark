import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/features/messaging/presentation/providers/message_provider.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(),
      body: authState.when(
        loading: () => const LoadingWidget(),
        error: (_, __) => const ErrorStateWidget(message: 'Failed to load user'),
        data: (user) {
          if (user == null) return const EmptyStateWidget(icon: Icons.lock, title: 'Not Logged In');
          
          final conversationsAsync = ref.watch(conversationsProvider(user.id));
          
          return conversationsAsync.when(
            loading: () => const LoadingWidget(message: 'Loading conversations...'),
            error: (error, _) => ErrorStateWidget(message: error.toString(), onRetry: () => ref.invalidate(conversationsProvider(user.id))),
            data: (conversations) => _buildContent(conversations),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlassmorphicContainer(
          blur: 10, borderRadius: 12, padding: const EdgeInsets.all(0),
          child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18), onPressed: () => Navigator.of(context).pop()),
        ),
      ),
      title: Text('Messages', style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
      centerTitle: true,
    );
  }

  Widget _buildContent(List<Conversation> conversations) {
    if (conversations.isEmpty) {
      return const EmptyStateWidget(icon: Icons.chat_bubble_outline, title: 'No Conversations', description: 'Start a chat with a founder or student!');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: conversations.length,
      itemBuilder: (context, index) => _buildConversationCard(conversations[index]),
    );
  }

  Widget _buildConversationCard(Conversation conv) {
    final bool hasUnread = conv.unreadCount > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        blur: 10, borderRadius: 16, padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.darkRed.withOpacity(0.2),
              child: Text(conv.participantName[0], style: AppTextStyles.headingMedium.copyWith(color: AppColors.darkRed)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(conv.participantName, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white, fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal), overflow: TextOverflow.ellipsis)),
                      Text('Now', style: AppTextStyles.bodyMedium.copyWith(color: hasUnread ? AppColors.darkRed : AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(conv.lastMessage, style: AppTextStyles.bodyMedium.copyWith(color: hasUnread ? AppColors.white : AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (hasUnread)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.darkRed, shape: BoxShape.circle),
                child: Text('${conv.unreadCount}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white, fontSize: 10)),
              ),
          ],
        ),
      ),
    );
  }
}
