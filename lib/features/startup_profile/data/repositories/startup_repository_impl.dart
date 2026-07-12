import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/startup_profile/data/models/startup_model.dart';
import 'package:alu_spark/features/startup_profile/domain/entities/startup.dart';
import 'package:alu_spark/features/startup_profile/domain/repositories/startup_repository.dart';

class StartupRepositoryImpl implements StartupRepository {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'startups';

  StartupRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<Startup?> getStartupById(String startupId) {
    return _firestore.collection(_collectionPath).doc(startupId).snapshots().map((doc) {
      if (doc.exists) {
        return StartupModel.fromFirestore(doc).toEntity();
      }
      return null;
    });
  }

  @override
  Future<void> createStartup(Startup startup) async {
    final model = StartupModel(
      id: startup.id,
      name: startup.name,
      tagline: startup.tagline,
      industry: startup.industry,
      description: startup.description,
      founderId: startup.founderId,
      founderName: startup.founderName,
      teamMembers: startup.teamMembers,
      openRolesCount: startup.openRolesCount,
      isVerified: startup.isVerified,
      createdAt: startup.createdAt,
    );
    await _firestore.collection(_collectionPath).doc(startup.id).set(model.toFirestore());
  }

  @override
  Future<void> updateStartup(Startup startup) async {
    final model = StartupModel(
      id: startup.id,
      name: startup.name,
      tagline: startup.tagline,
      industry: startup.industry,
      description: startup.description,
      founderId: startup.founderId,
      founderName: startup.founderName,
      teamMembers: startup.teamMembers,
      openRolesCount: startup.openRolesCount,
      isVerified: startup.isVerified,
      createdAt: startup.createdAt,
    );
    await _firestore.collection(_collectionPath).doc(startup.id).update(model.toFirestore());
  }
}
