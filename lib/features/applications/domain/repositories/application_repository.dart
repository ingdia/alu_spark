import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

abstract class ApplicationRepository {
  Stream<List<Application>> getApplicationsByStudent(String studentId);
  Stream<List<Application>> getApplicationsByOpportunity(String opportunityId);
  Future<String> createApplication(Application application);
  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status);
  Future<void> deleteApplication(String applicationId);
}
