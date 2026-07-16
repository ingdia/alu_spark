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

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text('Messages',
                  style: AppTextStyles.headingLarge
                      .copyWith(color: AppColors.white)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Connect with founders and students',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: authState.when(
                loading: () => const LoadingWidget(),
                error: (error, _) =>
                    ErrorStateWidget(message: error.toString()),
                data: (user) {
                  if (user == null) {
                    return const EmptyStateWidget(
                      icon: Icons.lock,
                      title: 'Not Logged In',
                      description: 'Please log in to view your messages.',
                    );
                  }
                  return Column(
                    children: [
                      _buildSearchBar(),
                      Expanded(child: _buildBody(context, user.id)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextField(
          controller: _searchCtrl,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Search conversations…',
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            border: InputBorder.none,
            icon: const Icon(Icons.search,
                color: AppColors.textSecondary, size: 20),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        color: AppColors.textSecondary, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      ref.read(conversationSearchQueryProvider.notifier).set('');
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (v) {
            ref.read(conversationSearchQueryProvider.notifier).set(v);
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String userId) {
    final filtered = ref.watch(filteredConversationsProvider(userId));
    return filtered.when(
      loading: () =>
          const LoadingWidget(message: 'Loading conversations...'),
      error: (error, _) => ErrorStateWidget(
        message: error.toString(),
        onRetry: () => ref.invalidate(conversationsProvider(userId)),
      ),
      data: (conversations) =>
          _buildContent(context, conversations, userId),
    );
  }

  Widget _buildContent(BuildContext context, List<Conversation> conversations,
      String currentUserId) {
    if (conversations.isEmpty) {
      final query = ref.read(conversationSearchQueryProvider);
      if (query.isNotEmpty) {
        return EmptyStateWidget(
          icon: Icons.search_off,
          title: 'No Results',
          description: 'No conversations match "$query".',
        );
      }
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
                child: const Icon(Icons.chat_bubble_rounded,
                    size: 40, color: AppColors.darkRed),
              ),
              const SizedBox(height: 24),
              Text(
                'No Conversations Yet',
                style: AppTextStyles.headingMedium
                    .copyWith(color: AppColors.white, fontSize: 20),
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
                onTap: () =>
                    Navigator.of(context).pushNamed(RouteNames.discover),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppColors.redGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Browse Opportunities',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600),
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
      itemBuilder: (context, index) =>
          _buildConversationCard(context, conversations[index], currentUserId),
    );
  }

  Widget _buildConversationCard(
      BuildContext context, Conversation conv, String currentUserId) {
    final otherId = conv.otherParticipantId(currentUserId);
    final contactName = conv.getParticipantName(otherId);
    final hasUnread = conv.getUnreadCount(currentUserId) > 0;
    final isTyping = conv.typingUsers.contains(otherId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            RouteNames.chatDetail,
            arguments: {
              'conversationId': conv.id,
              'contactId': otherId,
              'contactName': contactName,
            },
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
                  contactName.isNotEmpty
                      ? contactName[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.headingMedium
                      .copyWith(color: AppColors.darkRed),
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
                            contactName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _fmtTime(conv.lastMessageTime),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: hasUnread
                                ? AppColors.darkRed
                                : AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    if (conv.opportunityTitle != null) ...[
                      const SizedBox(height: 2),
                      Text(conv.opportunityTitle!,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.darkRedLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      isTyping ? 'typing…' : conv.lastMessage,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isTyping
                            ? const Color(0xFF34D399)
                            : hasUnread
                                ? AppColors.white
                                : AppColors.textSecondary,
                        fontSize: 13,
                        fontStyle: isTyping
                            ? FontStyle.italic
                            : FontStyle.normal,
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
                    '${conv.getUnreadCount(currentUserId)}',
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

  String _fmtTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dt.weekday - 1];
    }
    return '${dt.day}/${dt.month}';
  }
}
