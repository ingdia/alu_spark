import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/applications/presentation/providers/application_provider.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

class ApplicationTrackingScreen extends ConsumerWidget {
  const ApplicationTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get the current logged-in user
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(),
      body: authState.when(
        loading: () => const LoadingWidget(message: 'Loading your profile...'),
        error: (error, _) => ErrorStateWidget(
          message: 'Failed to load user data.',
          onRetry: () => ref.invalidate(authStateProvider),
        ),
        data: (user) {
          if (user == null) {
            return const EmptyStateWidget(
              icon: Icons.lock_outline,
              title: 'Not Logged In',
              description: 'Please log in to track your applications.',
            );
          }

          // 2. Watch the real-time applications stream for this user
          final applicationsAsync = ref.watch(applicationsByStudentProvider(user.id));

          return applicationsAsync.when(
            loading: () => const LoadingWidget(message: 'Fetching applications...'),
            error: (error, _) => ErrorStateWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(applicationsByStudentProvider(user.id)),
            ),
            data: (applications) => _buildContent(context, ref, applications),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 12,
          padding: const EdgeInsets.all(0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: Text(
        'My Applications',
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
      ),
      centerTitle: true,
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Application> applications) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryStats(applications),
          const SizedBox(height: 24),
          _buildSectionTitle('All Applications'),
          const SizedBox(height: 16),
          applications.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.folder_open,
                  title: 'No Applications Yet',
                  description: 'Start exploring opportunities and apply to your first role!',
                )
              : _buildApplicationsList(applications),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(List<Application> applications) {
    final total = applications.length;
    final pending = applications.where((a) => a.status == ApplicationStatus.pending || a.status == ApplicationStatus.reviewing).length;
    final interview = applications.where((a) => a.status == ApplicationStatus.interview).length;
    final accepted = applications.where((a) => a.status == ApplicationStatus.accepted).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Total', '$total', Icons.list_alt)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Pending', '$pending', Icons.hourglass_empty)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Interview', '$interview', Icons.people)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Accepted', '$accepted', Icons.check_circle)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
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
              color: AppColors.darkRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.darkRed, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
    );
  }

  Widget _buildApplicationsList(List<Application> applications) {
    return Column(
      children: applications.map((app) => _buildApplicationCard(app)).toList(),
    );
  }

  Widget _buildApplicationCard(Application app) {
    final statusColor = _getStatusColor(app.status);
    final formattedDate = '${app.createdAt.day}/${app.createdAt.month}/${app.createdAt.year}';

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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.work_outline, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.opportunityTitle,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.startupName,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    app.status.displayName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: statusColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderGlass, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Applied on $formattedDate',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to application details
                  },
                  child: Text(
                    'View Details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.darkRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
      case ApplicationStatus.reviewing:
        return AppColors.textSecondary; // Gray/White
      case ApplicationStatus.interview:
        return AppColors.darkRedLight; // Lighter Red/Amber
      case ApplicationStatus.accepted:
        return AppColors.darkRed; // Primary Red (or Green if you add it to palette)
      case ApplicationStatus.rejected:
        return AppColors.textSecondary.withOpacity(0.5); // Faded
    }
  }
}