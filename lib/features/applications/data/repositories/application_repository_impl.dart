import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/applications/data/models/application_model.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/features/applications/domain/repositories/application_repository.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'applications';

  ApplicationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> submitApplication(Application application) async {
    final model = ApplicationModel(
      id: '', // Firestore will auto-generate
      opportunityId: application.opportunityId,
      opportunityTitle: application.opportunityTitle,
      startupName: application.startupName,
      studentId: application.studentId,
      studentName: application.studentName,
      studentEmail: application.studentEmail,
      motivation: application.motivation,
      cvUrl: application.cvUrl,
      status: application.status,
      createdAt: application.createdAt,
    );

    await _firestore.collection(_collectionPath).add(model.toFirestore());
  }
@override
  Stream<List<Application>> getApplicationsByStartup(String startupId) {
    return _firestore
        .collection(_collectionPath)
        .where('startupId', isEqualTo: startupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ApplicationModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }
}
  @override
  Stream<List<Application>> getApplicationsByStudent(String studentId) {
    return _firestore
        .collection(_collectionPath)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ApplicationModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }

  @override
  Stream<List<Application>> getApplicationsByOpportunity(String opportunityId) {
    return _firestore
        .collection(_collectionPath)
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ApplicationModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }
}