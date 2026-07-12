import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';

class StudentApplication {
  final String title;
  final String startup;
  final String status;
  final Color statusColor;

  const StudentApplication({
    required this.title,
    required this.startup,
    required this.status,
    required this.statusColor,
  });
}

class ReceivedApplication {
  final String applicantName;
  final String role;
  final String status;
  final Color statusColor;

  const ReceivedApplication({
    required this.applicantName,
    required this.role,
    required this.status,
    required this.statusColor,
  });
}

class ApplicationState {
  final List<StudentApplication> studentApplications;
  final List<ReceivedApplication> receivedApplications;

  const ApplicationState({
    this.studentApplications = const [],
    this.receivedApplications = const [],
  });
}

class ApplicationNotifier extends Notifier<ApplicationState> {
  @override
  ApplicationState build() {
    return const ApplicationState(
      studentApplications: [
        StudentApplication(
          title: 'UI/UX Designer',
          startup: 'DesignHub',
          status: 'Interview',
          statusColor: AppColors.darkRed,
        ),
        StudentApplication(
          title: 'Frontend Developer',
          startup: 'TechStart',
          status: 'Pending',
          statusColor: AppColors.lightGray,
        ),
        StudentApplication(
          title: 'Marketing Intern',
          startup: 'GrowthLab',
          status: 'Accepted',
          statusColor: AppColors.darkRedLight,
        ),
      ],
      receivedApplications: [
        ReceivedApplication(
          applicantName: 'Alex Johnson',
          role: 'UI/UX Designer',
          status: 'New',
          statusColor: AppColors.darkRed,
        ),
        ReceivedApplication(
          applicantName: 'Sarah Lee',
          role: 'Frontend Dev',
          status: 'Reviewing',
          statusColor: AppColors.lightGray,
        ),
        ReceivedApplication(
          applicantName: 'James Mwangi',
          role: 'Marketing Intern',
          status: 'Shortlisted',
          statusColor: AppColors.darkRedLight,
        ),
      ],
    );
  }
}

final applicationProvider =
    NotifierProvider<ApplicationNotifier, ApplicationState>(
  ApplicationNotifier.new,
);
