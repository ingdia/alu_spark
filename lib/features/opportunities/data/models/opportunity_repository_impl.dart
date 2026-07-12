import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/opportunities/data/models/opportunity_model.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/features/opportunities/domain/repositories/opportunity_repository.dart';

class OpportunityRepositoryImpl implements OpportunityRepository {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'opportunities';

  OpportunityRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Opportunity>> getOpportunities() {
    return _firestore
        .collection(_collectionPath)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final l = snapshot.docs.map((doc) => OpportunityModel.fromFirestore(doc).toEntity()).toList();
      l.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return l;
    });
  }

  @override
  Stream<List<Opportunity>> getOpportunitiesByCategory(String category) {
    return _firestore
        .collection(_collectionPath)
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final l = snapshot.docs.map((doc) => OpportunityModel.fromFirestore(doc).toEntity()).toList();
      l.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return l;
    });
  }

  @override
  Future<Opportunity?> getOpportunityById(String id) async {
    final doc = await _firestore.collection(_collectionPath).doc(id).get();
    if (doc.exists) {
      return OpportunityModel.fromFirestore(doc).toEntity();
    }
    return null;
  }

  @override
  Future<String> createOpportunity(Opportunity opportunity) async {
    final docRef = _firestore.collection(_collectionPath).doc();
    
    final model = OpportunityModel(
      id: docRef.id,
      title: opportunity.title,
      description: opportunity.description,
      startupId: opportunity.startupId,
      startupName: opportunity.startupName,
      category: opportunity.category,
      location: opportunity.location,
      type: opportunity.type,
      salary: opportunity.salary,
      requirements: opportunity.requirements,
      benefits: opportunity.benefits,
      createdAt: DateTime.now(),
      deadline: opportunity.deadline,
      isActive: true,
      applicationsCount: 0,
    );

    await docRef.set(model.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> updateOpportunity(Opportunity opportunity) async {
    final model = OpportunityModel(
      id: opportunity.id,
      title: opportunity.title,
      description: opportunity.description,
      startupId: opportunity.startupId,
      startupName: opportunity.startupName,
      category: opportunity.category,
      location: opportunity.location,
      type: opportunity.type,
      salary: opportunity.salary,
      requirements: opportunity.requirements,
      benefits: opportunity.benefits,
      createdAt: opportunity.createdAt,
      deadline: opportunity.deadline,
      isActive: opportunity.isActive,
      applicationsCount: opportunity.applicationsCount,
    );

    await _firestore.collection(_collectionPath).doc(opportunity.id).update(model.toFirestore());
  }

  @override
  Future<void> deleteOpportunity(String id) async {
    // Soft delete: just set isActive to false
    await _firestore.collection(_collectionPath).doc(id).update({'isActive': false});
  }

  @override
  Future<void> incrementApplicationCount(String opportunityId) async {
    await _firestore.collection(_collectionPath).doc(opportunityId).update({
      'applicationsCount': FieldValue.increment(1),
    });
  }
}