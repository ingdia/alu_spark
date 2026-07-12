import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/shimmer_loading.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/features/opportunities/presentation/providers/opportunity_provider.dart';
import 'package:alu_spark/features/opportunities/presentation/widgets/opportunity_card.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the real-time streams from Firestore
    final featuredAsync = ref.watch(featuredOpportunitiesProvider);
    final recentAsync = ref.watch(recentOpportunitiesProvider);

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
      onTap: () {
        // TODO: Navigate to search screen
      },
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

  // Featured Horizontal List with Async Handling
  Widget _buildFeaturedList(BuildContext context, AsyncValue<List<Opportunity>> asyncValue) {
    return SizedBox(
      height: 220,
      child: asyncValue.when(
        loading: () => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.only(right: 16),
            child: SizedBox(width: 280, child: OpportunityCardShimmer()),
          ),
        ),
        error: (error, _) => Center(child: Text('Error: $error', style: TextStyle(color: Colors.red))),
        data: (opportunities) {
          if (opportunities.isEmpty) {
            return const Center(child: Text('No featured opportunities yet.'));
          }
          // Show first 3 for featured
          final featured = opportunities.take(3).toList();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featured.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: OpportunityCard(opportunity: featured[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Recent Vertical List with Async Handling
  Widget _buildRecentList(BuildContext context, AsyncValue<List<Opportunity>> asyncValue, WidgetRef ref) {
    return asyncValue.when(
      loading: () => Column(
        children: List.generate(3, (_) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: OpportunityCardShimmer(),
        )),
      ),
      error: (error, stack) => ErrorStateWidget(
        message: error.toString(),
        onRetry: () => ref.invalidate(recentOpportunitiesProvider),
      ),
      data: (opportunities) {
        if (opportunities.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No recent opportunities found.'),
            ),
          );
        }
        return Column(
          children: opportunities.map((opportunity) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OpportunityCard(opportunity: opportunity),
            );
          }).toList(),
        );
      },
    );
  }
}