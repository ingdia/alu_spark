import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

abstract class ApplicationRepository {
  Future<void> submitApplication(Application application);
  Stream<List<Application>> getApplicationsByStudent(String studentId);
  Stream<List<Application>> getApplicationsByStartup(String startupId);
  Stream<Application?> getApplicationById(String applicationId);
  Future<bool> hasApplied(String studentId, String opportunityId);
  Stream<Application?> getApplicationForOpportunity(String studentId, String opportunityId);
  Future<void> withdrawApplication(String applicationId);
  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status);
  Future<void> updateApplicationWithInterview({
    required String applicationId,
    required ApplicationStatus status,
    DateTime? interviewDate,
    String? interviewTime,
    String? interviewLocation,
    String? meetingLink,
    String? interviewNotes,
  });
}
