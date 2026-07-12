import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/features/opportunities/domain/repositories/opportunity_repository.dart';

class OpportunityRepositoryImpl implements OpportunityRepository {
  final FirebaseFirestore _firestore;

  OpportunityRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('opportunities');

  @override
  Stream<List<Opportunity>> getOpportunities() {
    return _col
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  @override
  Stream<List<Opportunity>> getOpportunitiesByCategory(String category) {
    return _col
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(_fromDoc).toList());
  }

  @override
  Future<Opportunity?> getOpportunityById(String id) async {
    final doc = await _col.doc(id).get();
    return doc.exists ? _fromDoc(doc) : null;
  }

  @override
  Future<String> createOpportunity(Opportunity opportunity) async {
    final ref = _col.doc();
    await ref.set(_toMap(opportunity.copyWith(id: ref.id)));
    return ref.id;
  }

  @override
  Future<void> updateOpportunity(Opportunity opportunity) async {
    await _col.doc(opportunity.id).update(_toMap(opportunity));
  }

  @override
  Future<void> deleteOpportunity(String id) async {
    await _col.doc(id).update({'isActive': false});
  }

  @override
  Future<void> incrementApplicationCount(String opportunityId) async {
    await _col.doc(opportunityId).update({
      'applicationsCount': FieldValue.increment(1),
    });
  }

  Opportunity _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Opportunity(
      id: doc.id,
      title: d['title'] as String? ?? '',
      description: d['description'] as String? ?? '',
      startupId: d['startupId'] as String? ?? '',
      startupName: d['startupName'] as String? ?? '',
      category: d['category'] as String? ?? '',
      location: d['location'] as String? ?? '',
      type: d['type'] as String? ?? '',
      salary: d['salary'] as String?,
      requirements: List<String>.from(d['requirements'] ?? []),
      benefits: List<String>.from(d['benefits'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deadline: (d['deadline'] as Timestamp?)?.toDate(),
      isActive: d['isActive'] as bool? ?? true,
      applicationsCount: d['applicationsCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> _toMap(Opportunity o) => {
        'title': o.title,
        'description': o.description,
        'startupId': o.startupId,
        'startupName': o.startupName,
        'category': o.category,
        'location': o.location,
        'type': o.type,
        'salary': o.salary,
        'requirements': o.requirements,
        'benefits': o.benefits,
        'createdAt': Timestamp.fromDate(o.createdAt),
        'deadline': o.deadline != null ? Timestamp.fromDate(o.deadline!) : null,
        'isActive': o.isActive,
        'applicationsCount': o.applicationsCount,
      };
}
