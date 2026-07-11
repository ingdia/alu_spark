import 'package:flutter/material.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

class ApplyOpportunityScreen extends StatelessWidget {
  final Opportunity opportunity;

  const ApplyOpportunityScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Apply',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Apply for ${opportunity.title}',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
