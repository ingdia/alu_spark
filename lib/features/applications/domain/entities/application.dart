import 'package:alu_spark/shared/enums/application_status.dart';

class Application {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String motivation;
  final String cvUrl;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Interview scheduling — populated when status == interview.
  final DateTime? interviewDate;
  final String? interviewTime;
  final String? interviewLocation;
  final String? meetingLink;
  final String? interviewNotes;

  Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.motivation,
    required this.cvUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.interviewDate,
    this.interviewTime,
    this.interviewLocation,
    this.meetingLink,
    this.interviewNotes,
  });
}
