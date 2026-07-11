import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:alu_spark/app/theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.glassWhite,
      highlightColor: AppColors.borderGlass,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class OpportunityCardShimmer extends StatelessWidget {
  const OpportunityCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerLoading(height: 50, width: 50, borderRadius: 12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLoading(height: 16, width: 150),
                    const SizedBox(height: 8),
                    const ShimmerLoading(height: 12, width: 100),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerLoading(height: 14, width: double.infinity),
          const SizedBox(height: 8),
          const ShimmerLoading(height: 14, width: 200),
          const SizedBox(height: 16),
          Row(
            children: [
              const ShimmerLoading(height: 24, width: 80, borderRadius: 12),
              const SizedBox(width: 8),
              const ShimmerLoading(height: 24, width: 80, borderRadius: 12),
              const Spacer(),
              const ShimmerLoading(height: 24, width: 24, borderRadius: 12),
            ],
          ),
        ],
      ),
    );
  }
}