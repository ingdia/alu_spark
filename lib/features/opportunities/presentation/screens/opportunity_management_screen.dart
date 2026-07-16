import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/features/opportunities/presentation/providers/opportunity_provider.dart';
import 'package:alu_spark/features/opportunities/presentation/screens/post_opportunity_screen.dart';

class OpportunityManagementScreen extends ConsumerWidget {
  const OpportunityManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const LoadingWidget(message: 'Loading...');

    final opportunitiesAsync =
        ref.watch(founderOpportunitiesProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkRed,
        onPressed: () => Navigator.of(context)
            .pushNamed(RouteNames.postOpportunity),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: opportunitiesAsync.when(
        loading: () =>
            const LoadingWidget(message: 'Loading opportunities...'),
        error: (e, _) => ErrorStateWidget(
          message: 'Failed to load opportunities.',
          onRetry: () =>
              ref.invalidate(founderOpportunitiesProvider(user.id)),
        ),
        data: (opportunities) {
          if (opportunities.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.work_off_outlined,
              title: 'No Opportunities Yet',
              description:
                  'Tap the + button to post your first opportunity.',
            );
          }
          return RefreshIndicator(
            color: AppColors.darkRed,
            backgroundColor: AppColors.darkBlueLight,
            onRefresh: () async =>
                ref.invalidate(founderOpportunitiesProvider(user.id)),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: opportunities.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (_, i) => _OpportunityTile(
                opportunity: opportunities[i],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(12),
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 12,
          padding: EdgeInsets.zero,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: Text('My Opportunities',
          style:
              AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
      centerTitle: true,
    );
  }
}

// ── Opportunity tile ──────────────────────────────────────────────────────────

class _OpportunityTile extends ConsumerStatefulWidget {
  final Opportunity opportunity;
  const _OpportunityTile({required this.opportunity});

  @override
  ConsumerState<_OpportunityTile> createState() => _OpportunityTileState();
}

class _OpportunityTileState extends ConsumerState<_OpportunityTile> {
  bool _loading = false;

  Opportunity get opp => widget.opportunity;

  Future<void> _edit() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PostOpportunityScreen(initial: opp),
      ),
    );
  }

  Future<void> _close() async {
    final confirmed = await _confirm(
      title: 'Close Opportunity',
      body:
          'Closing "${opp.title}" will stop new applications. All applicants will be notified.',
      action: 'Close',
    );
    if (confirmed != true || !mounted) return;
    await _run(() async {
      final repo = ref.read(opportunityRepositoryProvider);
      final notifications = ref.read(notificationServiceProvider);
      final ids = await repo.getApplicantIds(opp.id);
      await repo.closeOpportunity(opp.id);
      await notifications.notifyOpportunityClosed(
        studentIds: ids,
        opportunityTitle: opp.title,
        opportunityId: opp.id,
      );
    }, 'Opportunity closed.');
  }

  Future<void> _archive() async {
    final confirmed = await _confirm(
      title: 'Archive Opportunity',
      body:
          'Archiving "${opp.title}" will hide it everywhere. All applicants will be notified.',
      action: 'Archive',
    );
    if (confirmed != true || !mounted) return;
    await _run(() async {
      final repo = ref.read(opportunityRepositoryProvider);
      final notifications = ref.read(notificationServiceProvider);
      final ids = await repo.getApplicantIds(opp.id);
      await repo.archiveOpportunity(opp.id);
      await notifications.notifyOpportunityArchived(
        studentIds: ids,
        opportunityTitle: opp.title,
        opportunityId: opp.id,
      );
    }, 'Opportunity archived.');
  }

  Future<void> _run(Future<void> Function() action, String successMsg) async {
    setState(() => _loading = true);
    try {
      await action();
      if (mounted) _snack(successMsg, success: true);
    } catch (e) {
      if (mounted) _snack('Failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String body,
    required String action,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.darkBlueLight,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: AppTextStyles.headingMedium
                      .copyWith(color: AppColors.white)),
              const SizedBox(height: 12),
              Text(body,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary, height: 1.5),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderGlass),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Cancel',
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkRed,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(action,
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
      backgroundColor:
          success ? const Color(0xFF1B5E20) : AppColors.darkRed,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(opp.status);
    final statusLabel = _statusLabel(opp.status);

    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  opp.title,
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(statusLabel,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Meta row
          Wrap(
            spacing: 12,
            children: [
              _meta(Icons.category_outlined, opp.category),
              _meta(Icons.location_on_outlined, opp.location),
              _meta(Icons.work_outline, opp.type),
              _meta(Icons.people_outline,
                  '${opp.applicationsCount} applicants'),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.borderGlass, height: 1),
          const SizedBox(height: 12),
          // Action buttons
          _loading
              ? const Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: AppColors.darkRed, strokeWidth: 2),
                  ),
                )
              : Row(
                  children: [
                    _actionBtn(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      onTap: _edit,
                    ),
                    const SizedBox(width: 8),
                    if (opp.status == OpportunityStatus.active) ...[
                      _actionBtn(
                        icon: Icons.lock_outline,
                        label: 'Close',
                        onTap: _close,
                        muted: true,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (opp.status != OpportunityStatus.archived)
                      _actionBtn(
                        icon: Icons.archive_outlined,
                        label: 'Archive',
                        onTap: _archive,
                        muted: true,
                      ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 13),
        const SizedBox(width: 4),
        Text(text,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool muted = false,
  }) {
    final color = muted ? AppColors.textSecondary : AppColors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderGlass),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Color _statusColor(OpportunityStatus s) {
    switch (s) {
      case OpportunityStatus.active:
        return const Color(0xFF34D399);
      case OpportunityStatus.closed:
        return AppColors.textSecondary;
      case OpportunityStatus.archived:
        return const Color(0xFF6366F1);
    }
  }

  String _statusLabel(OpportunityStatus s) {
    switch (s) {
      case OpportunityStatus.active:
        return 'Active';
      case OpportunityStatus.closed:
        return 'Closed';
      case OpportunityStatus.archived:
        return 'Archived';
    }
  }
}
