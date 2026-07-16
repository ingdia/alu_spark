import 'package:flutter/material.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(16),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text('Settings', style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings_rounded, color: AppColors.darkRed, size: 48),
            ),
            const SizedBox(height: 20),
            Text('Settings Coming Soon',
                style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
            const SizedBox(height: 8),
            Text(
              'Notification preferences, privacy,\nand account settings will appear here.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
