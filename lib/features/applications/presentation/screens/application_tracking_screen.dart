import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class ApplicationTrackingScreen extends ConsumerWidget {
  const ApplicationTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using final instead of const because the list contains AppColors values
    final List<Map<String, dynamic>> applications = [
      {
        'title': 'Frontend Developer',
        'startup': 'TechStart',
        'date': 'Jul 10, 2026',
        'status': 'Interview',
        'color': AppColors.darkRed,
      },
      {
        'title': 'UI/UX Designer',
        'startup': 'DesignHub',
        'date': 'Jul 05, 2026',
        'status': 'Pending',
        'color': AppColors.lightGray,
      },
      {
        'title': 'Marketing Intern',
        'startup': 'GrowthLab',
        'date': 'Jun 28, 2026',
        'status': 'Accepted',
        'color': AppColors.darkRedLight,
      },
      {
        'title': 'Data Analyst',
        'startup': 'FinFlow',
        'date': 'Jun 15, 2026',
        'status': 'Rejected',
        'color': AppColors.textSecondary,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryStats(),
            const SizedBox(height: 24),
            _buildSectionTitle('All Applications'),
            const SizedBox(height: 16),
            _buildApplicationsList(applications),
            const SizedBox(height: 20),
          ],
        ),
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

  Widget _buildSummaryStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Total', '4', Icons.list_alt)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Pending', '1', Icons.hourglass_empty)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Interview', '1', Icons.people)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Accepted', '1', Icons.check_circle)),
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

  Widget _buildApplicationsList(List<Map<String, dynamic>> applications) {
    return Column(
      children: applications.map((app) => _buildApplicationCard(app)).toList(),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app) {
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
                    color: (app['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.work_outline, color: app['color'] as Color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app['title'] as String,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app['startup'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (app['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    app['status'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: app['color'] as Color,
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
                      'Applied on ${app['date']}',
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
}