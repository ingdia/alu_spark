import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/features/applications/domain/repositories/application_repository.dart';
import 'package:alu_spark/shared/enums/application_status.dart';
import 'package:alu_spark/core/services/notification_service.dart';
import 'package:alu_spark/features/messaging/domain/repositories/message_repository.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final FirebaseFirestore _firestore;
  final NotificationService _notifications;
  final MessageRepository? _messaging;
  static const _collection = 'applications';

  ApplicationRepositoryImpl({
    FirebaseFirestore? firestore,
    NotificationService? notifications,
    this._messaging,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notifications = notifications ?? NotificationService();

  Application _fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final createdAt = (d['createdAt'] as Timestamp).toDate();
    return Application(
      id: doc.id,
      opportunityId: d['opportunityId'] ?? '',
      opportunityTitle: d['opportunityTitle'] ?? '',
      startupId: d['startupId'] ?? '',
      startupName: d['startupName'] ?? '',
      studentId: d['studentId'] ?? '',
      studentName: d['studentName'] ?? '',
      studentEmail: d['studentEmail'] ?? '',
      motivation: d['motivation'] ?? '',
      cvUrl: d['cvUrl'] ?? '',
      status: ApplicationStatus.fromFirestore(d['status'] as String?),
      createdAt: createdAt,
      updatedAt: d['updatedAt'] != null
          ? (d['updatedAt'] as Timestamp).toDate()
          : createdAt,
      interviewDate: d['interviewDate'] != null
          ? (d['interviewDate'] as Timestamp).toDate()
          : null,
      interviewTime: d['interviewTime'] as String?,
      interviewLocation: d['interviewLocation'] as String?,
      meetingLink: d['meetingLink'] as String?,
      interviewNotes: d['interviewNotes'] as String?,
    );
  }

  Map<String, dynamic> _toMap(Application a) {
    final map = <String, dynamic>{
      'opportunityId': a.opportunityId,
      'opportunityTitle': a.opportunityTitle,
      'startupId': a.startupId,
      'startupName': a.startupName,
      'studentId': a.studentId,
      'studentName': a.studentName,
      'studentEmail': a.studentEmail,
      'motivation': a.motivation,
      'cvUrl': a.cvUrl,
      'status': a.status.firestoreValue,
      'createdAt': Timestamp.fromDate(a.createdAt),
      'updatedAt': Timestamp.fromDate(a.updatedAt),
    };
    if (a.interviewDate != null) {
      map['interviewDate'] = Timestamp.fromDate(a.interviewDate!);
    }
    if (a.interviewTime != null) map['interviewTime'] = a.interviewTime;
    if (a.interviewLocation != null) {
      map['interviewLocation'] = a.interviewLocation;
    }
    if (a.meetingLink != null) map['meetingLink'] = a.meetingLink;
    if (a.interviewNotes != null) map['interviewNotes'] = a.interviewNotes;
    return map;
  }

  @override
  Future<void> submitApplication(Application application) async {
    final ref = _firestore.collection(_collection)
        .doc('${application.studentId}_${application.opportunityId}');
    final now = DateTime.now();
    final data = _toMap(application);
    data['createdAt'] = Timestamp.fromDate(now);
    data['updatedAt'] = Timestamp.fromDate(now);
    await ref.set(data);
  }

  @override
  Stream<List<Application>> getApplicationsByStartup(String startupId) {
    return _firestore
        .collection(_collection)
        .where('startupId', isEqualTo: startupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  @override
  Stream<List<Application>> getApplicationsByStudent(String studentId) {
    return _firestore
        .collection(_collection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  @override
  Future<bool> hasApplied(String studentId, String opportunityId) async {
    final snap = await _firestore
        .collection(_collection)
        .where('studentId', isEqualTo: studentId)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  @override
  Stream<Application?> getApplicationForOpportunity(
      String studentId, String opportunityId) {
    return _firestore
        .collection(_collection)
        .where('studentId', isEqualTo: studentId)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty ? null : _fromDoc(s.docs.first));
  }

  @override
  Future<void> withdrawApplication(String applicationId) async {
    await _validateTransition(applicationId, ApplicationStatus.withdrawn);
    final doc = await _firestore.collection(_collection).doc(applicationId).get();
    final data = doc.data() as Map<String, dynamic>;

    await _firestore.collection(_collection).doc(applicationId).update({
      'status': ApplicationStatus.withdrawn.firestoreValue,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    // Notify the startup founder that the student withdrew.
    await _notifications.notifyWithdrawn(
      startupId: data['startupId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? 'A student',
      opportunityTitle: data['opportunityTitle'] as String? ?? '',
      applicationId: applicationId,
    );
  }

  @override
  Future<void> updateApplicationStatus(
      String applicationId, ApplicationStatus next) async {
    await _validateTransition(applicationId, next);
    final doc = await _firestore.collection(_collection).doc(applicationId).get();
    final data = doc.data() as Map<String, dynamic>;

    await _firestore.collection(_collection).doc(applicationId).update({
      'status': next.firestoreValue,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    final studentId = data['studentId'] as String? ?? '';
    final opportunityTitle = data['opportunityTitle'] as String? ?? '';
    final startupName = data['startupName'] as String? ?? '';

    switch (next) {
      case ApplicationStatus.underReview:
        await _notifications.notifyUnderReview(
          studentId: studentId,
          opportunityTitle: opportunityTitle,
          applicationId: applicationId,
        );
      case ApplicationStatus.interview:
        await _notifications.notifyInterviewScheduled(
          studentId: studentId,
          opportunityTitle: opportunityTitle,
          startupName: startupName,
          applicationId: applicationId,
        );
        // Auto-open conversation between founder and student.
        await _messaging?.openConversationForInterview(
          founderId: data['startupId'] as String? ?? '',
          founderName: startupName,
          studentId: studentId,
          studentName: data['studentName'] as String? ?? '',
          opportunityTitle: opportunityTitle,
          applicationId: applicationId,
        );
      case ApplicationStatus.accepted:
        await _notifications.notifyAccepted(
          studentId: studentId,
          opportunityTitle: opportunityTitle,
          startupName: startupName,
          applicationId: applicationId,
        );
      case ApplicationStatus.rejected:
        await _notifications.notifyRejected(
          studentId: studentId,
          opportunityTitle: opportunityTitle,
          applicationId: applicationId,
        );
      default:
        break;
    }
  }

  @override
  Future<void> updateApplicationWithInterview({
    required String applicationId,
    required ApplicationStatus status,
    DateTime? interviewDate,
    String? interviewTime,
    String? interviewLocation,
    String? meetingLink,
    String? interviewNotes,
  }) async {
    // Read current doc to determine if this is a new interview or an update.
    final doc =
        await _firestore.collection(_collection).doc(applicationId).get();
    if (!doc.exists) throw Exception('Application not found.');
    final data = doc.data() as Map<String, dynamic>;
    final current =
        ApplicationStatus.fromFirestore(data['status'] as String?);
    final isNewInterview = current != ApplicationStatus.interview;

    if (isNewInterview) {
      await _validateTransition(applicationId, status);
    }

    final update = <String, dynamic>{
      'status': status.firestoreValue,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
    if (interviewDate != null) {
      update['interviewDate'] = Timestamp.fromDate(interviewDate);
    }
    if (interviewTime != null) update['interviewTime'] = interviewTime;
    if (interviewLocation != null) {
      update['interviewLocation'] = interviewLocation;
    }
    if (meetingLink != null) update['meetingLink'] = meetingLink;
    if (interviewNotes != null) update['interviewNotes'] = interviewNotes;

    await _firestore.collection(_collection).doc(applicationId).update(update);

    final studentId = data['studentId'] as String? ?? '';
    final opportunityTitle = data['opportunityTitle'] as String? ?? '';
    final startupName = data['startupName'] as String? ?? '';

    String? dateLabel;
    if (interviewDate != null) {
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      dateLabel =
          '${interviewDate.day} ${months[interviewDate.month]} ${interviewDate.year}';
    }

    if (isNewInterview) {
      await _notifications.notifyInterviewScheduled(
        studentId: studentId,
        opportunityTitle: opportunityTitle,
        startupName: startupName,
        interviewDate: dateLabel,
        applicationId: applicationId,
      );
    } else {
      await _notifications.notifyInterviewUpdated(
        studentId: studentId,
        opportunityTitle: opportunityTitle,
        applicationId: applicationId,
      );
    }
  }

  Future<void> _validateTransition(
      String applicationId, ApplicationStatus next) async {
    final doc =
        await _firestore.collection(_collection).doc(applicationId).get();
    if (!doc.exists) throw Exception('Application not found.');
    final data = doc.data() as Map<String, dynamic>;
    final current =
        ApplicationStatus.fromFirestore(data['status'] as String?);
    if (!current.canTransitionTo(next)) {
      throw Exception(
        'Invalid transition: ${current.displayName} → ${next.displayName}.',
      );
    }
  }

  Stream<List<Application>> getApplicationsByOpportunity(
      String opportunityId) {
    return _firestore
        .collection(_collection)
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }
}
