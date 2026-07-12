import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/features/opportunities/data/repositories/opportunity_repository_impl.dart';
import 'package:alu_spark/features/opportunities/domain/repositories/opportunity_repository.dart';

// Provide the Opportunity Repository
final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepositoryImpl();
});