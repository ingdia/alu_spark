import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class ApplicationTrackingScreen extends ConsumerWidget {
  const ApplicationTrackingScreen({super.key});

  static const _statusColors = {
    'Interview': Color(0xFF6366F1),
    'Pending': Color(0xFFF59E0B),
    'Accepted': Color(0xFF22C55E),
    'Rejected': Color(0xFF64748B),
  };

  static const _statusIcons = {
    'Interview': Icons.people_rounded,
    'Pending': Icons.hourglass_top_rounded,
    'Accepted': Icons.check_circle_rounded,
    'Rejected': Icons.cancel_rounded,
  };

  static final List<Map<String, dynamic>> _applications = [
    {
      'title': 'Frontend Developer',
      'startup': 'TechStart',
      'date': 'Jul 10, 2026',
      'status': 'Interview',
      'avatar': 'assets/images/avatar_1.jpg',
    },
    {
      'title': 'UI/UX Designer',
      'startup': 'DesignHub',
      'date': 'Jul 05, 2026',
      'status': 'Pending',
      'avatar': 'assets/images/avatar_2.jpg',
    },
    {
      'title': 'Marketing Intern',
      'startup': 'GrowthLab',
      'date': 'Jun 28, 2026',
      'status': 'Accepted',
      'avatar': 'assets/images/avatar_3.jpg',
    },
    {
      'title': 'Data Analyst',
      'startup': 'FinFlow',
      'date': 'Jun 15, 2026',
      'status': 'Rejected',
      'avatar': 'assets/images/avatar_4.jpg',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: _Orb(
              size: MediaQuery.of(context).size.width * 0.6,
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -40,
            child: _Orb(
              size: MediaQuery.of(context).size.width * 0.5,
              color: AppColors.darkRed.withValues(alpha: 0.08),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildProgressBanner(),
                        const SizedBox(height: 24),
                        _buildStatsRow(),
                        const SizedBox(height: 28),
                        _buildSectionTitle('All Applications'),
                        const SizedBox(height: 12),
                        ..._applications.map(_buildApplicationCard),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GlassmorphicContainer(
            blur: 12,
            borderRadius: 12,
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.white, size: 16),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Applications',
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 19,
                    letterSpacing: -0.4,
                    height: 1.2,
                  ),
                ),
                Text(
                  'Track your journey',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          GlassmorphicContainer(
            blur: 12,
            borderRadius: 12,
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.filter_list_rounded,
                color: AppColors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9A031E), Color(0xFF1C2541)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkRed.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep going! 🚀',
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 17,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "You're 1 step away from landing your dream role.",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.white),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '65% profile strength',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 11,
                    color: AppColors.white.withValues(alpha: 0.7),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/avatar_alex.jpg',
              width: 68,
              height: 68,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'label': 'Total', 'value': '4', 'icon': Icons.list_alt_rounded, 'color': const Color(0xFF6366F1)},
      {'label': 'Pending', 'value': '1', 'icon': Icons.hourglass_top_rounded, 'color': const Color(0xFFF59E0B)},
      {'label': 'Interview', 'value': '1', 'icon': Icons.people_rounded, 'color': const Color(0xFF6366F1)},
      {'label': 'Accepted', 'value': '1', 'icon': Icons.check_circle_rounded, 'color': const Color(0xFF22C55E)},
    ];

    return Row(
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
                      fontSize: 18,
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headingMedium.copyWith(
        fontSize: 17,
        letterSpacing: -0.3,
        height: 1.2,
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app) {
    final status = app['status'] as String;
    final color = _statusColors[status] ?? AppColors.textSecondary;
    final icon = _statusIcons[status] ?? Icons.circle;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        blur: 12,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      app['avatar'] as String,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app['title'] as String,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        app['startup'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: color, size: 11),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.borderGlass),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: AppColors.textSecondary, size: 12),
                    const SizedBox(width: 5),
                    Text(
                      'Applied ${app['date']}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'View Details',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkRed,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: AppColors.darkRed, size: 10),
                    ],
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

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
