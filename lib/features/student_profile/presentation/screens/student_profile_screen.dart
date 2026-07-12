import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  static const _name = 'Alex Johnson';
  static const _university = 'African Leadership University';
  static const _major = 'Software Engineering';
  static const _bio =
      'Passionate software engineering student with a keen interest in mobile development and UI/UX design. Always eager to learn new technologies and contribute to impactful projects.';
  static const _avatarUrl = 'assets/images/avatar_alex.jpg';
  static const _coverUrl = 'assets/images/profile_cover.jpg';

  static const List<String> _skills = [
    'Flutter', 'Dart', 'Python', 'UI/UX', 'Firebase', 'Git', 'React', 'Figma'
  ];

  static const List<Map<String, String>> _education = [
    {
      'degree': 'BSc Software Engineering',
      'institution': 'African Leadership University',
      'period': '2023 – 2027'
    },
  ];

  static const List<Map<String, String>> _experience = [
    {'role': 'UI/UX Design Intern', 'company': 'TechStart', 'period': 'Jun 2025 – Present'},
    {'role': 'Frontend Developer', 'company': 'DesignHub', 'period': 'Jan 2025 – May 2025'},
  ];

  static const List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.bookmark_rounded, 'label': 'Saved Opportunities', 'color': Color(0xFF6366F1)},
    {'icon': Icons.notifications_rounded, 'label': 'Notifications', 'color': Color(0xFFF59E0B)},
    {'icon': Icons.bar_chart_rounded, 'label': 'My Analytics', 'color': Color(0xFF22C55E)},
    {'icon': Icons.settings_rounded, 'label': 'Settings', 'color': AppColors.textSecondary},
    {'icon': Icons.logout_rounded, 'label': 'Log Out', 'color': AppColors.darkRed},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                  _buildSkillsSection(),
                  const SizedBox(height: 24),
                  _buildTimelineSection('Education', _education, Icons.school_rounded),
                  const SizedBox(height: 24),
                  _buildTimelineSection('Experience', _experience, Icons.work_rounded),
                  const SizedBox(height: 24),
                  _buildMenuSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.darkBlue,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: GlassmorphicContainer(
          blur: 12,
          borderRadius: 12,
          padding: EdgeInsets.zero,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.white, size: 16),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: GlassmorphicContainer(
            blur: 12,
            borderRadius: 12,
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.white, size: 18),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.backgroundGradient),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.45, 1.0],
                  colors: [
                    Color(0x220B132B),
                    Color(0x770B132B),
                    Color(0xFF0B132B)
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.darkRed, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkRed.withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.darkBlueLight,
                      child: ClipOval(
                        child: Image.asset(
                          _avatarUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _name,
                              style: AppTextStyles.headingMedium.copyWith(
                                fontSize: 19,
                                height: 1.2,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.verified_rounded,
                                color: AppColors.darkRed, size: 15),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$_major • $_university',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 11,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'label': 'GPA', 'value': '3.8', 'icon': Icons.grade_rounded, 'color': const Color(0xFFF59E0B)},
      {'label': 'Projects', 'value': '12', 'icon': Icons.folder_rounded, 'color': const Color(0xFF6366F1)},
      {'label': 'Skills', 'value': '8', 'icon': Icons.bolt_rounded, 'color': AppColors.darkRed},
      {'label': 'Applied', 'value': '4', 'icon': Icons.send_rounded, 'color': const Color(0xFF22C55E)},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: stats.asMap().entries.map((e) {
          final s = e.value;
          final color = s['color'] as Color;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: e.key < stats.length - 1 ? 8 : 0),
              child: GlassmorphicContainer(
                blur: 12,
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(s['icon'] as IconData, color: color, size: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s['value'] as String,
                      style: AppTextStyles.headingMedium.copyWith(
                        fontSize: 17,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s['label'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 10,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.redGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.headingMedium.copyWith(
            fontSize: 17,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('About Me'),
        const SizedBox(height: 12),
        GlassmorphicContainer(
          blur: 12,
          borderRadius: 14,
          padding: const EdgeInsets.all(16),
          child: Text(
            _bio,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.65, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Skills'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.redGradient,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkRed.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                skill,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(
      String title, List<Map<String, String>> items, IconData sectionIcon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == items.length - 1;
          final label = item['degree'] ?? item['role'] ?? '';
          final sub = item['institution'] ?? item['company'] ?? '';
          final period = item['period'] ?? '';

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.redGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(sectionIcon, color: AppColors.white, size: 16),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 36,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.darkRed.withValues(alpha: 0.45),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: GlassmorphicContainer(
                    blur: 10,
                    borderRadius: 12,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          sub,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.darkRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            period,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.darkRed,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Account'),
        const SizedBox(height: 12),
        GlassmorphicContainer(
          blur: 12,
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: _menuItems.asMap().entries.map((entry) {
              final item = entry.value;
              final color = item['color'] as Color;
              final isLast = entry.key == _menuItems.length - 1;

              return Column(
                children: [
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item['icon'] as IconData,
                                color: color, size: 17),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['label'] as String,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontSize: 14,
                                color: isLast
                                    ? AppColors.darkRed
                                    : AppColors.white,
                                fontWeight: isLast
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (!isLast)
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                          height: 1, color: AppColors.borderGlass),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
