import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/utils/responsive_utils.dart';
import 'package:alu_spark/features/opportunities/presentation/providers/opportunity_provider.dart';
import 'package:alu_spark/features/applications/presentation/providers/application_provider.dart';
import 'package:alu_spark/features/opportunities/presentation/widgets/opportunity_card.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunities = ref.watch(opportunityProvider);
    final applications = ref.watch(applicationProvider).studentApplications;
    final horizontalPadding = ResponsiveUtils.getResponsivePadding(context);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.getMaxContentWidth(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildQuickStats(context, applications.length),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Recommended for You'),
                  const SizedBox(height: 16),
                  _buildRecommendedOpportunities(context, opportunities.featured),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Your Applications'),
                  const SizedBox(height: 16),
                  _buildApplicationStatus(context, applications),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, Alex 👋',
                style: AppTextStyles.headingMedium.copyWith(
                  color: AppColors.white,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find your next opportunity',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                ),
              ),
            ],
          ),
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

  Widget _buildQuickStats(BuildContext context, int appliedCount) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, 8);
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: _StatCard(title: 'Applied', count: '$appliedCount', icon: Icons.send_outlined),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: const _StatCard(title: 'Bookmarks', count: '12', icon: Icons.bookmark_border),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: const _StatCard(title: 'Interviews', count: '2', icon: Icons.calendar_today_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.white,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text('See All',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkRed)),
        ),
      ],
    );
  }

  Widget _buildRecommendedOpportunities(
      BuildContext context, List<Map<String, dynamic>> featured) {
    final cardWidth = ResponsiveUtils.isMobile(context)
        ? MediaQuery.of(context).size.width * 0.75
        : 320.0;

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final o = featured[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: cardWidth,
              child: OpportunityCard(
                title: o['title'],
                startup: o['startup'],
                location: o['location'],
                type: o['type'],
                logo: o['logo'],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplicationStatus(
      BuildContext context, List<StudentApplication> applications) {
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
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: app.statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.white,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(app.startup,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: app.statusColor.withOpacity(0.2),
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
    return GlassmorphicContainer(
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
    );
  }
}
