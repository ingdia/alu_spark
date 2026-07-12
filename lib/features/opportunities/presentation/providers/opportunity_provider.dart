import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

// Provider for Featured Opportunities
// (For now, we fetch all active opportunities. Later we can add a 'isFeatured' filter)
final featuredOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  final repository = ref.watch(opportunityRepositoryProvider);
  return repository.getOpportunities();
});

// Provider for Recent Opportunities
final recentOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  final repository = ref.watch(opportunityRepositoryProvider);
  return repository.getOpportunities();
});

// Provider for a single opportunity (used in Detail Screen)
final opportunityDetailProvider = StreamProvider.family<Opportunity?, String>((ref, id) {
  final repository = ref.watch(opportunityRepositoryProvider);
  return repository.getOpportunityById(id).asStream();
});