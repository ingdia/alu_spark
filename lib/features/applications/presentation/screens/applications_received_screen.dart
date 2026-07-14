import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/features/applications/presentation/providers/application_provider.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

class ApplicationsReceivedScreen extends ConsumerWidget {
  const ApplicationsReceivedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.value;

    if (currentUser == null) return const LoadingWidget(message: 'Loading...');

    final applicationsAsync =
        ref.watch(applicationsByStartupProvider(currentUser.id));

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(context),
      body: applicationsAsync.when(
        loading: () => const LoadingWidget(message: 'Fetching applications...'),
        error: (error, _) => ErrorStateWidget(
          message: 'Failed to load applications.',
          onRetry: () =>
              ref.invalidate(applicationsByStartupProvider(currentUser.id)),
        ),
        data: (applications) => _buildContent(context, applications),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 12,
          padding: EdgeInsets.zero,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: Text(
        'Received Applications',
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
      ),
      centerTitle: true,
    );
  }

  Widget _buildContent(BuildContext context, List<Application> applications) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryStats(applications),
          const SizedBox(height: 24),
          Text('All Applications',
              style:
                  AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
          const SizedBox(height: 16),
          applications.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.inbox_outlined,
                  title: 'No Applications Yet',
                  description:
                      'When students apply to your opportunities, they will appear here.',
                )
              : Column(
                  children: applications
                      .map((app) => _buildApplicationCard(context, app))
                      .toList(),
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(List<Application> applications) {
    final total = applications.length;
    final pending = applications
        .where((a) =>
            a.status == ApplicationStatus.pending ||
            a.status == ApplicationStatus.reviewing)
        .length;
    final shortlisted =
        applications.where((a) => a.status == ApplicationStatus.interview).length;
    final rejected =
        applications.where((a) => a.status == ApplicationStatus.rejected).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(label: 'Total', value: '$total', icon: Icons.list_alt)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Pending', value: '$pending', icon: Icons.fiber_new)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(label: 'Interview', value: '$shortlisted', icon: Icons.star_outline)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(label: 'Rejected', value: '$rejected', icon: Icons.cancel_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _buildApplicationCard(BuildContext context, Application app) {
    final statusColor = _statusColor(app.status);
    final formattedDate =
        '${app.createdAt.day}/${app.createdAt.month}/${app.createdAt.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.2),
                  child: Text(
                    app.studentName.isNotEmpty ? app.studentName[0] : '?',
                    style: AppTextStyles.bodyLarge.copyWith(color: statusColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.studentName,
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.white)),
                      const SizedBox(height: 4),
                      Text('Applied for ${app.opportunityTitle}',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    app.status.displayName,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: statusColor, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderGlass, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.email_outlined,
                    color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    app.studentEmail,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formattedDate,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _updateStatus(context, app.id, ApplicationStatus.rejected),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderGlass),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text('Reject',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _updateStatus(context, app.id, ApplicationStatus.interview),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkRed,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text('Shortlist',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(
      BuildContext context, String applicationId, ApplicationStatus status) async {
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .update({'status': status.name});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application ${status.displayName}'),
            backgroundColor: status == ApplicationStatus.interview
                ? AppColors.darkRed
                : Colors.grey[700],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
      case ApplicationStatus.reviewing:
        return AppColors.textSecondary;
      case ApplicationStatus.interview:
        return AppColors.darkRedLight;
      case ApplicationStatus.accepted:
        return AppColors.darkRed;
      case ApplicationStatus.rejected:
        return AppColors.textSecondary.withValues(alpha: 0.5);
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.darkRed, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style:
                  AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
