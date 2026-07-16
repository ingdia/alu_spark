import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/alu_logo.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/features/applications/presentation/providers/application_provider.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/features/opportunities/presentation/providers/opportunity_provider.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

class FounderHomeScreen extends ConsumerWidget {
  const FounderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.value;

    if (currentUser == null) return const LoadingWidget(message: 'Loading...');

    final startupId = currentUser.id;
    final applicationsAsync = ref.watch(applicationsByStartupProvider(startupId));
    final opportunitiesAsync = ref.watch(opportunitiesByStartupProvider(startupId));

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              applicationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.darkRed)),
                error: (e, _) => Text('$e', style: const TextStyle(color: Colors.red)),
                data: (applications) => opportunitiesAsync.when(
                  loading: () => const SizedBox.shrink(),
                error: (_, e) => const SizedBox.shrink(),
                  data: (opportunities) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickStats(applications, opportunities.length),
                      const SizedBox(height: 32),
                      _buildSectionHeader(context, 'Quick Actions', null),
                      const SizedBox(height: 16),
                      _buildQuickActions(context),
                      const SizedBox(height: 32),
                      _buildSectionHeader(context, 'Recent Applications', RouteNames.applicationsReceived),
                      const SizedBox(height: 16),
                      _buildRecentApplications(applications),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const AluLogo(size: 40),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(RouteNames.notifications),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderGlass),
            ),
            child: const Icon(Icons.notifications_outlined, color: AppColors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(List<Application> applications, int postedCount) {
    final newCount = applications.where((a) => a.status == ApplicationStatus.applied).length;
    return Row(
      children: [
        _StatCard(title: 'Received', count: '${applications.length}', icon: Icons.people_outline),
        _StatCard(title: 'New', count: '$newCount', icon: Icons.mark_email_unread_outlined),
        _StatCard(title: 'Posted', count: '$postedCount', icon: Icons.work_outline),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String? route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
        if (route != null)
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(route),
            child: Text('See All', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkRed)),
          )
        else
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('All quick actions are already visible below.'),
                backgroundColor: AppColors.darkBlueLight,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            ),
            child: Text('See All', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _ActionButton(title: 'Post Opportunity', icon: Icons.add_circle_outline, onTap: () => Navigator.of(context).pushNamed(RouteNames.postOpportunity))),
            const SizedBox(width: 16),
            Expanded(child: _ActionButton(title: 'Manage Profile', icon: Icons.business_outlined, onTap: () => Navigator.of(context).pushNamed(RouteNames.startupProfileEdit))),
          ],
        ),
        const SizedBox(height: 16),
        _ActionButton(
          title: 'Manage Opportunities',
          icon: Icons.work_outline,
          onTap: () => Navigator.of(context).pushNamed(RouteNames.opportunityManagement),
        ),
        const SizedBox(height: 16),
        _ActionButton(
          title: 'View Analytics',
          icon: Icons.bar_chart_outlined,
          onTap: () => Navigator.of(context).pushNamed(RouteNames.founderAnalytics),
        ),
      ],
    );
  }

  Widget _buildRecentApplications(List<Application> applications) {
    if (applications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No applications yet.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ),
      );
    }
    return Column(
      children: applications.take(5).map((app) {
        final statusColor = app.status == ApplicationStatus.accepted
            ? AppColors.darkRed
            : app.status == ApplicationStatus.interview
                ? AppColors.darkRedLight
                : AppColors.textSecondary;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.glassWhite,
                  child: Text(
                    app.studentName.isNotEmpty ? app.studentName[0] : '?',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.studentName, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
                      const SizedBox(height: 4),
                      Text(app.opportunityTitle, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    app.status.displayName,
                    style: AppTextStyles.bodyMedium.copyWith(color: statusColor, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;

  const _StatCard({required this.title, required this.count, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: AppColors.darkRed, size: 28),
              const SizedBox(height: 8),
              Text(count, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
              const SizedBox(height: 4),
              Text(title,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(title,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
