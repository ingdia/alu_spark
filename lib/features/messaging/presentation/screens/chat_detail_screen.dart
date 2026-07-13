import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/core/services/notification_service.dart';
import 'package:alu_spark/features/messaging/presentation/providers/message_provider.dart';
import 'package:alu_spark/features/messaging/domain/entities/message.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String contactId;
  final String contactName;

  const ChatDetailScreen({super.key, required this.contactId, required this.contactName});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  String? _conversationId;
  bool _isAtBottom = true;

  @override
  void initState() {
    super.initState();
    _initConversation();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isAtBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50;
      if (isAtBottom != _isAtBottom) {
        setState(() => _isAtBottom = isAtBottom);
      }
    }
  }

  Future<void> _initConversation() async {
    final authState = ref.read(authStateProvider);
    authState.whenData((currentUser) async {
      if (currentUser == null) return;

      final ids = [currentUser.id, widget.contactId]..sort();
      _conversationId = '${ids[0]}_${ids[1]}';
      
      if (mounted) setState(() {});
    });
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent,
          );
        }
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _conversationId == null) return;
    
    final authState = ref.read(authStateProvider);
    authState.whenData((currentUser) async {
      if (currentUser == null) return;

      final messageText = _messageController.text.trim();

      final message = Message(
        id: '',
        conversationId: _conversationId!,
        senderId: currentUser.id,
        text: messageText,
        createdAt: DateTime.now(),
      );

      await ref.read(messageRepositoryProvider).sendMessage(message);
      
      // Send notification to the recipient
      await NotificationService().notifyNewMessage(
        recipientId: widget.contactId,
        senderName: currentUser.fullName.isNotEmpty ? currentUser.fullName : 'Someone',
        conversationId: _conversationId,
      );

      _messageController.clear();
      _scrollToBottom();
    });
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays < 7) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlueLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Contact avatar
            CircleAvatar(
              backgroundColor: AppColors.darkRed,
              radius: 18,
              child: Text(
                widget.contactName.isNotEmpty ? widget.contactName[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contactName,
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                  ),
                  Text(
                    'online',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.green,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _conversationId == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.darkRed),
            )
          : Column(
              children: [
                Expanded(
                  child: ref.watch(messagesProvider(_conversationId!)).when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.darkRed),
                    ),
                    error: (error, _) => Center(
                      child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
                    ),
                    data: (messages) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_isAtBottom && messages.isNotEmpty) {
                          _scrollToBottom(animated: false);
                        }
                      });

                      if (messages.isEmpty) {
                        return _buildEmptyChat();
                      }

                      return GestureDetector(
                        onTap: () => _focusNode.unfocus(),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.backgroundGradient,
                          ),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[index];
                              final authState = ref.read(authStateProvider);
                              bool isSent = false;
                              authState.whenData((user) {
                                isSent = msg.senderId == user?.id;
                              });
                              
                              // Show date separator if new day
                              final showDate = index == 0 || 
                                  _isNewDay(messages[index - 1].createdAt, msg.createdAt);

                              return Column(
                                children: [
                                  if (showDate) _buildDateSeparator(msg.createdAt),
                                  _buildMessageBubble(msg, isSent, index == messages.length - 1),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Jump to bottom button
                if (!_isAtBottom && _conversationId != null)
                  GestureDetector(
                    onTap: () => _scrollToBottom(),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.darkRedLight,
                        child: Icon(Icons.keyboard_arrow_down, color: AppColors.white, size: 20),
                      ),
                    ),
                  ),
                // Message input bar - WhatsApp style
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildEmptyChat() {
    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.chat_bubble_outline, color: AppColors.darkRed, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Start a conversation with ${widget.contactName}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your messages are end-to-end encrypted.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    String dateText;
    if (diff.inDays == 0) {
      dateText = 'Today';
    } else if (diff.inDays == 1) {
      dateText = 'Yesterday';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.glassWhite.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _isNewDay(DateTime a, DateTime b) {
    return a.day != b.day || a.month != b.month || a.year != b.year;
  }

  Widget _buildMessageBubble(Message msg, bool isSent, bool isLast) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 8 : 4,
        left: isSent ? 60 : 0,
        right: isSent ? 0 : 60,
      ),
      child: Align(
        alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSent 
                    ? const Color(0xFF005C4B) // WhatsApp green for sent
                    : AppColors.darkBlueLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isSent ? 16 : 4),
                  bottomRight: Radius.circular(isSent ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(msg.createdAt),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                      if (isSent) ...[
                        const SizedBox(width: 4),
                        Icon(
                          msg.isRead ? Icons.done_all : Icons.done,
                          size: 16,
                          color: msg.isRead 
                              ? const Color(0xFF53BDEB) // Blue double check
                              : Colors.white.withValues(alpha: 0.6),
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

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBlueLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              // Emoji/attachment button
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined, color: AppColors.textSecondary),
                onPressed: () {},
              ),
              // Text field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderGlass),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _focusNode,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          maxLines: 4,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: const InputDecoration(
                            hintText: 'Type a message',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file, color: AppColors.textSecondary, size: 22),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Send button
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF005C4B), // WhatsApp green send button
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: AppColors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}