import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/shimmer_loading.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/features/opportunities/presentation/providers/opportunity_provider.dart';
import 'package:alu_spark/features/opportunities/presentation/widgets/opportunity_card.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  // Cache the last known data to prevent flashing on rebuilds
  List<Opportunity>? _cachedFeatured;
  List<Opportunity>? _cachedRecent;

  @override
  Widget build(BuildContext context) {
    // Watch the real-time streams from Firestore
    final featuredAsync = ref.watch(featuredOpportunitiesProvider);
    final recentAsync = ref.watch(recentOpportunitiesProvider);

    // Update cache when new data arrives
    featuredAsync.whenData((data) => _cachedFeatured = data);
    recentAsync.whenData((data) => _cachedRecent = data);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildSearchBar(context),
              const SizedBox(height: 32),
              
              // Featured Section
              _buildSectionHeader('Featured Opportunities'),
              const SizedBox(height: 16),
              _buildFeaturedList(context, featuredAsync),
              
              const SizedBox(height: 32),
              
              // Recent Section
              _buildSectionHeader('Recent Opportunities'),
              const SizedBox(height: 16),
              _buildRecentList(context, recentAsync, ref),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Discover',
      style: AppTextStyles.headingLarge.copyWith(color: AppColors.white),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(RouteNames.search),
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textSecondary, size: 24),
            const SizedBox(width: 12),
            Text(
              'Search opportunities...',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
        ),
        TextButton(
          onPressed: () {},
          child: Text('See All', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkRed)),
        ),
      ],
    );
  }

  // Featured Horizontal List with Async Handling - uses cache to prevent flash
  Widget _buildFeaturedList(BuildContext context, AsyncValue<List<Opportunity>> asyncValue) {
    // Use cached data if available to prevent flashing
    final displayData = asyncValue.whenOrNull(data: (data) => data) ?? _cachedFeatured;
    
    if (displayData != null) {
      final featured = displayData.take(3).toList();
      if (featured.isEmpty) {
        return const SizedBox(
          height: 220,
          child: Center(child: Text('No featured opportunities yet.')),
        );
      }
      return SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: featured.length,
          itemBuilder: (context, index) {
            final opp = featured[index];
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: OpportunityCard(
                  opportunity: opp,
                  onTap: () => Navigator.of(context).pushNamed(
                    RouteNames.opportunityDetail,
                    arguments: opp,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Only show shimmer on very first load
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.only(right: 16),
          child: SizedBox(width: 280, child: OpportunityCardShimmer()),
        ),
      ),
    );
  }

  // Recent Vertical List with Async Handling - uses cache to prevent flash
  Widget _buildRecentList(BuildContext context, AsyncValue<List<Opportunity>> asyncValue, WidgetRef ref) {
    // Use cached data if available to prevent flashing
    final displayData = asyncValue.whenOrNull(data: (data) => data) ?? _cachedRecent;

    if (displayData != null) {
      if (displayData.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('No recent opportunities found.'),
          ),
        );
      }
      return Column(
        children: displayData.map((opportunity) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OpportunityCard(
              opportunity: opportunity,
              onTap: () => Navigator.of(context).pushNamed(
                RouteNames.opportunityDetail,
                arguments: opportunity,
              ),
            ),
          );
        }).toList(),
      );
    }

    // Show error if we have no cache and there's an error
    if (asyncValue.hasError) {
      return ErrorStateWidget(
        message: asyncValue.error.toString(),
        onRetry: () => ref.invalidate(recentOpportunitiesProvider),
      );
    }

    // Only show shimmer on very first load
    return Column(
      children: List.generate(3, (_) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: OpportunityCardShimmer(),
      )),
    );
  }
}