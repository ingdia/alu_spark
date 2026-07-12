import 'package:alu_spark/features/applications/domain/entities/application.dart';

abstract class ApplicationRepository {
  // Submit a new application
  Future<void> submitApplication(Application application);
  
  // Get applications for a specific student
  Stream<List<Application>> getApplicationsByStudent(String studentId);
  
  // Get applications for a specific opportunity (for founders)
  Stream<List<Application>> getApplicationsByOpportunity(String opportunityId);
}