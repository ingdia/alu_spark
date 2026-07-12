import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/app/router/app_router.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  final Opportunity opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStartupHeader(),
                  const SizedBox(height: 24),
                  _buildTitleAndMeta(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('About the Role'),
                  const SizedBox(height: 12),
                  _buildDescription(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Requirements'),
                  const SizedBox(height: 12),
                  _buildRequirements(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('What We Offer'),
                  const SizedBox(height: 12),
                  _buildBenefits(),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
          _buildBottomBar(context, ref),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 12,
          padding: const EdgeInsets.all(0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.all(0),
            child: IconButton(
              icon: const Icon(Icons.bookmark_border, color: AppColors.white, size: 20),
              onPressed: () {
                // TODO: Toggle bookmark via provider
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.all(0),
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.white, size: 20),
              onPressed: () {
                // TODO: Share opportunity
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartupHeader() {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.darkRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business, color: AppColors.darkRed, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      opportunity.startupName,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: AppColors.darkRed, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${opportunity.category} • ${opportunity.type}',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndMeta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          opportunity.title,
          style: AppTextStyles.headingLarge.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (opportunity.location.isNotEmpty) _buildMetaChip(Icons.location_on_outlined, opportunity.location),
            _buildMetaChip(Icons.work_outline, opportunity.type),
            if (opportunity.salary != null && opportunity.salary!.isNotEmpty) 
              _buildMetaChip(Icons.attach_money, opportunity.salary!),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.darkRed, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
    );
  }

  Widget _buildDescription() {
    return Text(
      opportunity.description,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildRequirements() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opportunity.requirements.map((req) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGlass),
          ),
          child: Text(
            req,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBenefits() {
    return Column(
      children: opportunity.benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.darkRed, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  benefit,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkBlueLight,
        border: Border(top: BorderSide(color: AppColors.borderGlass, width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              // Increment application count in Firestore
              await ref.read(opportunityRepositoryProvider).incrementApplicationCount(opportunity.id);
              
              // Navigate to Apply Screen
              Navigator.of(context).pushNamed(
                RouteNames.applyOpportunity,
                arguments: opportunity,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Apply Now',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}