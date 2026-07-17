import 'package:alu_spark/features/messaging/domain/entities/room.dart';
import 'package:alu_spark/features/messaging/domain/entities/room_message.dart';

abstract class RoomRepository {
  Stream<List<Room>> getRooms();
  Stream<List<RoomMessage>> getRoomMessages(String roomId);
  Future<String> createRoom({
    required String title,
    required String description,
    required String createdBy,
    required String createdByName,
  });
  Future<void> joinRoom(String roomId, String userId);
  Future<void> leaveRoom(String roomId, String userId);
  Future<void> sendRoomMessage(RoomMessage message);
}
