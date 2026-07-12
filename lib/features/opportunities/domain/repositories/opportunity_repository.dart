import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

abstract class OpportunityRepository {
  Stream<List<Opportunity>> getOpportunities();
  Stream<List<Opportunity>> getOpportunitiesByCategory(String category);
  Future<Opportunity?> getOpportunityById(String id);
  Future<String> createOpportunity(Opportunity opportunity);
  Future<void> updateOpportunity(Opportunity opportunity);
  Future<void> deleteOpportunity(String id);
  Future<void> incrementApplicationCount(String opportunityId);
}
