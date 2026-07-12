import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/features/startup_profile/presentation/providers/startup_provider.dart';
import 'package:alu_spark/features/startup_profile/domain/entities/startup.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StartupProfileScreen extends ConsumerWidget {
  const StartupProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final startupAsync = ref.watch(startupDetailProvider(uid));

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: startupAsync.when(
        loading: () => const LoadingWidget(message: 'Loading startup profile...'),
        error: (error, _) => ErrorStateWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(startupDetailProvider(uid)),
        ),
        data: (startup) {
          if (startup == null) {
            return const EmptyStateWidget(
              icon: Icons.business_outlined,
              title: 'Startup Not Found',
              description: 'This startup profile does not exist or has been removed.',
            );
          }
          return _buildContent(context, ref, startup);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Startup startup) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.darkBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.white),
              onPressed: () {},
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.darkBlueLight, AppColors.darkBlue],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.glassWhite,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderGlass),
                      ),
                      child: const Icon(Icons.business, size: 45, color: AppColors.darkRed),
                    ),
                    const SizedBox(height: 12),
                    Text(startup.name, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
                    const SizedBox(height: 4),
                    Text(startup.tagline, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white.withValues(alpha: 0.8))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.darkRed.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.darkRed),
                      ),
                      child: Text(startup.industry, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkRed)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickStats(startup),
                const SizedBox(height: 24),
                _buildSectionTitle('About Us'),
                const SizedBox(height: 12),
                _buildAboutSection(startup.description),
                if (startup.website.isNotEmpty || startup.linkedin.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('Links'),
                  const SizedBox(height: 12),
                  _buildLinks(startup),
                ],
                const SizedBox(height: 24),
                _buildSectionTitle('Our Team'),
                const SizedBox(height: 12),
                _buildTeamMembers(startup.teamMembers),
                const SizedBox(height: 24),
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
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkRed.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: AppColors.darkRed, size: 20),
                        const SizedBox(width: 10),
                        Text('Log Out',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.darkRed,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(Startup startup) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('Team', startup.teamSize.isNotEmpty ? startup.teamSize : '${startup.teamMembers.length}'),
        const SizedBox(width: 12),
        _buildStatItem('Stage', startup.stage.isNotEmpty ? startup.stage : '—'),
        const SizedBox(width: 12),
        _buildStatItem('Open Roles', '${startup.openRolesCount}'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white));
  }

  Widget _buildLinks(Startup startup) {
    return Column(
      children: [
        if (startup.website.isNotEmpty)
          _buildLinkTile(Icons.language_rounded, 'Website', startup.website),
        if (startup.linkedin.isNotEmpty)
          _buildLinkTile(Icons.link_rounded, 'LinkedIn', startup.linkedin),
      ],
    );
  }

  Widget _buildLinkTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkRed, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 11)),
                  Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(String description) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Text(description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5)),
    );
  }

  Widget _buildTeamMembers(List<Map<String, String>> members) {
    if (members.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No team members added yet.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return Column(
      children: members.map((member) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 16,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.darkRed.withValues(alpha: 0.2),
                  child: Text(
                    (member['name'] ?? '?').substring(0, 1),
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkRed),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member['name'] ?? '', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
                      Text(member['role'] ?? '', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
