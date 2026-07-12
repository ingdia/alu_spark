import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class StartupProfileScreen extends ConsumerWidget {
  const StartupProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dummy data
    const String startupName = 'TechStart';
    const String tagline = 'Empowering students through technology';
    const String industry = 'EdTech';
    const String description = 'TechStart is a student-led startup focused on building innovative educational tools. We aim to bridge the gap between academic learning and industry requirements by providing real-world project experience and mentorship.';
    
    final List<Map<String, String>> teamMembers = [
      {'name': 'John Doe', 'role': 'CEO & Founder'},
      {'name': 'Jane Smith', 'role': 'CTO'},
      {'name': 'Alice Brown', 'role': 'Lead Designer'},
    ];

    final List<Map<String, String>> openRoles = [
      {'title': 'Frontend Developer', 'type': 'Internship'},
      {'title': 'Marketing Specialist', 'type': 'Part-time'},
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.darkBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.white),
                onPressed: () {
                  // TODO: Share startup profile
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.darkBlueLight,
                      AppColors.darkBlue,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.glassWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderGlass),
                        ),
                        child: const Icon(Icons.business, size: 45, color: AppColors.darkRed),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        startupName,
                        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tagline,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.darkRed.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.darkRed),
                        ),
                        child: Text(
                          industry,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkRed),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('About Us'),
                  const SizedBox(height: 12),
                  _buildAboutSection(description),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Open Opportunities'),
                  const SizedBox(height: 12),
                  _buildOpenRoles(openRoles),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Our Team'),
                  const SizedBox(height: 12),
                  _buildTeamMembers(teamMembers),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to edit startup profile
        },
        backgroundColor: AppColors.darkRed,
        icon: const Icon(Icons.edit, color: AppColors.white),
        label: Text(
          'Edit Profile',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('Team', '12'),
        const SizedBox(width: 12),
        _buildStatItem('Founded', '2023'),
        const SizedBox(width: 12),
        _buildStatItem('Open Roles', '4'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
    );
  }

  Widget _buildAboutSection(String description) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Text(
        description,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildOpenRoles(List<Map<String, String>> roles) {
    return Column(
      children: roles.map((role) {
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
                    color: AppColors.darkRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.work_outline, color: AppColors.darkRed, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role['title']!,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role['type']!,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTeamMembers(List<Map<String, String>> members) {
    return Column(
      children: members.map((member) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 16,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.darkRed.withValues(alpha: 0.2),
                  child: Text(
                    member['name']!.substring(0, 1),
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkRed),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member['name']!,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                      ),
                      Text(
                        member['role']!,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
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