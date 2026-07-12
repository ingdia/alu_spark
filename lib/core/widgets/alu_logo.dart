import 'package:flutter/material.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';

class AluLogo extends StatelessWidget {
  final double size;
  const AluLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            gradient: AppColors.redGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'ALU',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.white,
                fontSize: size * 0.35,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Spark',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.white,
            fontSize: size * 0.45,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
