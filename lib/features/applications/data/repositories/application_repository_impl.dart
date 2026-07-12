import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/features/applications/domain/repositories/application_repository.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final FirebaseFirestore _firestore;
  static const _collection = 'applications';

  ApplicationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Application _fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
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
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == d['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _toMap(Application a) => {
        'opportunityId': a.opportunityId,
        'opportunityTitle': a.opportunityTitle,
        'startupId': a.startupId,
        'startupName': a.startupName,
        'studentId': a.studentId,
        'studentName': a.studentName,
        'studentEmail': a.studentEmail,
        'motivation': a.motivation,
        'cvUrl': a.cvUrl,
        'status': a.status.name,
        'createdAt': Timestamp.fromDate(a.createdAt),
      };

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
  Stream<List<Application>> getApplicationsByOpportunity(String opportunityId) {
    return _firestore
        .collection(_collection)
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  @override
  Future<String> createApplication(Application application) async {
    final ref = _firestore.collection(_collection).doc();
    final data = _toMap(application);
    data['createdAt'] = Timestamp.fromDate(DateTime.now());
    await ref.set(data);
    return ref.id;
  }

  @override
  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
    await _firestore.collection(_collection).doc(applicationId).update({'status': status.name});
  }

  @override
  Future<void> deleteApplication(String applicationId) async {
    await _firestore.collection(_collection).doc(applicationId).delete();
  }
}
