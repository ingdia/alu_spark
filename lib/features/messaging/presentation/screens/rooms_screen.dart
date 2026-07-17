import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/features/messaging/domain/entities/room.dart';
import 'package:alu_spark/features/messaging/presentation/providers/room_provider.dart';

class RoomsScreen extends ConsumerWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);
    final myId = fb.FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        backgroundColor: AppColors.darkRed,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text('New Room',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
      ),
      body: roomsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading rooms…'),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
        data: (rooms) => rooms.isEmpty
            ? _buildEmpty(context, ref)
            : _buildList(context, ref, rooms, myId),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.forum_outlined,
                size: 48, color: AppColors.darkRed),
          ),
          const SizedBox(height: 20),
          Text('No Rooms Yet',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
          const SizedBox(height: 8),
          Text('Create the first room and start a discussion.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showCreateDialog(context, ref),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.redGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('Create a Room',
                  style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<Room> rooms,
      String myId) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: rooms.length,
      itemBuilder: (_, i) => _RoomCard(room: rooms[i], myId: myId),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBlueLight,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.borderGlass,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Create a Room',
                style: AppTextStyles.headingMedium
                    .copyWith(color: AppColors.white)),
            const SizedBox(height: 4),
            Text('Start a public discussion anyone can join.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            _sheetField(titleCtrl, 'Room title (e.g. "Startup Ideas 2025")',
                Icons.title),
            const SizedBox(height: 12),
            _sheetField(
                descCtrl, 'What is this room about?', Icons.info_outline,
                maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  final fbUser = fb.FirebaseAuth.instance.currentUser;
                  if (fbUser == null) return;
                  Navigator.of(ctx).pop();
                  final roomId =
                      await ref.read(roomRepositoryProvider).createRoom(
                            title: title,
                            description: descCtrl.text.trim(),
                            createdBy: fbUser.uid,
                            createdByName:
                                fbUser.displayName ?? 'Anonymous',
                          );
                  if (ctx.mounted) {
                    Navigator.of(ctx).pushNamed(RouteNames.roomDetail,
                        arguments: roomId);
                  }
                },
                child: Text('Create Room',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sheetField(
      TextEditingController ctrl, String hint, IconData icon,
      {int maxLines = 1}) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.darkRed, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _RoomCard extends ConsumerWidget {
  final Room room;
  final String myId;

  const _RoomCard({required this.room, required this.myId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMember = room.isMember(myId);
    final timeLabel = _fmtTime(room.lastMessageTime);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () async {
          if (!isMember) {
            await ref.read(roomRepositoryProvider).joinRoom(room.id, myId);
          }
          if (context.mounted) {
            Navigator.of(context)
                .pushNamed(RouteNames.roomDetail, arguments: room.id);
          }
        },
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.forum_outlined,
                    color: AppColors.darkRed, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(room.title,
                              style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(timeLabel,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11)),
                      ],
                    ),
                    if (room.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(room.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people_outline,
                            color: AppColors.textSecondary, size: 13),
                        const SizedBox(width: 4),
                        Text('${room.memberCount} members',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(room.lastMessage,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isMember
                      ? AppColors.darkRed.withValues(alpha: 0.2)
                      : AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isMember
                        ? AppColors.darkRed.withValues(alpha: 0.5)
                        : AppColors.borderGlass,
                  ),
                ),
                child: Text(
                  isMember ? 'Joined' : 'Join',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isMember ? AppColors.darkRed : AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
