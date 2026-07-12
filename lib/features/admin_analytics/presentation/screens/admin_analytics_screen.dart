import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _buildSectionTitle('Platform Growth'),
            const SizedBox(height: 12),
            _buildGrowthChart(),
            const SizedBox(height: 24),
            _buildSectionTitle('Top Categories'),
            const SizedBox(height: 12),
            _buildTopCategories(),
            const SizedBox(height: 24),
            _buildSectionTitle('Recent Activity'),
            const SizedBox(height: 12),
            _buildRecentActivity(),
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
        'Platform Analytics',
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
            Expanded(child: _buildStatCard('Students', '1,245', Icons.school_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Founders', '84', Icons.business_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Opportunities', '156', Icons.work_outline)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Applications', '3,420', Icons.send_outlined)),
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

  Widget _buildGrowthChart() {
    // Dummy data for chart
    final List<double> chartData = [0.3, 0.5, 0.4, 0.7, 0.6, 0.9];
    final List<String> months = ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    const double maxHeight = 100.0;

    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Registrations',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Last 6 months',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary, 
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: maxHeight + 30, // 100 for bars + 30 for labels
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: double.infinity,
                          height: maxHeight * value,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.darkRed,
                                AppColors.darkRed.withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          months[index],
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategories() {
    // Using final because the list contains AppColors values
    final List<Map<String, dynamic>> categories = [
      {'name': 'Technology', 'percentage': 45, 'color': AppColors.darkRed},
      {'name': 'Design', 'percentage': 25, 'color': AppColors.darkRedLight},
      {'name': 'Marketing', 'percentage': 15, 'color': AppColors.lightGray},
      {'name': 'Business', 'percentage': 10, 'color': AppColors.textSecondary},
      {'name': 'Finance', 'percentage': 5, 'color': AppColors.borderGlass},
    ];

    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cat['name'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                    ),
                    Text(
                      '${cat['percentage']}%',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (cat['percentage'] as int) / 100.0,
                    backgroundColor: AppColors.glassWhite,
                    valueColor: AlwaysStoppedAnimation<Color>(cat['color'] as Color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentActivity() {
    // Using final because the list contains AppColors values
    final List<Map<String, dynamic>> activities = [
      {'icon': Icons.send_outlined, 'text': 'Alex Johnson applied to Frontend Developer', 'time': '2m ago'},
      {'icon': Icons.verified_outlined, 'text': 'EcoTech Solutions was verified', 'time': '1h ago'},
      {'icon': Icons.add_circle_outline, 'text': 'New opportunity posted at DesignHub', 'time': '3h ago'},
      {'icon': Icons.person_add_outlined, 'text': 'Sarah Lee joined as a Student', 'time': '5h ago'},
    ];

    return Column(
      children: activities.map((act) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 16,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.darkRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(act['icon'] as IconData, color: AppColors.darkRed, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    act['text'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                  ),
                ),
                Text(
                  act['time'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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