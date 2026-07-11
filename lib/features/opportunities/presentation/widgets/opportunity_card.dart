import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/glassmorphism_container.dart';

class OpportunityCard extends StatelessWidget {
  final String title;
  final String startup;
  final String location;
  final String type;
  final IconData logo;
  final int? postedDays;
  final VoidCallback? onTap;

  const OpportunityCard({
    super.key,
    required this.title,
    required this.startup,
    required this.location,
    required this.type,
    required this.logo,
    this.postedDays,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.darkRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(logo, color: AppColors.darkRedLight, size: 28),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.white)),
                  const SizedBox(height: 4),
                  Text(startup, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildTag(Icons.location_on_outlined, location),
                      _buildTag(Icons.work_outline, type),
                      if (postedDays != null) _buildTag(Icons.schedule, '$postedDays days ago'),
                    ],
                  ),
                ],
              ),
            ),
            // Bookmark Icon
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border_rounded, color: AppColors.textSecondary, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
      ],
    );
  }
}