import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/constants/app_constants.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/providers/role_provider.dart';
import 'package:alu_spark/features/auth/presentation/screens/app_loading_screen.dart';
import 'package:alu_spark/shared/enums/user_role.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _initialDelayDone = false;
  bool _hasNavigated = false;
  String? _lastAuthUid; // track identity changes only

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _initialDelayDone = true);
    });
  }

  void _navigateTo(String routeName) {
    if (_hasNavigated) return;
    _hasNavigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        AppRouter.generateRoute(RouteSettings(name: routeName)),
        (_) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialDelayDone) return const AppLoadingScreen();

    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const AppLoadingScreen(),
      error: (e, _) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
      data: (user) {
        // Only reset the navigation guard when the actual user identity changes
        // (login / logout), NOT on every Firestore snapshot rebuild
        final currentUid = user?.id;
        if (currentUid != _lastAuthUid) {
          _lastAuthUid = currentUid;
          _hasNavigated = false;
        }

        // Not logged in
        if (user == null) {
          _navigateTo(RouteNames.splash);
          return const AppLoadingScreen();
        }

        // Email not verified yet — stay put (OTP screen handles this)
        // Admin role bypasses email verification requirement
        final isAdmin = AppConstants.isAdminEmail(user.email);
        if (!user.isEmailVerified && !isAdmin) {
          return const AppLoadingScreen();
        }

        // Hardcoded admin email always goes home — no Firestore doc required
        if (isAdmin) {
          Future.microtask(() {
            ref.read(roleProvider.notifier).setRole(UserRole.admin);
            _navigateTo(RouteNames.home);
          });
          return const AppLoadingScreen();
        }

        // Fetch fresh Firestore data to make routing decisions
        return StreamBuilder<Map<String, dynamic>?>(
          stream: ref.read(authRepositoryProvider).getUserDataStream(user.id),
          builder: (context, snapshot) {
            // Doc missing → treat as incomplete profile
            if (snapshot.hasData && snapshot.data == null) {
              _navigateTo(RouteNames.roleSelection);
              return const AppLoadingScreen();
            }
            if (!snapshot.hasData) return const AppLoadingScreen();

            final data = snapshot.data!;
            final roleStr = data['role'] as String? ?? 'student';
            final profileComplete = data['profileComplete'] as bool? ?? false;
            final startupStatus = data['startupProfileStatus'] as String?;

            // Resolve role from Firestore (source of truth)
            final role = UserRole.values.firstWhere(
              (r) => r.name == roleStr,
              orElse: () => UserRole.student,
            );

            // Admin role from Firestore bypasses profile completion check
            if (role == UserRole.admin) {
              Future.microtask(() {
                ref.read(roleProvider.notifier).setRole(UserRole.admin);
                _navigateTo(RouteNames.home);
              });
              return const AppLoadingScreen();
            }

            String destination;
            if (!profileComplete) {
              destination = RouteNames.roleSelection;
            } else if (role == UserRole.founder && startupStatus == 'pending') {
              destination = RouteNames.startupPending;
            } else if (role == UserRole.founder && startupStatus == 'rejected') {
              destination = RouteNames.startupPending;
            } else {
              destination = RouteNames.home;
            }

            Future.microtask(() {
              ref.read(roleProvider.notifier).setRole(role);
              _navigateTo(destination);
            });
            return const AppLoadingScreen();
          },
        );
      },
    );
  }
}
