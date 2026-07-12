import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/admin_analytics/domain/entities/platform_stats.dart';

final platformStatsProvider = FutureProvider<PlatformStats>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getPlatformStats();
});
