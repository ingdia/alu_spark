import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

/// Featured: first 5 active opportunities (shown in horizontal cards).
/// Uses autoDispose with skipLoadingOnReload to prevent UI flashing.
final featuredOpportunitiesProvider = StreamProvider.autoDispose<List<Opportunity>>((ref) {
  final repo = ref.watch(opportunityRepositoryProvider);
  return repo.getOpportunities().map((list) => list.take(5).toList());
});

/// Recent: all active opportunities ordered newest-first.
/// Uses autoDispose with skipLoadingOnReload to prevent UI flashing.
final recentOpportunitiesProvider = StreamProvider.autoDispose<List<Opportunity>>((ref) {
  final repo = ref.watch(opportunityRepositoryProvider);
  return repo.getOpportunities();
});

/// Opportunities posted by a specific startup (for founder dashboard).
final opportunitiesByStartupProvider =
    StreamProvider.autoDispose.family<List<Opportunity>, String>((ref, startupId) {
  final repo = ref.watch(opportunityRepositoryProvider);
  return repo.getOpportunities().map((list) => list.where((o) => o.startupId == startupId).toList());
});