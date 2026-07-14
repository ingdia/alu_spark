import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to automatically create notifications in Firestore
/// when key events happen in the app.
class NotificationService {
  final FirebaseFirestore _firestore;
  
  NotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _collection = 'notifications';

  /// Creates a notification for a user.
  Future<void> createNotification({
    required String userId,
    required String title,
    required String description,
    required String type, // 'application', 'message', 'startup_review', 'system'
    String? relatedId,
  }) async {
    try {
      await _firestore.collection(_collection).add({
        'userId': userId,
        'title': title,
        'description': description,
        'type': type,
        'isRead': false,
        'relatedId': relatedId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail - notifications should never block core functionality
      // ignore: avoid_print
      print('Failed to create notification: $e');
    }
  }

  /// Notify startup founder when a student applies.
  Future<void> notifyNewApplication({
    required String startupId,
    required String studentName,
    required String opportunityTitle,
    String? applicationId,
  }) async {
    await createNotification(
      userId: startupId,
      title: 'New Application Received',
      description: '$studentName applied for $opportunityTitle',
      type: 'application',
      relatedId: applicationId,
    );
  }

  /// Notify a user when they receive a new message.
  Future<void> notifyNewMessage({
    required String recipientId,
    required String senderName,
    String? conversationId,
  }) async {
    await createNotification(
      userId: recipientId,
      title: 'New Message',
      description: 'You have a new message from $senderName',
      type: 'message',
      relatedId: conversationId,
    );
  }

  /// Notify startup founder about verification status change.
  Future<void> notifyStartupStatus({
    required String founderId,
    required String startupName,
    required String status, // 'approved' or 'rejected'
  }) async {
    final title = status == 'approved' 
        ? 'Startup Approved! 🎉'
        : 'Startup Application Rejected';
    final description = status == 'approved'
        ? 'Your startup "$startupName" has been approved. You can now post opportunities!'
        : 'Your startup "$startupName" application was not approved. Please contact support.';
    
    await createNotification(
      userId: founderId,
      title: title,
      description: description,
      type: 'startup_review',
    );
  }
}