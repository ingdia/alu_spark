import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/messaging/domain/entities/room.dart';
import 'package:alu_spark/features/messaging/domain/entities/room_message.dart';

final roomsProvider = StreamProvider.autoDispose<List<Room>>((ref) {
  return ref.watch(roomRepositoryProvider).getRooms();
});

final roomMessagesProvider =
    StreamProvider.autoDispose.family<List<RoomMessage>, String>((ref, roomId) {
  return ref.watch(roomRepositoryProvider).getRoomMessages(roomId);
});
