import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/messaging/domain/entities/message.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';
import 'package:alu_spark/features/messaging/presentation/providers/message_provider.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String contactId;
  final String contactName;
  final String? conversationId;

  const ChatDetailScreen({
    super.key,
    required this.contactId,
    required this.contactName,
    this.conversationId,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen>
    with WidgetsBindingObserver {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();
  String? _convId;
  bool _isAtBottom = true;
  Timer? _typingTimer;
  bool _isTyping = false;

  String get _myId => ref.read(authStateProvider).value?.id ?? '';
  String get _myName =>
      ref.read(authStateProvider).value?.fullName ?? 'Me';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _convId = widget.conversationId;
    if (_convId == null) _initConversation();
    _scrollCtrl.addListener(_onScroll);
    _msgCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    if (_convId != null) {
      ref
          .read(messageRepositoryProvider)
          .setTyping(_convId!, _myId, false);
      ref
          .read(messageRepositoryProvider)
          .updateLastSeen(_convId!, _myId);
    }
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initConversation() async {
    final id = await ref.read(messageRepositoryProvider).getOrCreateConversation(
          currentUserId: _myId,
          currentUserName: _myName,
          otherUserId: widget.contactId,
          otherUserName: widget.contactName,
        );
    if (mounted) setState(() => _convId = id);
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final atBottom = _scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 60;
    if (atBottom != _isAtBottom) setState(() => _isAtBottom = atBottom);
  }

  void _onTextChanged() {
    if (_convId == null) return;
    if (!_isTyping) {
      _isTyping = true;
      ref.read(messageRepositoryProvider).setTyping(_convId!, _myId, true);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _isTyping = false;
      if (_convId != null) {
        ref
            .read(messageRepositoryProvider)
            .setTyping(_convId!, _myId, false);
      }
    });
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      if (animated) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      } else {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _convId == null) return;
    _msgCtrl.clear();
    _isTyping = false;
    _typingTimer?.cancel();
    ref.read(messageRepositoryProvider).setTyping(_convId!, _myId, false);

    await ref.read(messageRepositoryProvider).sendMessage(Message(
          id: '',
          conversationId: _convId!,
          senderId: _myId,
          senderName: _myName,
          text: text,
          createdAt: DateTime.now(),
          type: MessageType.text,
        ));
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final convAsync = _convId != null
        ? ref.watch(conversationByIdProvider(_convId!))
        : const AsyncData<Conversation?>(null);

    final conv = convAsync.value;
    final otherId = conv?.otherParticipantId(_myId) ?? widget.contactId;
    final otherLastSeen = conv?.lastSeen[otherId];
    final isOtherOnline = otherLastSeen != null &&
        DateTime.now().difference(otherLastSeen).inMinutes < 5;
    final isOtherTyping = conv?.typingUsers.contains(otherId) ?? false;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(
          conv, isOtherOnline, isOtherTyping, otherLastSeen),
      body: _convId == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.darkRed))
          : Column(
              children: [
                if (conv?.opportunityTitle != null)
                  _buildContextBanner(conv!.opportunityTitle!),
                Expanded(child: _buildMessageList()),
                if (!_isAtBottom)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 4),
                      child: GestureDetector(
                        onTap: () => _scrollToBottom(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.darkRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.keyboard_arrow_down,
                              color: AppColors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                if (isOtherTyping) _buildTypingIndicator(widget.contactName),
                _buildInputBar(),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(Conversation? conv, bool isOnline,
      bool isTyping, DateTime? lastSeen) {
    String subtitle;
    if (isTyping) {
      subtitle = 'typing…';
    } else if (isOnline) {
      subtitle = 'online';
    } else if (lastSeen != null) {
      subtitle = 'last seen ${_relativeTime(lastSeen)}';
    } else {
      subtitle = '';
    }

    return AppBar(
      backgroundColor: AppColors.darkBlueLight,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () {
          if (_convId != null) {
            ref
                .read(messageRepositoryProvider)
                .updateLastSeen(_convId!, _myId);
          }
          Navigator.of(context).pop();
        },
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.darkRed.withValues(alpha: 0.3),
            child: Text(
              widget.contactName.isNotEmpty
                  ? widget.contactName[0].toUpperCase()
                  : '?',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.white, fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.contactName,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.white)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isTyping
                            ? const Color(0xFF34D399)
                            : isOnline
                                ? const Color(0xFF34D399)
                                : AppColors.textSecondary,
                        fontSize: 11,
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextBanner(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.darkRed.withValues(alpha: 0.15),
      child: Row(
        children: [
          const Icon(Icons.work_outline, color: AppColors.darkRedLight, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(title,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.darkRedLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ref.watch(messagesProvider(_convId!)).when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.darkRed)),
          error: (e, _) =>
              Center(child: Text('$e', style: const TextStyle(color: Colors.red))),
          data: (msgs) {
            // Mark as read
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(messageRepositoryProvider)
                  .markAsRead(_convId!, _myId);
              if (_isAtBottom && msgs.isNotEmpty) {
                _scrollToBottom(animated: false);
              }
            });

            if (msgs.isEmpty) return _buildEmptyState();

            return GestureDetector(
              onTap: () => _focusNode.unfocus(),
              child: ListView.builder(
                controller: _scrollCtrl,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final msg = msgs[i];
                  final showDate = i == 0 ||
                      _isNewDay(msgs[i - 1].createdAt, msg.createdAt);
                  return Column(
                    children: [
                      if (showDate) _buildDateSep(msg.createdAt),
                      _buildBubble(msg, i == msgs.length - 1),
                    ],
                  );
                },
              ),
            );
          },
        );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline,
                color: AppColors.darkRed, size: 40),
          ),
          const SizedBox(height: 16),
          Text('Start the conversation',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.white)),
          const SizedBox(height: 6),
          Text('Send the first message.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDateSep(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    final label = diff.inDays == 0
        ? 'Today'
        : diff.inDays == 1
            ? 'Yesterday'
            : '${dt.day}/${dt.month}/${dt.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.darkRed.withValues(alpha: 0.2),
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: AppColors.darkRed, fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.darkBlueLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _dot(0),
                const SizedBox(width: 3),
                _dot(150),
                const SizedBox(width: 3),
                _dot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (_, v, _) => Opacity(
        opacity: v,
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(Message msg, bool isLast) {
    if (msg.type == MessageType.system) return _buildSystemBubble(msg);

    final isSent = msg.senderId == _myId;
    final isRead = msg.readBy.any((id) => id != msg.senderId);

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 8 : 4,
        left: isSent ? 56 : 0,
        right: isSent ? 0 : 56,
      ),
      child: Align(
        alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
        child: _bubbleContent(msg, isSent, isRead),
      ),
    );
  }

  Widget _bubbleContent(Message msg, bool isSent, bool isRead) {
    final bg = isSent
        ? const Color(0xFF1A3A2A)
        : AppColors.darkBlueLight;

    Widget content;
    switch (msg.type) {
      case MessageType.interview:
        content = _interviewCard(msg, isSent);
      case MessageType.offer:
        content = _offerCard(msg, isSent);
      case MessageType.attachment:
        content = _attachmentCard(msg, isSent);
      default:
        content = _textContent(msg, isSent, isRead, bg);
    }
    return content;
  }

  Widget _textContent(
      Message msg, bool isSent, bool isRead, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isSent ? 16 : 4),
          bottomRight: Radius.circular(isSent ? 4 : 16),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(msg.text,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, height: 1.35)),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_fmtTime(msg.createdAt),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11)),
              if (isSent) ...[
                const SizedBox(width: 4),
                Icon(
                  isRead ? Icons.done_all : Icons.done,
                  size: 15,
                  color: isRead
                      ? const Color(0xFF53BDEB)
                      : Colors.white.withValues(alpha: 0.55),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _interviewCard(Message msg, bool isSent) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: AppColors.darkRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.darkRed.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_outlined,
                    color: AppColors.white, size: 16),
                const SizedBox(width: 6),
                Text('Interview Scheduled',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white, height: 1.5)),
                const SizedBox(height: 8),
                _timeAndTick(msg, isSent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _offerCard(Message msg, bool isSent) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: const Color(0xFF34D399).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF34D399).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF34D399).withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text('Offer Extended',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white, height: 1.5)),
                const SizedBox(height: 8),
                _timeAndTick(msg, isSent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachmentCard(Message msg, bool isSent) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBlueLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.attach_file,
                    color: AppColors.darkRed, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(msg.attachmentName ?? 'Attachment',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                    if (msg.attachmentUrl != null)
                      Text(msg.attachmentUrl!,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.darkRedLight,
                              fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _timeAndTick(msg, isSent),
        ],
      ),
    );
  }

  Widget _buildSystemBubble(Message msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.textSecondary, size: 13),
              const SizedBox(width: 6),
              Flexible(
                child: Text(msg.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4),
                    textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeAndTick(Message msg, bool isSent) {
    final isRead = msg.readBy.any((id) => id != msg.senderId);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_fmtTime(msg.createdAt),
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 11)),
        if (isSent) ...[
          const SizedBox(width: 4),
          Icon(
            isRead ? Icons.done_all : Icons.done,
            size: 14,
            color: isRead
                ? const Color(0xFF53BDEB)
                : Colors.white.withValues(alpha: 0.55),
          ),
        ],
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBlueLight,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderGlass),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          focusNode: _focusNode,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                          maxLines: 4,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: const InputDecoration(
                            hintText: 'Type a message…',
                            hintStyle: TextStyle(
                                color: AppColors.textSecondary),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.darkRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: AppColors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isNewDay(DateTime a, DateTime b) =>
      a.day != b.day || a.month != b.month || a.year != b.year;

  String _fmtTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
