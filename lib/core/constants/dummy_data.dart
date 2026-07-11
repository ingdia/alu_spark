import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class DummyData {
  DummyData._();

  static const List<String> categories = [
    'All', 'Software Dev', 'Design', 'Marketing', 'Research', 'Operations'
  ];

  static final List<Map<String, dynamic>> featuredOpportunities = [
    {
      'title': 'Frontend Developer Intern',
      'startup': 'FinTech ALU',
      'location': 'Kigali, Remote',
      'type': 'Part-time',
      'logo': Icons.account_balance_wallet,
      'color': AppColors.darkRed,
    },
    {
      'title': 'UI/UX Design Lead',
      'startup': 'AgriConnect',
      'location': 'Nairobi',
      'type': 'Full-time',
      'logo': Icons.eco,
      'color': AppColors.darkBlue,
    },
  ];

  static const List<Map<String, dynamic>> recentOpportunities = [
    {
      'title': 'Marketing Strategist',
      'startup': 'EduSpark',
      'location': 'Remote',
      'type': 'Internship',
      'logo': Icons.campaign,
      'postedDays': 2,
    },
    {
      'title': 'Data Analyst',
      'startup': 'HealthTech Rwanda',
      'location': 'Kigali',
      'type': 'Contract',
      'logo': Icons.analytics,
      'postedDays': 5,
    },
    {
      'title': 'Community Manager',
      'startup': 'CampusLife',
      'location': 'On-site',
      'type': 'Volunteer',
      'logo': Icons.groups,
      'postedDays': 1,
    },
  ];
}