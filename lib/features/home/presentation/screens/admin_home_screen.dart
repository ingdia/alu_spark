import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildQuickStats(),
              const SizedBox(height: 32),
              _buildSectionHeader('Quick Actions'),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 32),
              _buildSectionHeader('Pending Verifications'),
              const SizedBox(height: 16),
              _buildPendingVerifications(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Overview',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Admin Dashboard',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to admin settings or notifications
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderGlass),
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: AppColors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Total Students', '1,245', Icons.school_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Total Startups', '84', Icons.business_outlined),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Pending Verifications', '7', Icons.verified_user_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Active Opps', '156', Icons.work_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
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
            count,
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.white,
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to see all
          },
          child: Text(
            'See All',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkRed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton('Verify Startups', Icons.verified_user_outlined, () {}),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton('Manage Users', Icons.people_outline, () {}),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton('Analytics', Icons.analytics_outlined, () {}),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton('Reports', Icons.report_outlined, () {}),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.white, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingVerifications() {
    // Using final instead of const because the list contains AppColors values
    final verifications = [
      {'name': 'EcoTech Solutions', 'founder': 'John Doe', 'date': '2 days ago', 'color': AppColors.darkRed},
      {'name': 'FinFlow', 'founder': 'Jane Smith', 'date': '5 days ago', 'color': AppColors.lightGray},
      {'name': 'HealthPlus', 'founder': 'Alice Brown', 'date': '1 week ago', 'color': AppColors.darkRedLight},
    ];

    return Column(
      children: verifications.map((v) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (v['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.business_outlined,
                    color: v['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v['name'] as String,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${v['founder']} • ${v['date']}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (v['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pending',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: v['color'] as Color,
                      fontSize: 12,
                    ),
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