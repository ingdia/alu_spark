import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/constants/dummy_data.dart';
import 'package:alu_spark/core/utils/responsive_utils.dart';
import 'package:alu_spark/features/opportunities/presentation/widgets/opportunity_card.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  _buildQuickStats(context),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Recommended for You'),
                  const SizedBox(height: 16),
                  _buildRecommendedOpportunities(context),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Your Applications'),
                  const SizedBox(height: 16),
                  _buildApplicationStatus(context),
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
    final titleSize = ResponsiveUtils.getResponsiveFontSize(context, 24);
    
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
                  fontSize: titleSize,
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
        GestureDetector(
          onTap: () {
            // TODO: Navigate to notifications
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderGlass),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, 8);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: _buildStatCard('Applied', '5', Icons.send_outlined),
          ),
        ),
        if (isMobile) ...[
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: _buildStatCard('Bookmarks', '12', Icons.bookmark_border),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: _buildStatCard('Interviews', '2', Icons.calendar_today_outlined),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: AppColors.darkRed, size: 28),
          const SizedBox(height: 8),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
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

  Widget _buildRecommendedOpportunities(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: DummyData.featuredOpportunities.length,
        itemBuilder: (context, index) {
          final o = DummyData.featuredOpportunities[index];
          final cardWidth = ResponsiveUtils.isMobile(context) 
              ? MediaQuery.of(context).size.width * 0.75
              : 320.0;
              
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

  Widget _buildApplicationStatus(BuildContext context) {
    final applications = [
      {'title': 'UI/UX Designer', 'startup': 'DesignHub', 'status': 'Interview', 'color': AppColors.darkRed},
      {'title': 'Frontend Developer', 'startup': 'TechStart', 'status': 'Pending', 'color': AppColors.lightGray},
      {'title': 'Marketing Intern', 'startup': 'GrowthLab', 'status': 'Accepted', 'color': AppColors.darkRedLight},
    ];
    
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
                    color: app['color'] as Color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app['title'] as String,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.white,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app['startup'] as String,
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
                    color: (app['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    app['status'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: app['color'] as Color,
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