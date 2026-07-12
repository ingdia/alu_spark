import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/notifications/domain/entities/notification.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'system',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      description: description,
      type: type,
      createdAt: createdAt,
      isRead: isRead,
    );
  }
}
