import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

abstract class OpportunityRepository {
  // Fetch all active opportunities
  Stream<List<Opportunity>> getOpportunities();
  
  // Fetch opportunities by category
  Stream<List<Opportunity>> getOpportunitiesByCategory(String category);
  
  // Fetch a single opportunity by ID
  Future<Opportunity?> getOpportunityById(String id);
  
  // Create a new opportunity (Founder)
  Future<String> createOpportunity(Opportunity opportunity);
  
  // Update an existing opportunity
  Future<void> updateOpportunity(Opportunity opportunity);
  
  // Delete an opportunity
  Future<void> deleteOpportunity(String id);
  
  // Increment application count
  Future<void> incrementApplicationCount(String opportunityId);
}