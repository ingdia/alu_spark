import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/features/applications/presentation/providers/application_provider.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/features/opportunities/presentation/providers/opportunity_provider.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

class FounderAnalyticsScreen extends ConsumerWidget {
  const FounderAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(16),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text('Recruitment Analytics',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
        centerTitle: true,
      ),
      body: currentUser == null
          ? const LoadingWidget(message: 'Loading...')
          : _FounderAnalyticsBody(startupId: currentUser.id),
    );
  }
}

class _FounderAnalyticsBody extends ConsumerWidget {
  final String startupId;
  const _FounderAnalyticsBody({required this.startupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(applicationsByStartupProvider(startupId));
    final oppsAsync = ref.watch(founderOpportunitiesProvider(startupId));

    return appsAsync.when(
      loading: () => const LoadingWidget(message: 'Loading analytics...'),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(applicationsByStartupProvider(startupId)),
      ),
      data: (apps) => oppsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading analytics...'),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(founderOpportunitiesProvider(startupId)),
        ),
        data: (opps) => _buildContent(apps, opps),
      ),
    );
  }

  Widget _buildContent(List<Application> apps, List<Opportunity> opps) {
    final posted = opps.length;
    final received = apps.length;
    final interviews = apps.where((a) => a.status == ApplicationStatus.interview).length;
    final accepted = apps.where((a) => a.status == ApplicationStatus.accepted).length;
    final interviewRate = received > 0 ? (interviews / received * 100) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _StatCard(label: 'Posted', value: '$posted', icon: Icons.work_outline, color: AppColors.white),
            const SizedBox(width: 12),
            _StatCard(label: 'Received', value: '$received', icon: Icons.people_outline, color: const Color(0xFF60A5FA)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _StatCard(label: 'Interviews', value: '$interviews', icon: Icons.event_outlined, color: AppColors.darkRedLight),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Interview Rate',
              value: '${interviewRate.toStringAsFixed(0)}%',
              icon: Icons.trending_up,
              color: const Color(0xFF34D399),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _StatCard(label: 'Accepted', value: '$accepted', icon: Icons.check_circle_outline, color: const Color(0xFF34D399)),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Acceptance Rate',
              value: received > 0 ? '${(accepted / received * 100).toStringAsFixed(0)}%' : '0%',
              icon: Icons.star_outline,
              color: const Color(0xFFFBBF24),
            ),
          ]),
          const SizedBox(height: 32),
          Text('Applications by Status',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
          const SizedBox(height: 12),
          _buildStatusBreakdown(apps),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown(List<Application> apps) {
    if (apps.isEmpty) {
      return GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text('No applications yet.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ),
      );
    }

    final statuses = [
      ApplicationStatus.applied,
      ApplicationStatus.underReview,
      ApplicationStatus.interview,
      ApplicationStatus.accepted,
      ApplicationStatus.rejected,
      ApplicationStatus.withdrawn,
    ];
    final total = apps.length;

    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: statuses.map((s) {
          final count = apps.where((a) => a.status == s).length;
          final pct = total > 0 ? count / total : 0.0;
          final color = _statusColor(s);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.displayName,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
                    Text('$count  ${(pct * 100).toStringAsFixed(0)}%',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppColors.glassWhite,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _statusColor(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.applied: return const Color(0xFF60A5FA);
      case ApplicationStatus.underReview: return const Color(0xFFFBBF24);
      case ApplicationStatus.interview: return AppColors.darkRedLight;
      case ApplicationStatus.accepted: return const Color(0xFF34D399);
      case ApplicationStatus.rejected:
      case ApplicationStatus.withdrawn: return AppColors.textSecondary;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
