import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dummy data
    const String name = 'Alex Johnson';
    const String university = 'African Leadership University';
    const String major = 'Software Engineering';
    const String bio = 'Passionate software engineering student with a keen interest in mobile development and UI/UX design. Always eager to learn new technologies and contribute to impactful projects.';
    
    final List<String> skills = ['Flutter', 'Dart', 'Python', 'UI/UX Design', 'Firebase', 'Git'];
    
    final List<Map<String, String>> education = [
      {'degree': 'BSc in Software Engineering', 'institution': 'African Leadership University', 'period': '2023 - 2027'},
    ];
    
    final List<Map<String, String>> experience = [
      {'role': 'UI/UX Design Intern', 'company': 'TechStart', 'period': 'Jun 2025 - Present'},
      {'role': 'Frontend Developer', 'company': 'DesignHub', 'period': 'Jan 2025 - May 2025'},
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.darkBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.white),
                onPressed: () {
                  // TODO: Navigate to settings
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
                      AppColors.darkRed.withOpacity(0.4),
                      AppColors.darkBlue,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: AppColors.glassWhite,
                        child: const Icon(Icons.person, size: 45, color: AppColors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$major • $university',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white.withOpacity(0.8)),
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
                  _buildSectionTitle('About Me'),
                  const SizedBox(height: 12),
                  _buildAboutSection(bio),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Skills'),
                  const SizedBox(height: 12),
                  _buildSkillsSection(skills),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Education'),
                  const SizedBox(height: 12),
                  _buildEducationSection(education),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Experience'),
                  const SizedBox(height: 12),
                  _buildExperienceSection(experience),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to edit profile
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
        _buildStatItem('GPA', '3.8'),
        const SizedBox(width: 12),
        _buildStatItem('Projects', '12'),
        const SizedBox(width: 12),
        _buildStatItem('Skills', '6'),
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

  Widget _buildAboutSection(String bio) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Text(
        bio,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSkillsSection(List<String> skills) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGlass),
          ),
          child: Text(
            skill,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEducationSection(List<Map<String, String>> education) {
    return Column(
      children: education.map((edu) {
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
                    color: AppColors.darkRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school_outlined, color: AppColors.darkRed, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        edu['degree']!,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        edu['institution']!,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        edu['period']!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
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

  Widget _buildExperienceSection(List<Map<String, String>> experience) {
    return Column(
      children: experience.map((exp) {
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
                    color: AppColors.darkRed.withOpacity(0.2),
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
                        exp['role']!,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exp['company']!,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exp['period']!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
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