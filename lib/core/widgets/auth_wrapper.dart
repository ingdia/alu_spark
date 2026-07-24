import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/constants/app_constants.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/providers/role_provider.dart';
import 'package:alu_spark/features/auth/presentation/screens/app_loading_screen.dart';
import 'package:alu_spark/shared/enums/user_role.dart';

String resolvePostLoginDestination({
  required UserRole role,
  required bool profileComplete,
  required String? startupStatus,
}) {
  if (role == UserRole.student) {
    return RouteNames.home;
  }

  if (!profileComplete) {
    return RouteNames.roleSelection;
  }

  if (role == UserRole.founder && (startupStatus == 'pending' || startupStatus == 'rejected')) {
    return RouteNames.startupPending;
  }

  return RouteNames.home;
}

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _initialDelayDone = false;
  String? _lastAuthUid;
  String? _lastDestination;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _initialDelayDone = true);
    });
  }

  void _navigateTo(String routeName) {
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
    final currentFirebaseUser = ref.read(firebaseAuthServiceProvider).currentUser;

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
          _lastDestination = null;
        }

        // If the auth stream is temporarily empty during a login transition,
        // but Firebase already has a signed-in user, keep the wrapper on the
        // loading screen rather than bouncing to the splash/landing route.
        if (user == null) {
          if (currentFirebaseUser == null) {
            if (_lastDestination != RouteNames.splash) {
              _lastDestination = RouteNames.splash;
              _navigateTo(RouteNames.splash);
            }
          }
          return const AppLoadingScreen();
        }

        // Email not verified yet — route to the OTP screen, which polls for
        // verification and can recover. Returning a bare loading screen here
        // traps the user on an infinite spinner with no way out.
        // Admin role bypasses email verification requirement.
        final isAdmin = AppConstants.isAdminEmail(user.email);
        if (!user.isEmailVerified && !isAdmin) {
          if (_lastDestination != RouteNames.otpVerification) {
            _lastDestination = RouteNames.otpVerification;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                RouteNames.otpVerification,
                (_) => false,
                arguments: {'email': user.email, 'name': user.fullName},
              );
            });
          }
          return const AppLoadingScreen();
        }

        // Hardcoded admin email always goes home — no Firestore doc required
        if (isAdmin) {
          Future.microtask(() {
            ref.read(roleProvider.notifier).setRole(UserRole.admin);
            if (_lastDestination != RouteNames.home) {
              _lastDestination = RouteNames.home;
              _navigateTo(RouteNames.home);
            }
          });
          return const AppLoadingScreen();
        }

        // Students should reach Home immediately using the role already resolved
        // from the authenticated user state; waiting on the Firestore stream can
        // leave them stuck on the loading screen if the doc hasn't arrived yet.
        if (user.role == UserRole.student) {
          Future.microtask(() {
            ref.read(roleProvider.notifier).setRole(UserRole.student);
            if (_lastDestination != RouteNames.home) {
              _lastDestination = RouteNames.home;
              _navigateTo(RouteNames.home);
            }
          });
          return const AppLoadingScreen();
        }

        // Fetch fresh Firestore data to make routing decisions for founders.
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
                if (_lastDestination != RouteNames.home) {
                  _lastDestination = RouteNames.home;
                  _navigateTo(RouteNames.home);
                }
              });
              return const AppLoadingScreen();
            }

            final destination = resolvePostLoginDestination(
              role: role,
              profileComplete: profileComplete,
              startupStatus: startupStatus,
            );

            Future.microtask(() {
              ref.read(roleProvider.notifier).setRole(role);
              if (destination != _lastDestination) {
                _lastDestination = destination;
                _navigateTo(destination);
              }
            });
            return const AppLoadingScreen();
          },
        );
      },
    );
  }
}
