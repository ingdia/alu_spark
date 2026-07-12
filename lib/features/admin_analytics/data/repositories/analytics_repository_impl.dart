import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/admin_analytics/domain/entities/platform_stats.dart';
import 'package:alu_spark/features/admin_analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final FirebaseFirestore _firestore;

  AnalyticsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<PlatformStats> getPlatformStats() async {
    // Note: In a production app, use Cloud Functions to maintain a 'stats' document 
    // to avoid reading entire collections on every load.
    final usersSnap = await _firestore.collection('users').get();
    final oppsSnap = await _firestore.collection('opportunities').get();
    final appsSnap = await _firestore.collection('applications').get();

    int students = 0;
    int founders = 0;

    for (var doc in usersSnap.docs) {
      final role = doc.data()['role'];
      if (role == 'student') students++;
      if (role == 'founder') founders++;
    }

    return PlatformStats(
      totalStudents: students,
      totalFounders: founders,
      totalOpportunities: oppsSnap.size,
      totalApplications: appsSnap.size,
    );
  }
}
