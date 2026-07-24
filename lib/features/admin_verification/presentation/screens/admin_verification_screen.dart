import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/features/admin_verification/presentation/providers/verification_provider.dart';

class AdminVerificationScreen extends ConsumerWidget {
  const AdminVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingStartupsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(context),
      body: pendingAsync.when(
        loading: () => const LoadingWidget(message: 'Loading pending startups...'),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(pendingStartupsProvider),
        ),
        data: (startups) => startups.isEmpty
            ? const EmptyStateWidget(
                icon: Icons.verified_outlined,
                title: 'All Caught Up',
                description: 'No startups pending verification.',
              )
            : _buildList(context, ref, startups),
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

  Widget _buildList(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> startups) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: startups.length,
      itemBuilder: (context, index) => _buildCard(context, ref, startups[index]),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, Map<String, dynamic> startup) {
    final name = startup['startupName'] ?? startup['name'] ?? 'Unnamed Startup';
    final proofUrl = startup['proofDocumentUrl'] as String? ?? '';
    final founders = (startup['founders'] as List<dynamic>? ?? []);
    final submittedAt = startup['submittedAt'] as Timestamp?;
    final dateStr = submittedAt != null
        ? _formatDate(submittedAt.toDate())
        : 'Unknown date';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
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
                      Text(name, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
                      const SizedBox(height: 2),
                      Text(
                        '${startup['industry'] ?? ''} · ${startup['stage'] ?? ''}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
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
                  child: Text('Pending',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkRedLight, fontSize: 12)),
                ),
              ],
            ),

            // Submission date
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.schedule, color: AppColors.textSecondary, size: 13),
                const SizedBox(width: 4),
                Text('Submitted $dateStr',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),

            // Description
            if ((startup['description'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                startup['description'] as String,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Founders list
            if (founders.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Founders',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ...founders.map((f) {
                final fm = f as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        '${fm['name'] ?? ''} · ${fm['role'] ?? ''}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white, fontSize: 12),
                      ),
                      if ((fm['email'] ?? '').isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text('(${fm['email']})',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ],
                  ),
                );
              }),
            ],

            // Proof document link
            if (proofUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => launchUrl(Uri.parse(proofUrl), mode: LaunchMode.externalApplication),
                child: Row(
                  children: [
                    const Icon(Icons.open_in_new, color: AppColors.darkRed, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        proofUrl,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkRed,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.darkRed,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
                    onTap: () => _updateStatus(context, ref, startup['id'] as String, 'approved', name),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    label: 'Reject',
                    icon: Icons.cancel_outlined,
                    color: AppColors.textSecondary,
                    onTap: () => _showRejectDialog(context, ref, startup['id'] as String, name),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Future<void> _showRejectDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBlueLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject "$name"?',
            style: AppTextStyles.headingMedium.copyWith(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Provide a reason (optional):',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 10),
            GlassmorphicContainer(
              blur: 10,
              borderRadius: 10,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: reasonController,
                maxLines: 3,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Insufficient documentation...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Reject', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkRed)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await _updateStatus(context, ref, id, 'rejected', name,
          reason: reasonController.text.trim());
    }
    reasonController.dispose();
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

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String id,
    String status,
    String startupName, {
    String? reason,
  }) async {
    try {
      if (status == 'approved') {
        await ref.read(verificationNotifierProvider.notifier).approveStartup(id);
      } else {
        await ref.read(verificationNotifierProvider.notifier).rejectStartup(id, reason: reason);
      }

      // Notify the founder
      await ref.read(notificationServiceProvider).notifyStartupStatus(
            founderId: id,
            startupName: startupName,
            status: status,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              Icon(
                status == 'approved' ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: Colors.white, size: 18,
              ),
              const SizedBox(width: 10),
              Text('Startup ${status == 'approved' ? 'approved ✓' : 'rejected'}.'),
            ]),
            backgroundColor: status == 'approved' ? const Color(0xFF1B5E20) : AppColors.darkRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.darkRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}
