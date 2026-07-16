import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/opportunities/data/models/opportunity_model.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/features/opportunities/domain/repositories/opportunity_repository.dart';

class OpportunityRepositoryImpl implements OpportunityRepository {
  final FirebaseFirestore _firestore;
  static const _col = 'opportunities';
  static const _appCol = 'applications';

  OpportunityRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  List<Opportunity> _sorted(List<Opportunity> l) =>
      l..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Stream<List<Opportunity>> getOpportunities() {
    return _firestore
        .collection(_col)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) => _sorted(
            s.docs.map((d) => OpportunityModel.fromFirestore(d).toEntity()).toList()));
  }

  @override
  Stream<List<Opportunity>> getOpportunitiesByCategory(String category) {
    return _firestore
        .collection(_col)
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((s) => _sorted(
            s.docs.map((d) => OpportunityModel.fromFirestore(d).toEntity()).toList()));
  }

  @override
  Future<Opportunity?> getOpportunityById(String id) async {
    final doc = await _firestore.collection(_col).doc(id).get();
    return doc.exists ? OpportunityModel.fromFirestore(doc).toEntity() : null;
  }

  @override
  Stream<List<Opportunity>> getOpportunitiesByStartupAll(String startupId) {
    return _firestore
        .collection(_col)
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((s) => _sorted(
            s.docs.map((d) => OpportunityModel.fromFirestore(d).toEntity()).toList()));
  }

  @override
  Future<String> createOpportunity(Opportunity opportunity) async {
    final ref = _firestore.collection(_col).doc();
    final model = OpportunityModel(
      id: ref.id,
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
      status: OpportunityStatus.active,
    );
    await ref.set(model.toFirestore());
    return ref.id;
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
      isActive: opportunity.status == OpportunityStatus.active,
      applicationsCount: opportunity.applicationsCount,
      status: opportunity.status,
    );
    await _firestore.collection(_col).doc(opportunity.id).update(model.toFirestore());
  }

  @override
  Future<void> closeOpportunity(String id) async {
    await _firestore.collection(_col).doc(id).update({
      'status': 'closed',
      'isActive': false,
    });
  }

  @override
  Future<void> archiveOpportunity(String id) async {
    await _firestore.collection(_col).doc(id).update({
      'status': 'archived',
      'isActive': false,
    });
  }

  @override
  Future<void> deleteOpportunity(String id) async {
    await _firestore.collection(_col).doc(id).delete();
  }

  @override
  Future<void> incrementApplicationCount(String opportunityId) async {
    await _firestore
        .collection(_col)
        .doc(opportunityId)
        .update({'applicationsCount': FieldValue.increment(1)});
  }

  @override
  Future<List<String>> getApplicantIds(String opportunityId) async {
    final snap = await _firestore
        .collection(_appCol)
        .where('opportunityId', isEqualTo: opportunityId)
        .get();
    return snap.docs
        .map((d) => (d.data()['studentId'] as String?) ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
  }
}
