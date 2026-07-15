import 'package:cloud_firestore/cloud_firestore.dart';

/// Automatically creates Firestore notifications for every key app event.
/// Never throws — failures are swallowed so they never block core actions.
class NotificationService {
  final FirebaseFirestore _firestore;

  NotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _col = 'notifications';

  Future<void> _create({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) async {
    try {
      await _firestore.collection(_col).add({
        'userId': userId,
        'title': title,
        'description': body,
        'type': type,
        'isRead': false,
        'relatedId': relatedId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ── Student-facing ────────────────────────────────────────────────────────

  /// Student submitted an application → notify the founder.
  Future<void> notifyNewApplication({
    required String startupId,
    required String studentName,
    required String opportunityTitle,
    String? applicationId,
  }) =>
      _create(
        userId: startupId,
        title: 'New Application Received',
        body: '$studentName applied for "$opportunityTitle"',
        type: 'application',
        relatedId: applicationId,
      );

  /// Founder moved application to Under Review → notify student.
  Future<void> notifyUnderReview({
    required String studentId,
    required String opportunityTitle,
    String? applicationId,
  }) =>
      _create(
        userId: studentId,
        title: 'Application Under Review',
        body: 'Your application for "$opportunityTitle" is now being reviewed.',
        type: 'application',
        relatedId: applicationId,
      );

  /// Founder scheduled an interview → notify student.
  Future<void> notifyInterviewScheduled({
    required String studentId,
    required String opportunityTitle,
    required String startupName,
    String? interviewDate,
    String? applicationId,
  }) =>
      _create(
        userId: studentId,
        title: 'Interview Scheduled 🎉',
        body: interviewDate != null
            ? '$startupName scheduled your interview for "$opportunityTitle" on $interviewDate.'
            : '$startupName scheduled an interview for "$opportunityTitle".',
        type: 'application',
        relatedId: applicationId,
      );

  /// Founder updated interview details → notify student.
  Future<void> notifyInterviewUpdated({
    required String studentId,
    required String opportunityTitle,
    String? applicationId,
  }) =>
      _create(
        userId: studentId,
        title: 'Interview Details Updated',
        body: 'The interview details for "$opportunityTitle" have been updated.',
        type: 'application',
        relatedId: applicationId,
      );

  /// Application accepted → notify student.
  Future<void> notifyAccepted({
    required String studentId,
    required String opportunityTitle,
    required String startupName,
    String? applicationId,
  }) =>
      _create(
        userId: studentId,
        title: 'Application Accepted 🎉',
        body: 'Congratulations! $startupName accepted your application for "$opportunityTitle".',
        type: 'application',
        relatedId: applicationId,
      );

  /// Application rejected → notify student.
  Future<void> notifyRejected({
    required String studentId,
    required String opportunityTitle,
    String? applicationId,
  }) =>
      _create(
        userId: studentId,
        title: 'Application Update',
        body: 'Your application for "$opportunityTitle" was not selected this time.',
        type: 'application',
        relatedId: applicationId,
      );

  /// Student withdrew → notify founder.
  Future<void> notifyWithdrawn({
    required String startupId,
    required String studentName,
    required String opportunityTitle,
    String? applicationId,
  }) =>
      _create(
        userId: startupId,
        title: 'Application Withdrawn',
        body: '$studentName withdrew their application for "$opportunityTitle".',
        type: 'application',
        relatedId: applicationId,
      );

  // ── Opportunity ───────────────────────────────────────────────────────────

  /// Opportunity closed → notify all applicants.
  Future<void> notifyOpportunityClosed({
    required List<String> studentIds,
    required String opportunityTitle,
    String? opportunityId,
  }) async {
    for (final id in studentIds) {
      await _create(
        userId: id,
        title: 'Opportunity Closed',
        body: 'The opportunity "$opportunityTitle" has been closed.',
        type: 'system',
        relatedId: opportunityId,
      );
    }
  }

  // ── Messaging ─────────────────────────────────────────────────────────────

  Future<void> notifyNewMessage({
    required String recipientId,
    required String senderName,
    String? conversationId,
  }) =>
      _create(
        userId: recipientId,
        title: 'New Message',
        body: 'You have a new message from $senderName.',
        type: 'message',
        relatedId: conversationId,
      );

  // ── Startup verification ──────────────────────────────────────────────────

  Future<void> notifyStartupStatus({
    required String founderId,
    required String startupName,
    required String status,
  }) =>
      _create(
        userId: founderId,
        title: status == 'approved'
            ? 'Startup Approved! 🎉'
            : 'Startup Application Rejected',
        body: status == 'approved'
            ? 'Your startup "$startupName" has been approved. You can now post opportunities!'
            : 'Your startup "$startupName" application was not approved. Please contact support.',
        type: 'system',
      );
}
