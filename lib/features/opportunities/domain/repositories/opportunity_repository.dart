import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

abstract class OpportunityRepository {
  Stream<List<Opportunity>> getOpportunities();
  Stream<List<Opportunity>> getOpportunitiesByCategory(String category);
  Future<Opportunity?> getOpportunityById(String id);
  Future<String> createOpportunity(Opportunity opportunity);
  Future<void> updateOpportunity(Opportunity opportunity);
  Future<void> deleteOpportunity(String id);
  Future<void> closeOpportunity(String id);
  Future<void> archiveOpportunity(String id);
  Future<void> incrementApplicationCount(String opportunityId);
  /// Returns all opportunities for a startup regardless of status (for founder dashboard).
  Stream<List<Opportunity>> getOpportunitiesByStartupAll(String startupId);
  /// Returns applicant student IDs for an opportunity (for notifications).
  Future<List<String>> getApplicantIds(String opportunityId);
}
