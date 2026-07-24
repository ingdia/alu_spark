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
          onRetry: () => ref.invalidate(platformStatsProvider),
        ),
        data: (stats) => _buildContent(stats),
      ),
    );
  }

  Widget _buildContent(PlatformStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryStats(stats),
          const SizedBox(height: 32),
          Text('Applications by Status',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
          const SizedBox(height: 12),
          _buildBreakdown(stats.applicationsByStatus, _statusColor),
          const SizedBox(height: 32),
          Text('Opportunities by Category',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
          const SizedBox(height: 12),
          _buildBreakdown(stats.opportunitiesByCategory, (_) => AppColors.darkRed),
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
              color: AppColors.darkRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.darkRed, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildBreakdown(Map<String, int> data, Color Function(String) colorFn) {
    if (data.isEmpty) {
      return GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text('No data yet.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ),
      );
    }

    final total = data.values.fold(0, (a, b) => a + b);
    final sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: sorted.map((entry) {
          final pct = total > 0 ? entry.value / total : 0.0;
          final color = colorFn(entry.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatLabel(entry.key),
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
                    Text('${entry.value}  ${(pct * 100).toStringAsFixed(0)}%',
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

  String _formatLabel(String raw) {
    switch (raw) {
      case 'underReview': return 'Under Review';
      default:
        return raw.isEmpty ? 'Unknown' : raw[0].toUpperCase() + raw.substring(1);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'applied': return const Color(0xFF60A5FA);
      case 'underReview': return const Color(0xFFFBBF24);
      case 'interview': return AppColors.darkRedLight;
      case 'accepted': return const Color(0xFF34D399);
      case 'rejected':
      case 'withdrawn': return AppColors.textSecondary;
      default: return AppColors.darkRed;
    }
  }
}
