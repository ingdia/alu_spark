import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/admin_analytics/domain/entities/platform_stats.dart';
import 'package:alu_spark/features/admin_analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final FirebaseFirestore _firestore;

  AnalyticsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<PlatformStats> getPlatformStats() async {
    final usersCol = _firestore.collection('users');
    final oppsCol = _firestore.collection('opportunities');
    final appsCol = _firestore.collection('applications');

    // Parallel aggregation counts
    final results = await Future.wait([
      usersCol.where('role', isEqualTo: 'student').count().get(),
      usersCol.where('role', isEqualTo: 'founder').count().get(),
      oppsCol.count().get(),
      appsCol.count().get(),
    ]);

    final totalStudents = results[0].count ?? 0;
    final totalFounders = results[1].count ?? 0;
    final totalOpportunities = results[2].count ?? 0;
    final totalApplications = results[3].count ?? 0;

    // Applications by status — fetch only the status field
    final appsSnap = await appsCol.get();
    final Map<String, int> appsByStatus = {};
    for (final doc in appsSnap.docs) {
      final status = (doc.data()['status'] as String?) ?? 'applied';
      appsByStatus[status] = (appsByStatus[status] ?? 0) + 1;
    }

    // Opportunities by category — fetch only the category field
    final oppsSnap = await oppsCol.get();
    final Map<String, int> oppsByCategory = {};
    for (final doc in oppsSnap.docs) {
      final category = (doc.data()['category'] as String?) ?? 'Other';
      oppsByCategory[category] = (oppsByCategory[category] ?? 0) + 1;
    }

    return PlatformStats(
      totalStudents: totalStudents,
      totalFounders: totalFounders,
      totalOpportunities: totalOpportunities,
      totalApplications: totalApplications,
      applicationsByStatus: appsByStatus,
      opportunitiesByCategory: oppsByCategory,
    );
  }
}
