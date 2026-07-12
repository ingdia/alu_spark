import 'package:flutter/material.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback? onTap;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        // Navigation will be handled by the parent or router
      },
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Startup Logo Placeholder
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.darkRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business, color: AppColors.darkRed, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        opportunity.startupName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.bookmark_border, color: AppColors.textSecondary, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            // Tags Row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag(opportunity.type),
                if (opportunity.location.isNotEmpty) _buildTag(opportunity.location),
                if (opportunity.category.isNotEmpty) _buildTag(opportunity.category),
              ],
            ),
            const SizedBox(height: 16),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Posted ${_getTimeAgo(opportunity.createdAt)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${opportunity.applicationsCount} applied',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.darkRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
          fontSize: 11,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    return 'Just now';
  }
}