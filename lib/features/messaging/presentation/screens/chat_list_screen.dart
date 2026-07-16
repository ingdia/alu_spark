import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';
import 'package:alu_spark/features/messaging/presentation/providers/message_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlueLight,
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
        title: Text('Messages',
            style:
                AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
        centerTitle: true,
      ),
      body: user == null
          ? const EmptyStateWidget(
              icon: Icons.lock_outline,
              title: 'Not Logged In',
              description: 'Please log in to view your messages.',
            )
          : Column(
              children: [
                _buildSearchBar(ref),
                Expanded(child: _buildBody(context, ref, user.id)),
              ],
            ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextField(
          controller: _searchCtrl,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Search conversations…',
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        color: AppColors.textSecondary, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      ref.read(conversationSearchQueryProvider.notifier).set('');
                    },
                  )
                : null,
          ),
          onChanged: (v) {
            ref.read(conversationSearchQueryProvider.notifier).set(v);
            setState(() {}); // rebuild to show/hide clear button
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, String userId) {
    final filtered = ref.watch(filteredConversationsProvider(userId));
    return filtered.when(
      loading: () => const LoadingWidget(message: 'Loading messages...'),
      error: (e, _) => ErrorStateWidget(message: e.toString()),
      data: (convs) => _buildList(context, convs, userId),
    );
  }

  Widget _buildList(
      BuildContext context, List<Conversation> convs, String myId) {
    if (convs.isEmpty) {
      final query = ref.read(conversationSearchQueryProvider);
      return EmptyStateWidget(
        icon: Icons.chat_bubble_outline,
        title: query.isEmpty ? 'No Conversations Yet' : 'No Results',
        description: query.isEmpty
            ? 'Conversations open automatically when an interview is scheduled.'
            : 'No conversations match "$query".',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: convs.length,
      separatorBuilder: (_, _) =>
          const Divider(color: AppColors.borderGlass, height: 0.5, indent: 80),
      itemBuilder: (_, i) => _ConvTile(conv: convs[i], myId: myId),
    );
  }
}

class _ConvTile extends StatelessWidget {
  final Conversation conv;
  final String myId;

  const _ConvTile({required this.conv, required this.myId});

  @override
  Widget build(BuildContext context) {
    final otherId = conv.otherParticipantId(myId);
    final otherName = conv.getParticipantName(otherId);
    final unread = conv.getUnreadCount(myId);
    final hasUnread = unread > 0;
    final lastSeen = conv.lastSeen[otherId];
    final isTyping = conv.typingUsers.contains(otherId);

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        RouteNames.chatDetail,
        arguments: {
          'conversationId': conv.id,
          'contactId': otherId,
          'contactName': otherName,
        },
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.darkRed.withValues(alpha: 0.2),
                  child: Text(
                    otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                    style: AppTextStyles.headingMedium
                        .copyWith(color: AppColors.darkRed, fontSize: 18),
                  ),
                ),
                if (_isOnline(lastSeen))
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34D399),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.darkBlue, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(otherName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis),
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
                  const SizedBox(height: 3),
                  if (conv.opportunityTitle != null)
                    Text(conv.opportunityTitle!,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.darkRedLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: isTyping
                            ? Text('typing…',
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: const Color(0xFF34D399),
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic))
                            : Text(conv.lastMessage,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: hasUnread
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.darkRed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$unread',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  if (!isTyping && lastSeen != null && !_isOnline(lastSeen))
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('Last seen ${_relativeTime(lastSeen)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary, fontSize: 10)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isOnline(DateTime? lastSeen) {
    if (lastSeen == null) return false;
    return DateTime.now().difference(lastSeen).inMinutes < 5;
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

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
