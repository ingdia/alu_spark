import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

/// Featured: first 5 active opportunities (shown in horizontal cards).
final featuredOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref
      .watch(opportunityRepositoryProvider)
      .getOpportunities()
      .map((list) => list.take(5).toList());
});

/// Recent: all active opportunities ordered newest-first.
final recentOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).getOpportunities();
});

/// Opportunities posted by a specific startup (for founder dashboard).
final opportunitiesByStartupProvider =
    StreamProvider.family<List<Opportunity>, String>((ref, startupId) {
  return ref
      .watch(opportunityRepositoryProvider)
      .getOpportunities()
      .map((list) => list.where((o) => o.startupId == startupId).toList());
});
