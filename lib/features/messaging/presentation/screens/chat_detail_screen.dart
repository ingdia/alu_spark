import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String contactName;
  final String contactRole;

  const ChatDetailScreen({
    super.key,
    required this.contactName,
    required this.contactRole,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Using final for lists to align with project conventions
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi! I saw your application for the Frontend Developer position.',
      'isSent': false,
      'time': '10:30 AM',
    },
    {
      'text': 'Yes, that\'s correct! I\'m very interested in the role.',
      'isSent': true,
      'time': '10:32 AM',
    },
    {
      'text': 'Great! We reviewed your portfolio and were impressed with your work.',
      'isSent': false,
      'time': '10:33 AM',
    },
    {
      'text': 'Thank you so much! I\'ve been working on Flutter projects for the past year.',
      'isSent': true,
      'time': '10:35 AM',
    },
    {
      'text': 'We\'d love to schedule an interview to discuss the role in more detail. Are you available this week?',
      'isSent': false,
      'time': '10:36 AM',
    },
    {
      'text': 'Absolutely! I\'m available Wednesday or Thursday afternoon.',
      'isSent': true,
      'time': '10:38 AM',
    },
    {
      'text': 'Perfect! Let\'s schedule for Thursday at 2 PM. I\'ll send you a calendar invite.',
      'isSent': false,
      'time': '10:40 AM',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.darkBlueLight,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
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
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.darkRed.withOpacity(0.2),
            child: Text(
              widget.contactName.substring(0, 1),
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkRed),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.contactName,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
              ),
              Text(
                widget.contactRole,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.all(0),
            child: IconButton(
              icon: const Icon(Icons.call_outlined, color: AppColors.white, size: 20),
              onPressed: () {
                // TODO: Initiate call
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.all(0),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.white, size: 20),
              onPressed: () {
                // TODO: Show more options
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final bool isSent = message['isSent'] as bool;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.darkRed.withOpacity(0.2),
                child: Text(
                  widget.contactName.substring(0, 1),
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkRed),
                ),
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSent ? AppColors.darkRed : AppColors.glassWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isSent ? 16 : 4),
                  bottomRight: Radius.circular(isSent ? 4 : 16),
                ),
                border: isSent ? null : Border.all(color: AppColors.borderGlass),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      message['time'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlueLight,
        border: Border(top: BorderSide(color: AppColors.borderGlass, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: GlassmorphicContainer(
                blur: 10,
                borderRadius: 25,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _messageController,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text.trim(),
          'isSent': true,
          'time': 'Now',
        });
        _messageController.clear();
      });
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      
      // TODO: Trigger provider to send message to Firebase
    }
  }
}