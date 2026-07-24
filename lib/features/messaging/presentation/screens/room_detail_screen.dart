import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/messaging/domain/entities/room.dart';
import 'package:alu_spark/features/messaging/domain/entities/room_message.dart';
import 'package:alu_spark/features/messaging/presentation/providers/room_provider.dart';

class RoomDetailScreen extends ConsumerStatefulWidget {
  final String roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();

  String get _myId => fb.FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _myName =>
      fb.FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    await ref.read(roomRepositoryProvider).sendRoomMessage(RoomMessage(
          id: '',
          roomId: widget.roomId,
          senderId: _myId,
          senderName: _myName,
          text: text,
          createdAt: DateTime.now(),
        ));
    _scrollToBottom();
  }

  Future<void> _leaveRoom(Room room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkBlueLight,
        title: Text('Leave Room',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
        content: Text('Leave "${room.title}"?',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Leave',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.darkRed)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(roomRepositoryProvider).leaveRoom(room.id, _myId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    final room = roomsAsync.value?.firstWhere(
      (r) => r.id == widget.roomId,
      orElse: () => Room(
        id: widget.roomId,
        title: 'Room',
        description: '',
        createdBy: '',
        createdByName: '',
        createdAt: DateTime.now(),
        memberIds: const [],
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        memberCount: 0,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(room),
      body: Column(
        children: [
          if (room != null && room.description.isNotEmpty)
            _buildDescriptionBanner(room.description),
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Room? room) {
    return AppBar(
      backgroundColor: AppColors.darkBlueLight,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.forum_outlined,
                color: AppColors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room?.title ?? 'Room',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.white)),
                Text('${room?.memberCount ?? 0} members',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (room != null)
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.textSecondary),
            tooltip: 'Leave room',
            onPressed: () => _leaveRoom(room),
          ),
      ],
    );
  }

  Widget _buildDescriptionBanner(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.darkRed.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              color: AppColors.darkRedLight, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(description,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ref.watch(roomMessagesProvider(widget.roomId)).when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.darkRed)),
          error: (e, _) =>
              Center(child: Text('$e', style: const TextStyle(color: Colors.red))),
          data: (msgs) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _scrollToBottom());

            if (msgs.isEmpty) {
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
                      child: const Icon(Icons.forum_outlined,
                          color: AppColors.darkRed, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text('No messages yet',
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.white)),
                    const SizedBox(height: 6),
                    Text('Be the first to say something!',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              );
            }

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
                  final showName = i == 0 ||
                      msgs[i - 1].senderId != msg.senderId;
                  return Column(
                    children: [
                      if (showDate) _buildDateSep(msg.createdAt),
                      _buildBubble(msg, showName),
                    ],
                  );
                },
              ),
            );
          },
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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

  Widget _buildBubble(RoomMessage msg, bool showName) {
    final isMine = msg.senderId == _myId;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 4,
        left: isMine ? 56 : 0,
        right: isMine ? 0 : 56,
      ),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (showName && !isMine)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(msg.senderName,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkRedLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine
                    ? const Color(0xFF1A3A2A)
                    : AppColors.darkBlueLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: isMine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(msg.text,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15, height: 1.35)),
                  const SizedBox(height: 3),
                  Text(
                    _fmtTime(msg.createdAt),
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                            hintText: 'Say something…',
                            hintStyle:
                                TextStyle(color: AppColors.textSecondary),
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
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
