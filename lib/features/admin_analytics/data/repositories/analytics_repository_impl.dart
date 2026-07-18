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

    const appStatuses = ['applied', 'underReview', 'interview', 'accepted', 'rejected', 'withdrawn'];
    const oppCategories = ['Technology', 'Business', 'Design', 'Marketing', 'Finance', 'Other'];

    final countQueries = [
      usersCol.where('role', isEqualTo: 'student').count().get(),
      usersCol.where('role', isEqualTo: 'founder').count().get(),
      oppsCol.count().get(),
      appsCol.count().get(),
      ...appStatuses.map((s) => appsCol.where('status', isEqualTo: s).count().get()),
      ...oppCategories.map((c) => oppsCol.where('category', isEqualTo: c).count().get()),
    ];

    final results = await Future.wait(countQueries);

    final totalStudents = results[0].count ?? 0;
    final totalFounders = results[1].count ?? 0;
    final totalOpportunities = results[2].count ?? 0;
    final totalApplications = results[3].count ?? 0;

    final Map<String, int> appsByStatus = {};
    for (var i = 0; i < appStatuses.length; i++) {
      final count = results[4 + i].count ?? 0;
      if (count > 0) appsByStatus[appStatuses[i]] = count;
    }

    final Map<String, int> oppsByCategory = {};
    for (var i = 0; i < oppCategories.length; i++) {
      final count = results[4 + appStatuses.length + i].count ?? 0;
      if (count > 0) oppsByCategory[oppCategories[i]] = count;
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
