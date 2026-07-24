import 'package:flutter/material.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

class FormatUtils {
  FormatUtils._();

  static const _months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// "15 Jan 2026"
  static String formatDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month]} ${dt.year}';

  /// "15/1/2026"
  static String formatShortDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  /// "now", "5m", "14:30", "Mon", "3/1"
  static String formatChatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dt.weekday - 1];
    }
    return '${dt.day}/${dt.month}';
  }

  /// "5m ago", "3h ago", "2d ago"
  static String formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// Canonical status color used across all application status displays.
  static Color applicationStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return const Color(0xFF60A5FA);
      case ApplicationStatus.underReview:
        return const Color(0xFFFBBF24);
      case ApplicationStatus.interview:
        return AppColors.darkRedLight;
      case ApplicationStatus.accepted:
        return const Color(0xFF34D399);
      case ApplicationStatus.rejected:
      case ApplicationStatus.withdrawn:
        return AppColors.textSecondary;
    }
  }
}
