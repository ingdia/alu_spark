import 'package:flutter/material.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool showBackground;

  const LoadingWidget({
    super.key,
    this.message,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showBackground) {
      return Container(
        color: AppColors.darkBlue.withOpacity(0.9),
        child: Center(
          child: _buildLoadingContent(),
        ),
      );
    }

    return Center(
      child: _buildLoadingContent(),
    );
  }

  Widget _buildLoadingContent() {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkRed),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}