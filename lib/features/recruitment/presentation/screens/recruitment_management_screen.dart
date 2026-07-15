import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/features/applications/presentation/providers/application_provider.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

enum _SortOrder { newest, oldest, status }

class RecruitmentManagementScreen extends ConsumerStatefulWidget {
  const RecruitmentManagementScreen({super.key});

  @override
  ConsumerState<RecruitmentManagementScreen> createState() =>
      _RecruitmentManagementScreenState();
}

class _RecruitmentManagementScreenState
    extends ConsumerState<RecruitmentManagementScreen> {
  ApplicationStatus? _filterStatus;
  _SortOrder _sortOrder = _SortOrder.newest;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Application> _process(List<Application> all) {
    var list = all.where((a) {
      final matchesFilter =
          _filterStatus == null || a.status == _filterStatus;
      final q = _query.toLowerCase();
      final matchesSearch = q.isEmpty ||
          a.studentName.toLowerCase().contains(q) ||
          a.studentEmail.toLowerCase().contains(q) ||
          a.opportunityTitle.toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();

    switch (_sortOrder) {
      case _SortOrder.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOrder.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _SortOrder.status:
        list.sort((a, b) => a.status.index.compareTo(b.status.index));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    if (currentUser == null) return const LoadingWidget(message: 'Loading...');

    final applicationsAsync =
        ref.watch(applicationsByStartupProvider(currentUser.id));

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(context),
      body: applicationsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading candidates...'),
        error: (e, _) => ErrorStateWidget(
          message: 'Failed to load applications.',
          onRetry: () =>
              ref.invalidate(applicationsByStartupProvider(currentUser.id)),
        ),
        data: (all) {
          final processed = _process(all);
          return Column(
            children: [
              _buildSearchBar(),
              _buildFilterRow(all),
              Expanded(child: _buildList(context, all, processed)),
            ],
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recruitment',
              style: AppTextStyles.headingMedium
                  .copyWith(color: AppColors.white, fontSize: 18)),
          Text('Management System',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
      actions: [
        PopupMenuButton<_SortOrder>(
          icon: const Icon(Icons.sort, color: AppColors.white),
          color: AppColors.darkBlueLight,
          onSelected: (v) => setState(() => _sortOrder = v),
          itemBuilder: (_) => [
            _sortItem(_SortOrder.newest, 'Newest First', Icons.arrow_downward),
            _sortItem(_SortOrder.oldest, 'Oldest First', Icons.arrow_upward),
            _sortItem(_SortOrder.status, 'By Status', Icons.flag_outlined),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  PopupMenuItem<_SortOrder> _sortItem(
      _SortOrder v, String label, IconData icon) {
    final selected = _sortOrder == v;
    return PopupMenuItem(
      value: v,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color:
                  selected ? AppColors.darkRed : AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: selected
                      ? AppColors.white
                      : AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: _searchController,
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Search by name, email or role…',
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: AppColors.textSecondary),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        color: AppColors.textSecondary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
    );
  }

  Widget _buildFilterRow(List<Application> all) {
    final statuses = [
      null,
      ApplicationStatus.applied,
      ApplicationStatus.underReview,
      ApplicationStatus.interview,
      ApplicationStatus.accepted,
      ApplicationStatus.rejected,
    ];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = statuses[i];
          final label = s == null ? 'All' : s.displayName;
          final count = s == null
              ? all.length
              : all.where((a) => a.status == s).length;
          final selected = _filterStatus == s;
          return GestureDetector(
            onTap: () => setState(() => _filterStatus = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.darkRed
                    : AppColors.glassWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.darkRed
                      : AppColors.borderGlass,
                ),
              ),
              child: Text(
                '$label ($count)',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected
                      ? AppColors.white
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Application> all,
      List<Application> processed) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: _buildStats(all),
          ),
        ),
        if (processed.isEmpty)
          const SliverFillRemaining(
            child: EmptyStateWidget(
              icon: Icons.people_outline,
              title: 'No Candidates Found',
              description: 'Try adjusting your search or filter.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _ApplicantCard(application: processed[i]),
                childCount: processed.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStats(List<Application> all) {
    final total = all.length;
    final newApps =
        all.where((a) => a.status == ApplicationStatus.applied).length;
    final underReview =
        all.where((a) => a.status == ApplicationStatus.underReview).length;
    final interview =
        all.where((a) => a.status == ApplicationStatus.interview).length;
    final accepted =
        all.where((a) => a.status == ApplicationStatus.accepted).length;
    final rejected =
        all.where((a) => a.status == ApplicationStatus.rejected).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview',
            style: AppTextStyles.headingMedium
                .copyWith(color: AppColors.white)),
        const SizedBox(height: 12),
        Row(children: [
          _StatTile(label: 'Total', value: '$total',
              icon: Icons.people_outline, color: AppColors.white),
          const SizedBox(width: 10),
          _StatTile(label: 'New', value: '$newApps',
              icon: Icons.fiber_new_outlined,
              color: const Color(0xFF60A5FA)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _StatTile(label: 'Reviewing', value: '$underReview',
              icon: Icons.rate_review_outlined,
              color: const Color(0xFFFBBF24)),
          const SizedBox(width: 10),
          _StatTile(label: 'Interview', value: '$interview',
              icon: Icons.event_outlined,
              color: AppColors.darkRedLight),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _StatTile(label: 'Accepted', value: '$accepted',
              icon: Icons.check_circle_outline,
              color: const Color(0xFF34D399)),
          const SizedBox(width: 10),
          _StatTile(label: 'Rejected', value: '$rejected',
              icon: Icons.cancel_outlined,
              color: AppColors.textSecondary),
        ]),
        const SizedBox(height: 20),
        Text('Candidates',
            style: AppTextStyles.headingMedium
                .copyWith(color: AppColors.white)),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ─── Stat Tile ────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Text(label,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Applicant Card ───────────────────────────────────────────────────────────

class _ApplicantCard extends StatelessWidget {
  final Application application;

  const _ApplicantCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final app = application;
    final statusColor = _statusColor(app.status);
    final date =
        '${app.createdAt.day} ${_month(app.createdAt.month)} ${app.createdAt.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(
          RouteNames.applicantProfile,
          arguments: app,
        ),
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: statusColor.withValues(alpha: 0.2),
                    child: Text(
                      app.studentName.isNotEmpty
                          ? app.studentName[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: statusColor),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.studentName,
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: AppColors.white)),
                        const SizedBox(height: 2),
                        Text(app.studentEmail,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  _statusBadge(app.status, statusColor),
                ],
              ),
              const SizedBox(height: 12),
              _infoRow(Icons.work_outline, app.opportunityTitle),
              const SizedBox(height: 5),
              _infoRow(Icons.calendar_today_outlined, date),
              if (app.motivation.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(color: AppColors.borderGlass, height: 1),
                const SizedBox(height: 10),
                Text(
                  app.motivation,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('View Full Profile →',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkRedLight, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(ApplicationStatus status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(status.displayName,
          style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 13),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary, fontSize: 12),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Color _statusColor(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.applied:
        return const Color(0xFF60A5FA);
      case ApplicationStatus.underReview:
        return const Color(0xFFFBBF24);
      case ApplicationStatus.interview:
        return AppColors.darkRedLight;
      case ApplicationStatus.accepted:
        return const Color(0xFF34D399);
      case ApplicationStatus.rejected:
      case ApplicationStatus.withdrawn:
        return AppColors.textSecondary;
    }
  }

  String _month(int m) {
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}
