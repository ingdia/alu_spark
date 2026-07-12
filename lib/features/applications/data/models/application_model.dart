import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

class ApplicationModel {
  // ... (keep existing fields, add startupId)
  final String startupId;

  ApplicationModel({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId, // Added
    required this.startupName,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.motivation,
    required this.cvUrl,
    required this.status,
    required this.createdAt,
  });

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id: doc.id,
      opportunityId: data['opportunityId'] ?? '',
      opportunityTitle: data['opportunityTitle'] ?? '',
      startupId: data['startupId'] ?? '', // Added
      startupName: data['startupName'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentEmail: data['studentEmail'] ?? '',
      motivation: data['motivation'] ?? '',
      cvUrl: data['cvUrl'] ?? '',
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupId': startupId, // Added
      'startupName': startupName,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'motivation': motivation,
      'cvUrl': cvUrl,
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Application toEntity() {
    return Application(
      id: id,
      opportunityId: opportunityId,
      opportunityTitle: opportunityTitle,
      startupId: startupId, // Added
      startupName: startupName,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      motivation: motivation,
      cvUrl: cvUrl,
      status: status,
      createdAt: createdAt,
    );
  }
}