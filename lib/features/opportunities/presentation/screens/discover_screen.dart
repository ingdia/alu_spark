import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/opportunity_provider.dart';
import '../widgets/opportunity_card.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(opportunityProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, Alex 👋', style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 4),
                        Text('Find your next big role', style: AppTextStyles.headingMedium),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderGlass),
                      ),
                      child: Stack(
                        children: [
                          const Icon(Icons.notifications_outlined, color: AppColors.white, size: 24),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.darkRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Category chips
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = state.selectedCategoryIndex == index;
                      return GestureDetector(
                        onTap: () => ref
                            .read(opportunityProvider.notifier)
                            .selectCategory(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.darkRed : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.darkRed : AppColors.borderGlass,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              state.categories[index],
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isSelected ? AppColors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Featured
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Text('Featured Opportunities',
                    style: AppTextStyles.headingMedium.copyWith(fontSize: 18)),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPadding(
              padding: const EdgeInsets.only(left: 20),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.featured.length,
                    itemBuilder: (context, index) =>
                        _FeaturedCard(data: state.featured[index]),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Recent
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Text('Recent Opportunities',
                    style: AppTextStyles.headingMedium.copyWith(fontSize: 18)),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = state.filteredRecent[index];
                    return OpportunityCard(
                      title: item['title'],
                      startup: item['startup'],
                      location: item['location'],
                      type: item['type'],
                      logo: item['logo'],
                      postedDays: item['postedDays'],
                    );
                  },
                  childCount: state.filteredRecent.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _FeaturedCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data['color'] as Color;
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
        ),
        border: Border.all(color: AppColors.borderGlass, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data['logo'], color: AppColors.white, size: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data['type'],
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['title'],
                  style: AppTextStyles.headingMedium
                      .copyWith(fontSize: 18, color: AppColors.white)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.business_rounded, color: AppColors.white, size: 16),
                const SizedBox(width: 4),
                Text(data['startup'],
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.white.withOpacity(0.9))),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined, color: AppColors.white, size: 16),
                const SizedBox(width: 4),
                Text(data['location'],
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.white.withOpacity(0.9))),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
