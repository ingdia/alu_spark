import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
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
  String? _conversationId;

  @override
  void initState() {
    super.initState();
    _initConversation();
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _conversationId == null) return;
    
    final authState = ref.read(authStateProvider);
    authState.whenData((currentUser) {
      if (currentUser == null) return;

      final message = Message(
        id: '',
        conversationId: _conversationId!,
        senderId: currentUser.id,
        text: _messageController.text.trim(),
        createdAt: DateTime.now(),
      );

      ref.read(messageRepositoryProvider).sendMessage(message);
      _messageController.clear();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
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
        title: Text(
          widget.contactName,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
        ),
      ),
      body: _conversationId == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ref.watch(messagesProvider(_conversationId!)).when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text('Error: $error')),
                    data: (messages) {
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final authState = ref.read(authStateProvider);
                          bool isSent = false;
                          authState.whenData((user) {
                            isSent = msg.senderId == user?.id;
                          });
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSent ? AppColors.darkRed : AppColors.glassWhite,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      msg.text,
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.darkBlueLight,
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassmorphicContainer(
                          blur: 10,
                          borderRadius: 25,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _messageController,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.darkRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send, color: AppColors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
