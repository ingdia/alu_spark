import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';

final _pendingStartupsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('startups')
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

class AdminVerificationScreen extends ConsumerWidget {
  const AdminVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(_pendingStartupsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(context),
      body: pendingAsync.when(
        loading: () => const LoadingWidget(message: 'Loading pending startups...'),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(_pendingStartupsProvider),
        ),
        data: (startups) => startups.isEmpty
            ? const EmptyStateWidget(
                icon: Icons.verified_outlined,
                title: 'All Caught Up',
                description: 'No startups pending verification.',
              )
            : _buildList(context, startups),
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
      title: Text(
        'Startup Verification',
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
      ),
      centerTitle: true,
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> startups) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: startups.length,
      itemBuilder: (context, index) => _buildCard(context, startups[index]),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> startup) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.darkRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business_outlined, color: AppColors.darkRed, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startup['name'] ?? 'Unnamed Startup',
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        startup['industry'] ?? '',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.darkRedLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pending',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.darkRedLight,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if ((startup['description'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                startup['description'] as String,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderGlass, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Approve',
                    icon: Icons.check_circle_outline,
                    color: AppColors.darkRed,
                    onTap: () => _updateStatus(context, startup['id'] as String, 'approved'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    label: 'Reject',
                    icon: Icons.cancel_outlined,
                    color: AppColors.textSecondary,
                    onTap: () => _updateStatus(context, startup['id'] as String, 'rejected'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String id, String status) async {
    await FirebaseFirestore.instance
        .collection('startups')
        .doc(id)
        .update({'status': status});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Startup ${status == 'approved' ? 'approved' : 'rejected'}.'),
          backgroundColor: AppColors.darkRed,
        ),
      );
    }
  }
}
