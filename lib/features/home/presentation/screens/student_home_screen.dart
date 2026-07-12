import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/utils/responsive_utils.dart';
import 'package:alu_spark/features/opportunities/presentation/providers/opportunity_provider.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/features/applications/presentation/providers/application_provider.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredOpportunitiesProvider);
    final recentAsync = ref.watch(recentOpportunitiesProvider);
    final applications = ref.watch(applicationProvider).studentApplications;
    final horizontalPadding = ResponsiveUtils.getResponsivePadding(context);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Stack(
        children: [
          const _GlowingBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUtils.getMaxContentWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      _buildSearchBar(context),
                      const SizedBox(height: 24),
                      _buildQuickStats(context, applications.length),
                      const SizedBox(height: 28),
                      _buildSectionHeader(context, 'Featured Opportunities'),
                      const SizedBox(height: 12),
                      _buildAsyncCards(context, featuredAsync),
                      const SizedBox(height: 24),
                      _buildSectionHeader(context, 'Recent Opportunities'),
                      const SizedBox(height: 12),
                      _buildAsyncList(context, recentAsync),
                      const SizedBox(height: 96),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkRed, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/avatar_alex.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, _) => Container(
                    color: AppColors.darkBlueLight,
                    child: const Icon(Icons.person, color: AppColors.white, size: 24),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.darkBlue, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning 👋',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Alex Johnson',
                style: AppTextStyles.headingMedium.copyWith(
                  fontSize: 19,
                  letterSpacing: -0.4,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(RouteNames.notifications),
          child: GlassmorphicContainer(
            blur: 12,
            borderRadius: 12,
            padding: const EdgeInsets.all(10),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: AppColors.white, size: 20),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.darkRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GlassmorphicContainer(
      blur: 12,
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search roles, startups...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.redGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, int appliedCount) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Applied', value: '$appliedCount', icon: Icons.send_rounded, accent: AppColors.darkRed)),
        const SizedBox(width: 10),
        const Expanded(child: _StatCard(label: 'Saved', value: '12', icon: Icons.bookmark_rounded, accent: Color(0xFF6366F1))),
        const SizedBox(width: 10),
        const Expanded(child: _StatCard(label: 'Interviews', value: '2', icon: Icons.calendar_month_rounded, accent: Color(0xFF22C55E))),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppTextStyles.headingMedium.copyWith(
            fontSize: 17,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'See all',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkRed,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAsyncCards(BuildContext context, AsyncValue<List<Opportunity>> async) {
    final cardWidth = ResponsiveUtils.isMobile(context)
        ? MediaQuery.of(context).size.width * 0.76
        : 300.0;
    return SizedBox(
      height: 208,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.darkRed)),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.red))),
        data: (list) => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: list.length,
          itemBuilder: (context, index) {
            final o = list[index];
            return Padding(
              padding: EdgeInsets.only(right: index < list.length - 1 ? 12 : 0),
              child: _FeaturedCard(
                width: cardWidth,
                title: o.title,
                startup: o.startupName,
                location: o.location,
                type: o.type,
                bgImage: 'assets/images/featured_${(index % 2) + 1}.jpg',
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAsyncList(BuildContext context, AsyncValue<List<Opportunity>> async) {
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.darkRed)),
      error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.red))),
      data: (list) => Column(
        children: list.map((o) => _RecentOpportunityCard(
          title: o.title,
          startup: o.startupName,
          location: o.location,
          type: o.type,
          postedDays: DateTime.now().difference(o.createdAt).inDays,
        )).toList(),
      ),
    );
  }
}

// ── Glowing background orbs ──────────────────────────────────────────────────
class _GlowingBackground extends StatelessWidget {
  const _GlowingBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _Orb(size: size.width * 0.65, color: AppColors.darkRed.withValues(alpha: 0.15)),
          ),
          Positioned(
            top: size.height * 0.38,
            left: -80,
            child: _Orb(size: size.width * 0.55, color: AppColors.darkBlueLight.withValues(alpha: 0.45)),
          ),
          Positioned(
            bottom: size.height * 0.1,
            right: -40,
            child: _Orb(size: size.width * 0.45, color: AppColors.darkRed.withValues(alpha: 0.08)),
          ),
        ],
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

// ── Stat card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 12,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 16),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.headingMedium.copyWith(fontSize: 20, height: 1.1)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, height: 1.3)),
        ],
      ),
    );
  }
}

// ── Featured card ─────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final double width;
  final String title;
  final String startup;
  final String location;
  final String type;
  final String bgImage;

  const _FeaturedCard({
    required this.width,
    required this.title,
    required this.startup,
    required this.location,
    required this.type,
    required this.bgImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkRed.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                bgImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, _) => Container(
                  decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0x779A031E), Color(0xEE0B132B)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.business_rounded, color: AppColors.white, size: 18),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            type,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: AppTextStyles.headingMedium.copyWith(
                        fontSize: 16,
                        height: 1.25,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.business_rounded, color: AppColors.textSecondary, size: 12),
                        const SizedBox(width: 4),
                        Text(startup, style: AppTextStyles.bodyMedium.copyWith(fontSize: 11)),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on_rounded, color: AppColors.textSecondary, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recent opportunity card ───────────────────────────────────────────────────
class _RecentOpportunityCard extends StatelessWidget {
  final String title;
  final String startup;
  final String location;
  final String type;
  final int postedDays;

  const _RecentOpportunityCard({
    required this.title,
    required this.startup,
    required this.location,
    required this.type,
    required this.postedDays,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        blur: 12,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.redGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkRed.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.business_rounded, color: AppColors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    startup,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MiniTag(Icons.location_on_outlined, location),
                      const SizedBox(width: 10),
                      _MiniTag(Icons.work_outline, type),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.bookmark_border_rounded, color: AppColors.textSecondary, size: 20),
                const SizedBox(height: 6),
                Text(
                  '${postedDays}d ago',
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, height: 1.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniTag(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, height: 1.2)),
      ],
    );
  }
}
