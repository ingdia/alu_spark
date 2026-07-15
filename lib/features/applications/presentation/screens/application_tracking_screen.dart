import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/applications/presentation/providers/application_provider.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

class ApplicationTrackingScreen extends ConsumerWidget {
  const ApplicationTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = fb.FirebaseAuth.instance.currentUser?.uid ?? '';
    final applicationsAsync =
        ref.watch(applicationsByStudentProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(context),
      body: applicationsAsync.when(
        loading: () =>
            const LoadingWidget(message: 'Fetching applications...'),
        error: (error, _) => ErrorStateWidget(
          message: 'Failed to load applications.',
          onRetry: () =>
              ref.invalidate(applicationsByStudentProvider(userId)),
        ),
        data: (applications) => _buildContent(context, ref, applications),
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
          padding: const EdgeInsets.all(0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: Text('My Applications',
          style:
              AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
      centerTitle: true,
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref,
      List<Application> applications) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryStats(applications),
          const SizedBox(height: 24),
          Text('All Applications',
              style: AppTextStyles.headingMedium
                  .copyWith(color: AppColors.white)),
          const SizedBox(height: 16),
          applications.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.folder_open,
                  title: 'No Applications Yet',
                  description:
                      'Start exploring opportunities and apply to your first role!',
                )
              : _buildApplicationsList(context, ref, applications),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(List<Application> applications) {
    final total = applications.length;
    final active = applications
        .where((a) =>
            a.status == ApplicationStatus.applied ||
            a.status == ApplicationStatus.underReview)
        .length;
    final interview = applications
        .where((a) => a.status == ApplicationStatus.interview)
        .length;
    final accepted = applications
        .where((a) => a.status == ApplicationStatus.accepted)
        .length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatCard('Total', '$total', Icons.list_alt)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard(
                    'Active', '$active', Icons.hourglass_empty)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'Interview', '$interview', Icons.people)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatCard(
                    'Accepted', '$accepted', Icons.check_circle)),
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
              color: AppColors.darkRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.darkRed, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: AppTextStyles.headingMedium
                  .copyWith(color: AppColors.white)),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(BuildContext context, WidgetRef ref,
      List<Application> applications) {
    return Column(
      children: applications
          .map((app) => _buildApplicationCard(context, ref, app))
          .toList(),
    );
  }

  Widget _buildApplicationCard(
      BuildContext context, WidgetRef ref, Application app) {
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.work_outline, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.opportunityTitle,
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.white)),
                      const SizedBox(height: 4),
                      Text(app.startupName,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(app.status.displayName,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: statusColor, fontSize: 12)),
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
                    const Icon(Icons.calendar_today,
                        color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 6),
                    Text('Applied $formattedDate',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                GestureDetector(
                  onTap: () =>
                      _showApplicationDetails(context, ref, app),
                  child: Text('View Details',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkRed,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApplicationDetails(
      BuildContext context, WidgetRef ref, Application app) {
    final statusColor = _statusColor(app.status);
    final formattedDate =
        '${app.createdAt.day}/${app.createdAt.month}/${app.createdAt.year}';
    final updatedDate =
        '${app.updatedAt.day}/${app.updatedAt.month}/${app.updatedAt.year}';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBlueLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderGlass,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // header: opportunity + startup + status badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.work_outline,
                        color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.opportunityTitle,
                            style: AppTextStyles.headingMedium
                                .copyWith(color: AppColors.white)),
                        const SizedBox(height: 4),
                        Text(app.startupName,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(app.status.displayName,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: statusColor, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.borderGlass, height: 1),
              const SizedBox(height: 20),
              // dates
              Row(
                children: [
                  Expanded(
                    child: _detailField(
                        'Applied On', formattedDate),
                  ),
                  Expanded(
                    child: _detailField(
                        'Last Updated', updatedDate),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // motivation
              Text('Motivation Letter',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              GlassmorphicContainer(
                blur: 10,
                borderRadius: 12,
                padding: const EdgeInsets.all(16),
                child: Text(
                  app.motivation.isNotEmpty
                      ? app.motivation
                      : 'No motivation letter provided.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.white, height: 1.5),
                ),
              ),
              // cv link
              if (app.cvUrl.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('CV / Resume',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                GlassmorphicContainer(
                  blur: 10,
                  borderRadius: 12,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file,
                          color: AppColors.darkRed, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(app.cvUrl,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.white),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Divider(color: AppColors.borderGlass, height: 1),
              const SizedBox(height: 20),
              // timeline
              Text('Status Timeline',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),
              _buildStatusTimeline(app),
              // withdraw button
              if (app.status.canWithdraw) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await ref
                          .read(applicationRepositoryProvider)
                          .withdrawApplication(app.id);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.borderGlass),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Withdraw Application',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style:
                AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
      ],
    );
  }

  Widget _buildStatusTimeline(Application app) {
    const steps = [
      ApplicationStatus.applied,
      ApplicationStatus.underReview,
      ApplicationStatus.interview,
      ApplicationStatus.accepted,
    ];

    if (app.status == ApplicationStatus.rejected) {
      return _terminalTimelineRow(
          Icons.cancel_outlined, 'Application Rejected', AppColors.textSecondary);
    }
    if (app.status == ApplicationStatus.withdrawn) {
      return _terminalTimelineRow(
          Icons.undo_outlined, 'Application Withdrawn', AppColors.textSecondary);
    }

    final currentIndex = steps.indexOf(app.status);

    // Map each completed step to the timestamp when it was reached.
    // applied → createdAt; current step → updatedAt; future steps → null.
    DateTime? timestampFor(int i) {
      if (i > currentIndex) return null;
      if (i == 0) return app.createdAt;
      if (i == currentIndex) return app.updatedAt;
      // Intermediate completed steps: we only have updatedAt for the latest,
      // so show updatedAt only on the current step and createdAt on applied.
      return null;
    }

    return Column(
      children: List.generate(steps.length, (i) {
        final isDone = i <= currentIndex;
        final isActive = i == currentIndex;
        final color = isDone ? AppColors.darkRed : AppColors.textSecondary;
        final isLast = i == steps.length - 1;
        final ts = timestampFor(i);
        final dateLabel = ts != null
            ? '${ts.day} ${_monthName(ts.month)} ${ts.year}'
            : null;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDone ? 0.2 : 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? AppColors.darkRed : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isDone ? Icons.check : Icons.radio_button_unchecked,
                    color: color,
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: dateLabel != null ? 40 : 28,
                    color: isDone && i < currentIndex
                        ? AppColors.darkRed.withValues(alpha: 0.4)
                        : AppColors.borderGlass,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    steps[i].displayName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDone ? AppColors.white : AppColors.textSecondary,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (dateLabel != null) ...[  
                    const SizedBox(height: 2),
                    Text(
                      dateLabel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  String _monthName(int month) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month];
  }

  Widget _terminalTimelineRow(
      IconData icon, String label, Color color) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 12,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: AppTextStyles.bodyMedium.copyWith(color: color)),
        ],
      ),
    );
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return AppColors.textSecondary;
      case ApplicationStatus.underReview:
        return const Color(0xFF6366F1);
      case ApplicationStatus.interview:
        return AppColors.darkRedLight;
      case ApplicationStatus.accepted:
        return const Color(0xFF22C55E);
      case ApplicationStatus.rejected:
      case ApplicationStatus.withdrawn:
        return AppColors.textSecondary;
    }
  }
}
