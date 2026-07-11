import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/app/router/app_router.dart';

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
              _buildPlatformStats(),
              const SizedBox(height: 32),
              _buildSectionHeader('Admin Actions'),
              const SizedBox(height: 16),
              _buildAdminActions(context),
              const SizedBox(height: 32),
              _buildSectionHeader('Recent Activity'),
              const SizedBox(height: 16),
              _buildRecentActivity(),
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
            Text('Admin Panel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('ALU Spark', style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderGlass),
          ),
          child: const Icon(Icons.notifications_outlined, color: AppColors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildPlatformStats() {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard('Students', '1,245', Icons.school_outlined),
            _buildStatCard('Founders', '84', Icons.rocket_launch_outlined),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard('Opportunities', '156', Icons.work_outline),
            _buildStatCard('Pending', '7', Icons.hourglass_empty_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
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
                  color: AppColors.darkRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.darkRed, size: 20),
              ),
              const SizedBox(height: 12),
              Text(count, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
              const SizedBox(height: 4),
              Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white));
  }

  Widget _buildAdminActions(BuildContext context) {
    final actions = [
      {'label': 'Verify Startups', 'icon': Icons.verified_outlined, 'route': RouteNames.adminVerification},
      {'label': 'Manage Users', 'icon': Icons.people_outline, 'route': RouteNames.adminUserManagement},
      {'label': 'Analytics', 'icon': Icons.bar_chart_outlined, 'route': RouteNames.adminAnalytics},
      {'label': 'Notifications', 'icon': Icons.notifications_outlined, 'route': RouteNames.notifications},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, action['route'] as String),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(action['icon'] as IconData, color: AppColors.darkRed, size: 28),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    action['label'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'icon': Icons.verified_outlined, 'text': 'EcoTech Solutions submitted for verification', 'time': '2m ago'},
      {'icon': Icons.person_add_outlined, 'text': 'Sarah Lee joined as a Student', 'time': '1h ago'},
      {'icon': Icons.add_circle_outline, 'text': 'New opportunity posted at DesignHub', 'time': '3h ago'},
      {'icon': Icons.cancel_outlined, 'text': 'EduConnect verification rejected', 'time': '5h ago'},
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
                    color: AppColors.darkRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(act['icon'] as IconData, color: AppColors.darkRed, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(act['text'] as String, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
                ),
                Text(act['time'] as String, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
