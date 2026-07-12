import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

final featuredOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).getOpportunities();
});

final recentOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).getOpportunities();
});
