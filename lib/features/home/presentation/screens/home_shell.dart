import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/providers/role_provider.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../app/router/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

// Student screens
import 'student_home_screen.dart';
import '../../../opportunities/presentation/screens/search_screen.dart';
import '../../../opportunities/presentation/screens/discover_screen.dart';
import '../../../messaging/presentation/screens/messages_screen.dart';
import '../../../student_profile/presentation/screens/student_profile_screen.dart';

// Founder screens
import 'founder_home_screen.dart';
import '../../../applications/presentation/screens/applications_received_screen.dart';
import '../../../opportunities/presentation/screens/post_opportunity_screen.dart';
import '../../../startup_profile/presentation/screens/startup_profile_screen.dart';

// Admin screens
import 'admin_home_screen.dart';
import '../../../admin_user_management/presentation/screens/admin_user_management_screen.dart';
import '../../../admin_verification/presentation/screens/admin_verification_screen.dart';
import '../../../admin_analytics/presentation/screens/admin_analytics_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;
  UserRole? _previousRole;

  List<Widget> _screensFor(UserRole role) {
    switch (role) {
      case UserRole.founder:
        return const [
          FounderHomeScreen(),
          ApplicationsReceivedScreen(),
          PostOpportunityScreen(),
          MessagesScreen(),
          StartupProfileScreen(),
        ];
      case UserRole.admin:
        return const [
          AdminHomeScreen(),
          AdminUserManagementScreen(),
          AdminVerificationScreen(),
          AdminAnalyticsScreen(),
          _AdminSettingsScreen(),
        ];
      case UserRole.student:
        return const [
          StudentHomeScreen(),
          DiscoverScreen(),
          SearchScreen(),
          MessagesScreen(),
          StudentProfileScreen(),
        ];
    }
  }

  List<_NavItem> _navItemsFor(UserRole role) {
    switch (role) {
      case UserRole.founder:
        return [
          _NavItem(Icons.dashboard_outlined, 'Dashboard'),
          _NavItem(Icons.inbox_outlined, 'Applications'),
          _NavItem(Icons.add_circle_outline, 'Post'),
          _NavItem(Icons.chat_bubble_outline, 'Messages'),
          _NavItem(Icons.business_outlined, 'Profile'),
        ];
      case UserRole.admin:
        return [
          _NavItem(Icons.home_outlined, 'Overview'),
          _NavItem(Icons.people_outline, 'Users'),
          _NavItem(Icons.verified_outlined, 'Verify'),
          _NavItem(Icons.bar_chart_outlined, 'Analytics'),
          _NavItem(Icons.settings_outlined, 'Settings'),
        ];
      case UserRole.student:
        return [
          _NavItem(Icons.home_outlined, 'Home'),
          _NavItem(Icons.explore_outlined, 'Discover'),
          _NavItem(Icons.search_outlined, 'Search'),
          _NavItem(Icons.chat_bubble_outline, 'Messages'),
          _NavItem(Icons.person_outline, 'Profile'),
        ];
    }
  }


  @override
  Widget build(BuildContext context) {
    final role = ref.watch(roleProvider);

    if (_previousRole != null && _previousRole != role) {
      _currentIndex = 0;
    }
    _previousRole = role;

    final screens = _screensFor(role);
    final navItems = _navItemsFor(role);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          top: false,
          bottom: false,
          child: IndexedStack(index: _currentIndex, children: screens),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(navItems),
    );
  }

  Widget _buildBottomNav(List<_NavItem> items) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 75,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.darkBlueLight.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.borderGlass, width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, items[0]),
              _buildNavItem(1, items[1]),
              const SizedBox(width: 60),
              _buildNavItem(3, items[3]),
              _buildNavItem(4, items[4]),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: GestureDetector(
            onTap: () => setState(() => _currentIndex = 2),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.redGradient,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.darkRed.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8))
                ],
              ),
              child: Icon(items[2].icon, color: AppColors.white, size: _currentIndex == 2 ? 28 : 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, _NavItem item) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon,
                color: isSelected ? AppColors.darkRed : AppColors.textSecondary, size: 26),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.darkRed : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _AdminSettingsScreen extends ConsumerWidget {
  const _AdminSettingsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTextStyles.headingLarge.copyWith(color: AppColors.white)),
              const SizedBox(height: 32),
              _tile(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Admin Account',
                sub: fb.FirebaseAuth.instance.currentUser?.email ?? 'admin',
              ),
              const SizedBox(height: 12),
              _tile(
                icon: Icons.info_outline,
                label: 'App Version',
                sub: '1.0.0',
              ),
              const SizedBox(height: 32),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkRed.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: AppColors.darkRed, size: 22),
                      const SizedBox(width: 16),
                      Text('Log Out',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.darkRed,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile({required IconData icon, required String label, required String sub}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.darkRed, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
              Text(sub, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
