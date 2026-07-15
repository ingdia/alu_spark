import 'package:alu_spark/features/applications/domain/entities/application.dart';

abstract class ApplicationRepository {
  Future<void> submitApplication(Application application);
  Stream<List<Application>> getApplicationsByStudent(String studentId);
  Stream<List<Application>> getApplicationsByStartup(String startupId);
  Future<bool> hasApplied(String studentId, String opportunityId);
}
