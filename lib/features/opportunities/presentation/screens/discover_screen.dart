import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/glassmorphism_container.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(padding: const EdgeInsets.all(20.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Discover', style: AppTextStyles.headingLarge),
      const SizedBox(height: 8),
      Text('Find your next internship at ALU', style: AppTextStyles.bodyMedium),
      const SizedBox(height: 24),
      Expanded(child: GlassmorphicContainer(padding: const EdgeInsets.all(24), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.explore_rounded, size: 64, color: AppColors.darkRed),
        const SizedBox(height: 16),
        Text('Discover Opportunities', style: AppTextStyles.headingMedium),
        const SizedBox(height: 8),
        Text('Dummy data will be loaded here.', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
      ]))))
    ])));
  }
}