import 'package:alu_spark/features/admin_analytics/domain/entities/platform_stats.dart';

abstract class AnalyticsRepository {
  Future<PlatformStats> getPlatformStats();
}
