import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/features/bookmarks/domain/entities/bookmark.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/features/applications/presentation/providers/application_provider.dart';
import 'package:alu_spark/shared/enums/application_status.dart';
import 'package:alu_spark/app/router/app_router.dart';

class OpportunityDetailScreen extends ConsumerStatefulWidget {
  final Opportunity opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  ConsumerState<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState
    extends ConsumerState<OpportunityDetailScreen> {
  bool _isBookmarked = false;
  bool _bookmarkLoading = false;

  Opportunity get opportunity => widget.opportunity;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    final result = await ref
        .read(bookmarkRepositoryProvider)
        .isBookmarked(user.id, opportunity.id);
    if (mounted) setState(() => _isBookmarked = result);
  }

  Future<void> _toggleBookmark() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    setState(() => _bookmarkLoading = true);
    try {
      if (_isBookmarked) {
        final bookmarks = await ref
            .read(bookmarkRepositoryProvider)
            .getBookmarksByUser(user.id)
            .first;
        final match =
            bookmarks.where((b) => b.opportunityId == opportunity.id);
        if (match.isNotEmpty) {
          await ref
              .read(bookmarkRepositoryProvider)
              .removeBookmark(match.first.id);
        }
        setState(() => _isBookmarked = false);
      } else {
        await ref.read(bookmarkRepositoryProvider).addBookmark(Bookmark(
              id: '',
              userId: user.id,
              opportunityId: opportunity.id,
              opportunityTitle: opportunity.title,
              startupName: opportunity.startupName,
              category: opportunity.category,
              location: opportunity.location,
              createdAt: DateTime.now(),
            ));
        setState(() => _isBookmarked = true);
      }
    } finally {
      if (mounted) setState(() => _bookmarkLoading = false);
    }
  }

  Future<void> _withdraw(Application app) async {
    final confirmed = await showDialog<bool>(
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
              Text('Withdraw Application',
                  style: AppTextStyles.headingMedium
                      .copyWith(color: AppColors.white)),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to withdraw your application for ${opportunity.title}? This cannot be undone.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        side:
                            const BorderSide(color: AppColors.borderGlass),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
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
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text('Withdraw',
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(applicationRepositoryProvider)
          .withdrawApplication(app.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = fb.FirebaseAuth.instance.currentUser?.uid ?? '';
    final appAsync = ref.watch(applicationForOpportunityProvider(
        (studentId: uid, opportunityId: opportunity.id)));

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStartupHeader(),
                  const SizedBox(height: 24),
                  _buildTitleAndMeta(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('About the Role'),
                  const SizedBox(height: 12),
                  _buildDescription(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Requirements'),
                  const SizedBox(height: 12),
                  _buildRequirements(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('What We Offer'),
                  const SizedBox(height: 12),
                  _buildBenefits(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, appAsync),
        ],
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
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.all(0),
            child: IconButton(
              icon: _bookmarkLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2))
                  : Icon(
                      _isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: _isBookmarked
                          ? AppColors.darkRed
                          : AppColors.white,
                      size: 20,
                    ),
              onPressed: _bookmarkLoading ? null : _toggleBookmark,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.all(0),
            child: IconButton(
              icon: const Icon(Icons.share_outlined,
                  color: AppColors.white, size: 20),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartupHeader() {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.business, color: AppColors.darkRed, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      opportunity.startupName,
                      style:
                          AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified,
                        color: AppColors.darkRed, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${opportunity.category} • ${opportunity.type}',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndMeta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          opportunity.title,
          style: AppTextStyles.headingLarge.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (opportunity.location.isNotEmpty)
              _buildMetaChip(
                  Icons.location_on_outlined, opportunity.location),
            _buildMetaChip(Icons.work_outline, opportunity.type),
            if (opportunity.salary != null &&
                opportunity.salary!.isNotEmpty)
              _buildMetaChip(Icons.attach_money, opportunity.salary!),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.darkRed, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white));
  }

  Widget _buildDescription() {
    return Text(
      opportunity.description,
      style: AppTextStyles.bodyMedium
          .copyWith(color: AppColors.textSecondary, height: 1.5),
    );
  }

  Widget _buildRequirements() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opportunity.requirements.map((req) {
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGlass),
          ),
          child: Text(req,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.white)),
        );
      }).toList(),
    );
  }

  Widget _buildBenefits() {
    return Column(
      children: opportunity.benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    color: AppColors.darkRed, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(benefit,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary, height: 1.4)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Bottom bar — reacts to application state ──────────────────────────────
  Widget _buildBottomBar(
      BuildContext context, AsyncValue<Application?> appAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkBlueLight,
        border:
            Border(top: BorderSide(color: AppColors.borderGlass, width: 1)),
      ),
      child: SafeArea(
        child: appAsync.when(
          loading: () => const SizedBox(
            height: 50,
            child: Center(
                child: CircularProgressIndicator(
                    color: AppColors.darkRed, strokeWidth: 2)),
          ),
          error: (_, __) => _applyButton(context),
          data: (app) {
            if (app == null) return _applyButton(context);
            return _applicationStatusPanel(context, app);
          },
        ),
      ),
    );
  }

  Widget _applyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pushNamed(
          RouteNames.applyOpportunity,
          arguments: opportunity,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkRed,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text('Apply Now',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
      ),
    );
  }

  Widget _applicationStatusPanel(BuildContext context, Application app) {
    switch (app.status) {
      case ApplicationStatus.applied:
      case ApplicationStatus.underReview:
      case ApplicationStatus.interview:
        return _activeApplicationPanel(context, app);
      case ApplicationStatus.accepted:
        return _acceptedPanel();
      case ApplicationStatus.rejected:
        return _rejectedPanel();
      case ApplicationStatus.withdrawn:
        return _withdrawnPanel();
    }
  }

  Widget _activeApplicationPanel(BuildContext context, Application app) {
    final submittedDate =
        '${app.createdAt.day}/${app.createdAt.month}/${app.createdAt.year}';
    final updatedDate =
        '${app.updatedAt.day}/${app.updatedAt.month}/${app.updatedAt.year}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassmorphicContainer(
          blur: 10,
          borderRadius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: AppColors.darkRed, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Application Submitted',
                        style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('Submitted $submittedDate · Updated $updatedDate',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              _statusBadge(app.status),
            ],
          ),
        ),
        if (app.status == ApplicationStatus.interview) ...[
          const SizedBox(height: 8),
          GlassmorphicContainer(
            blur: 10,
            borderRadius: 14,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.event_outlined,
                    color: AppColors.darkRedLight, size: 18),
                const SizedBox(width: 10),
                Text('Interview Scheduled',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkRedLight,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: () => _withdraw(app),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.borderGlass),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Withdraw Application',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
        ),
      ],
    );
  }

  Widget _acceptedPanel() {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🎉', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Congratulations!',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Your offer has been accepted.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          _statusBadge(ApplicationStatus.accepted),
        ],
      ),
    );
  }

  Widget _rejectedPanel() {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline,
                color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Application Unsuccessful',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Thank you for applying.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          _statusBadge(ApplicationStatus.rejected),
        ],
      ),
    );
  }

  Widget _withdrawnPanel() {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.undo_outlined,
                color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Application Withdrawn',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('You withdrew this application.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          _statusBadge(ApplicationStatus.withdrawn),
        ],
      ),
    );
  }

  Widget _statusBadge(ApplicationStatus status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.displayName,
          style: AppTextStyles.bodyMedium
              .copyWith(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return AppColors.textSecondary;
      case ApplicationStatus.underReview:
        return const Color(0xFF6366F1);
      case ApplicationStatus.interview:
        return AppColors.darkRedLight;
      case ApplicationStatus.accepted:
        return const Color(0xFF22C55E);
      case ApplicationStatus.rejected:
      case ApplicationStatus.withdrawn:
        return AppColors.textSecondary;
    }
  }
}
