import 'package:alu_spark/shared/enums/application_status.dart';

class Application {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId; // Added
  final String startupName;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String motivation;
  final String cvUrl;
  final ApplicationStatus status;
  final DateTime createdAt;

  Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId, // Added
    required this.startupName,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.motivation,
    required this.cvUrl,
    required this.status,
    required this.createdAt,
  });
}