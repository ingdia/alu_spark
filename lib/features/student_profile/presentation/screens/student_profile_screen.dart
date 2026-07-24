import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/features/student_profile/domain/entities/student.dart';
import 'package:alu_spark/core/widgets/avatar_widget.dart';
import 'package:alu_spark/features/student_profile/presentation/providers/student_profile_provider.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  static const List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.send_rounded, 'label': 'My Applications', 'color': AppColors.darkRed},
    {'icon': Icons.bookmark_rounded, 'label': 'Saved Opportunities', 'color': Color(0xFF6366F1)},
    {'icon': Icons.notifications_rounded, 'label': 'Notifications', 'color': Color(0xFFF59E0B)},
    {'icon': Icons.bar_chart_rounded, 'label': 'My Analytics', 'color': Color(0xFF22C55E)},
    {'icon': Icons.settings_rounded, 'label': 'Settings', 'color': AppColors.textSecondary},
    {'icon': Icons.logout_rounded, 'label': 'Log Out', 'color': AppColors.darkRed},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = fb.FirebaseAuth.instance.currentUser?.uid ?? '';
    final profileAsync = ref.watch(studentProfileProvider(uid));

    return profileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.darkBlue,
        body: Center(child: CircularProgressIndicator(color: AppColors.darkRed)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.darkBlue,
        body: Center(
          child: Text('Error loading profile', style: AppTextStyles.bodyMedium),
        ),
      ),
      data: (student) {
        if (student == null) {
          return Scaffold(
            backgroundColor: AppColors.darkBlue,
            body: Center(
              child: Text('Profile not found', style: AppTextStyles.bodyMedium),
            ),
          );
        }
        return _ProfileBody(student: student, menuItems: _menuItems, onMenuTap: (ctx, r, i) => _onMenuTap(ctx, ref, i));
      },
    );
  }

  void _onMenuTap(BuildContext context, WidgetRef ref, int index) async {
    switch (index) {
      case 0:
        Navigator.of(context).pushNamed(RouteNames.applicationTracking);
        break;
      case 1:
        Navigator.of(context).pushNamed(RouteNames.bookmarks);
        break;
      case 2:
        Navigator.of(context).pushNamed(RouteNames.notifications);
        break;
      case 3:
        Navigator.of(context).pushNamed(RouteNames.analytics);
        break;
      case 4:
        Navigator.of(context).pushNamed(RouteNames.settings);
        break;
      case 5:
        await ref.read(authRepositoryProvider).signOut();
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (_) => false);
        }
        break;
    }
  }
}

class _ProfileBody extends StatelessWidget {
  final Student student;
  final List<Map<String, dynamic>> menuItems;
  final void Function(BuildContext, WidgetRef, int) onMenuTap;

  const _ProfileBody({
    required this.student,
    required this.menuItems,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  if (student.bio.isNotEmpty) ...[
                    _buildAboutSection(),
                    const SizedBox(height: 24),
                  ],
                  if (student.skills.isNotEmpty) ...[
                    _buildSkillsSection(),
                    const SizedBox(height: 24),
                  ],
                  if (student.education.isNotEmpty) ...[
                    _buildTimelineSection('Education', student.education, Icons.school_rounded),
                    const SizedBox(height: 24),
                  ],
                  if (student.experience.isNotEmpty) ...[
                    _buildTimelineSection('Experience', student.experience, Icons.work_rounded),
                    const SizedBox(height: 24),
                  ],
                  _buildMenuSection(context),
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
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 16),
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
              onPressed: () => Navigator.of(context).pushNamed(RouteNames.studentProfileEdit),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/profile_cover.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.45, 1.0],
                  colors: [Color(0x220B132B), Color(0x770B132B), Color(0xFF0B132B)],
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
                  AvatarWidget(
                    name: student.fullName,
                    imageUrl: student.profileImageUrl,
                    radius: 36,
                    borderColor: AppColors.darkRed,
                    borderWidth: 2.5,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                student.fullName,
                                style: AppTextStyles.headingMedium.copyWith(
                                  fontSize: 19,
                                  height: 1.2,
                                  letterSpacing: -0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.verified_rounded, color: AppColors.darkRed, size: 15),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${student.major} • ${student.university}',
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, height: 1.3),
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
      {'label': 'Skills', 'value': '${student.skills.length}', 'icon': Icons.bolt_rounded, 'color': AppColors.darkRed},
      {'label': 'Education', 'value': '${student.education.length}', 'icon': Icons.school_rounded, 'color': const Color(0xFF6366F1)},
      {'label': 'Experience', 'value': '${student.experience.length}', 'icon': Icons.work_rounded, 'color': const Color(0xFF22C55E)},
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
                      style: AppTextStyles.headingMedium.copyWith(fontSize: 17, height: 1.1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s['label'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 10, height: 1.2),
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
          style: AppTextStyles.headingMedium.copyWith(fontSize: 17, letterSpacing: -0.3, height: 1.2),
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
            student.bio,
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
          children: student.skills.map((skill) {
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

  Widget _buildTimelineSection(String title, List<Map<String, String>> items, IconData sectionIcon) {
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
                          colors: [AppColors.darkRed.withValues(alpha: 0.45), Colors.transparent],
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
                        Text(label, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3)),
                        const SizedBox(height: 3),
                        Text(sub, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, height: 1.3)),
                        if (period.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  Widget _buildMenuSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Account'),
          const SizedBox(height: 12),
          GlassmorphicContainer(
            blur: 12,
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: menuItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final color = item['color'] as Color;
                final isLast = index == menuItems.length - 1;

                return Column(
                  children: [
                    InkWell(
                      onTap: () => onMenuTap(context, ref, index),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(item['icon'] as IconData, color: color, size: 17),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['label'] as String,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontSize: 14,
                                  color: isLast ? AppColors.darkRed : AppColors.white,
                                  fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            if (!isLast)
                              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(height: 1, color: AppColors.borderGlass),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
