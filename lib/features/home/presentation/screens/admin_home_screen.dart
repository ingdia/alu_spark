import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/widgets/alu_logo.dart';
import 'package:alu_spark/features/admin_analytics/presentation/providers/analytics_provider.dart';
import 'package:alu_spark/features/admin_verification/presentation/providers/verification_provider.dart';

class _ActivityItem {
  final IconData icon;
  final String text;
  final DateTime time;
  const _ActivityItem({required this.icon, required this.text, required this.time});
}

final _recentActivityProvider = FutureProvider<List<_ActivityItem>>((ref) async {
  final firestore = FirebaseFirestore.instance;

  final results = await Future.wait([
    firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get(),
    firestore
        .collection('opportunities')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get(),
    firestore
        .collection('startups')
        .where('status', whereIn: ['approved', 'rejected'])
        .orderBy('updatedAt', descending: true)
        .limit(5)
        .get(),
  ]);

  final items = <_ActivityItem>[];

  for (final doc in results[0].docs) {
    final d = doc.data();
    final ts = d['createdAt'] as Timestamp?;
    if (ts == null) continue;
    final role = d['role'] as String? ?? 'student';
    final name = d['fullName'] as String? ?? 'Someone';
    items.add(_ActivityItem(
      icon: role == 'founder' ? Icons.rocket_launch_outlined : Icons.person_add_outlined,
      text: '$name joined as a ${role[0].toUpperCase()}${role.substring(1)}',
      time: ts.toDate(),
    ));
  }

  for (final doc in results[1].docs) {
    final d = doc.data();
    final ts = d['createdAt'] as Timestamp?;
    if (ts == null) continue;
    items.add(_ActivityItem(
      icon: Icons.add_circle_outline,
      text: 'New opportunity: "${d['title'] ?? 'Untitled'}" at ${d['startupName'] ?? ''}',
      time: ts.toDate(),
    ));
  }

  for (final doc in results[2].docs) {
    final d = doc.data();
    final ts = d['updatedAt'] as Timestamp?;
    if (ts == null) continue;
    final status = d['status'] as String? ?? '';
    final name = d['startupName'] ?? d['name'] ?? 'A startup';
    items.add(_ActivityItem(
      icon: status == 'approved' ? Icons.verified_outlined : Icons.cancel_outlined,
      text: '$name verification $status',
      time: ts.toDate(),
    ));
  }

  items.sort((a, b) => b.time.compareTo(a.time));
  return items.take(5).toList();
});

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(platformStatsProvider);
    final pendingAsync = ref.watch(pendingStartupsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ref),
              const SizedBox(height: 24),
              statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.darkRed)),
                error: (_, _) => _buildPlatformStatsStatic(),
                data: (stats) => _buildPlatformStatsLive(
                  students: stats.totalStudents,
                  founders: stats.totalFounders,
                  opportunities: stats.totalOpportunities,
                  pending: pendingAsync.value?.length ?? 0,
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Admin Actions'),
              const SizedBox(height: 16),
              _buildAdminActions(context),
              const SizedBox(height: 32),
              _buildSectionHeader('Recent Activity'),
              const SizedBox(height: 16),
              _buildRecentActivityLive(ref),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const AluLogo(size: 40),
        GestureDetector(
          onTap: () async {
            await ref.read(authRepositoryProvider).signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                AppRouter.generateRoute(const RouteSettings(name: RouteNames.splash)),
                (_) => false,
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.darkRed.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.logout, color: AppColors.darkRed, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformStatsLive({required int students, required int founders, required int opportunities, required int pending}) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard('Students', '$students', Icons.school_outlined),
            _buildStatCard('Founders', '$founders', Icons.rocket_launch_outlined),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard('Opportunities', '$opportunities', Icons.work_outline),
            _buildStatCard('Pending', '$pending', Icons.hourglass_empty_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildPlatformStatsStatic() {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard('Students', '—', Icons.school_outlined),
            _buildStatCard('Founders', '—', Icons.rocket_launch_outlined),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard('Opportunities', '—', Icons.work_outline),
            _buildStatCard('Pending', '—', Icons.hourglass_empty_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.darkRed, size: 20),
              ),
              const SizedBox(height: 12),
              Text(count, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
              const SizedBox(height: 4),
              Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white));
  }

  Widget _buildAdminActions(BuildContext context) {
    final actions = [
      {'label': 'Verify Startups', 'icon': Icons.verified_outlined, 'route': RouteNames.adminVerification},
      {'label': 'Manage Users', 'icon': Icons.people_outline, 'route': RouteNames.adminUserManagement},
      {'label': 'Analytics', 'icon': Icons.bar_chart_outlined, 'route': RouteNames.adminAnalytics},
      {'label': 'Notifications', 'icon': Icons.notifications_outlined, 'route': RouteNames.notifications},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, action['route'] as String),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(action['icon'] as IconData, color: AppColors.darkRed, size: 28),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    action['label'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivityLive(WidgetRef ref) {
    return ref.watch(_recentActivityProvider).when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.darkRed)),
      error: (_, _) => GestureDetector(
        onTap: () => ref.invalidate(_recentActivityProvider),
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Text('Failed to load. Tap to retry.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return GlassmorphicContainer(
            blur: 10,
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Text('No recent activity.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          );
        }
        return Column(
          children: items.map((act) {
            final diff = DateTime.now().difference(act.time);
            final timeLabel = diff.inMinutes < 60
                ? '${diff.inMinutes}m ago'
                : diff.inHours < 24
                    ? '${diff.inHours}h ago'
                    : '${diff.inDays}d ago';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassmorphicContainer(
                blur: 10,
                borderRadius: 16,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.darkRed.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(act.icon, color: AppColors.darkRed, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(act.text,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
                    ),
                    Text(timeLabel,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
