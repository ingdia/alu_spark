import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/features/admin_analytics/presentation/providers/analytics_provider.dart';
import 'package:alu_spark/features/admin_analytics/domain/entities/platform_stats.dart';

class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(platformStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
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
          'Platform Analytics',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: statsAsync.when(
        loading: () => const LoadingWidget(message: 'Calculating platform metrics...'),
        error: (error, _) => ErrorStateWidget(
          message: error.toString(),
          description: 'Failed to load analytics.',
          onRetry: () => ref.invalidate(platformStatsProvider),
        ),
        data: (stats) => _buildContent(context, stats),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PlatformStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryStats(stats),
          const SizedBox(height: 32),
          _buildSectionTitle('Platform Growth'),
          const SizedBox(height: 12),
          _buildGrowthChartPlaceholder(),
          const SizedBox(height: 32),
          _buildSectionTitle('Top Categories'),
          const SizedBox(height: 12),
          _buildTopCategoriesPlaceholder(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(PlatformStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Students', '${stats.totalStudents}', Icons.school_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Founders', '${stats.totalFounders}', Icons.business_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Opportunities', '${stats.totalOpportunities}', Icons.work_outline)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Applications', '${stats.totalApplications}', Icons.send_outlined)),
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

  Widget _buildGrowthChartPlaceholder() {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.bar_chart, color: AppColors.textSecondary, size: 48),
          const SizedBox(height: 12),
          Text(
            'Growth chart visualization coming soon',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoriesPlaceholder() {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.category, color: AppColors.textSecondary, size: 48),
          const SizedBox(height: 12),
          Text(
            'Category breakdown coming soon',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
