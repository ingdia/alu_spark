import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/features/applications/presentation/providers/application_provider.dart';
import 'package:alu_spark/core/widgets/alu_logo.dart';

class FounderHomeScreen extends ConsumerWidget {
  const FounderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(applicationProvider).receivedApplications;

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
              _buildQuickStats(applications),
              const SizedBox(height: 32),
              _buildSectionHeader('Quick Actions'),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 32),
              _buildSectionHeader('Recent Applications'),
              const SizedBox(height: 16),
              _buildRecentApplications(applications),
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
        const AluLogo(size: 40),
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

  Widget _buildQuickStats(List<ReceivedApplication> applications) {
    final newCount = applications.where((a) => a.status == 'New').length;
    return Row(
      children: [
        _StatCard(title: 'Posted', count: '4', icon: Icons.work_outline),
        _StatCard(title: 'Received', count: '${applications.length}', icon: Icons.people_outline),
        _StatCard(title: 'New', count: '$newCount', icon: Icons.mark_email_unread_outlined),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
        TextButton(
          onPressed: () {},
          child: Text('See All',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkRed)),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _ActionButton(title: 'Post Opportunity', icon: Icons.add_circle_outline, onTap: () {})),
        const SizedBox(width: 16),
        Expanded(child: _ActionButton(title: 'Manage Profile', icon: Icons.business_outlined, onTap: () {})),
      ],
    );
  }

  Widget _buildRecentApplications(List<ReceivedApplication> applications) {
    return Column(
      children: applications.map((app) {
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
                    app.applicantName[0],
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.applicantName,
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
                      const SizedBox(height: 4),
                      Text(app.role,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: app.statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    app.status,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: app.statusColor,
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
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary, fontSize: 12),
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
