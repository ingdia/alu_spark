import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String name;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.name,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  bool _canResend = false;
  int _timerSeconds = 60;
  Timer? _timer;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() { _timerSeconds = 60; _canResend = false; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        setState(() => _canResend = true);
        t.cancel();
      }
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkVerification(silent: true);
    });
  }

  Future<void> _checkVerification({bool silent = false}) async {
    if (!silent) setState(() => _isChecking = true);
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final user = authService.currentUser;
      if (user == null) return;
      await user.reload();
      final fresh = authService.currentUser;
      if (fresh != null && fresh.emailVerified) {
        // Force-refresh the ID token so Firestore sees email_verified = true
        await fresh.getIdToken(true);
        _pollTimer?.cancel();
        _timer?.cancel();
        if (mounted) _goToProfileSetup();
      } else if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Email not verified yet. Please check your inbox.'),
          backgroundColor: AppColors.darkRed,
        ));
      }
    } catch (_) {
    } finally {
      if (!silent && mounted) setState(() => _isChecking = false);
    }
  }

  void _goToProfileSetup() async {
    // Persist the verified flag, then refresh the auth stream so AuthWrapper
    // re-reads a fresh (verified) user. Routing through the root ('/') handles
    // BOTH a brand-new registrant (→ role selection) and a returning user who
    // just verified on a cold start (→ home / startup-pending) — the wrapper
    // decides based on their Firestore profile, so we don't hardcode it here.
    await ref.read(authRepositoryProvider).markEmailVerified();
    ref.invalidate(authStateProvider);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      AppRouter.generateRoute(const RouteSettings(name: '/')),
      (_) => false,
    );
  }

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (_) => false);
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    try {
      await ref.read(firebaseAuthServiceProvider).currentUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email resent!')),
        );
      }
      _startTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  String get _timerText {
    final m = _timerSeconds ~/ 60;
    final s = _timerSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text('Verify Your Email', style: AppTextStyles.headingLarge),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium,
                    children: [
                      const TextSpan(text: 'A verification link was sent to\n'),
                      TextSpan(
                        text: widget.email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '\n\nClick the link in your email, then tap the button below.'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                GlassmorphicContainer(
                  blur: 15,
                  borderRadius: 24,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.mark_email_unread_outlined, color: AppColors.darkRed, size: 64),
                      const SizedBox(height: 16),
                      Text('Check your inbox',
                          style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isChecking ? null : () => _checkVerification(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkRed,
                            disabledBackgroundColor: AppColors.glassWhite,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: _isChecking
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                              : Text("I've Verified My Email",
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.white, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Didn't receive it? ", style: AppTextStyles.bodyMedium),
                          GestureDetector(
                            onTap: (_canResend && !_isResending) ? _resendEmail : null,
                            child: _isResending
                                ? const SizedBox(width: 16, height: 16,
                                    child: CircularProgressIndicator(color: AppColors.darkRed, strokeWidth: 2))
                                : Text(
                                    _canResend ? 'Resend Email' : 'Resend in $_timerText',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: _canResend ? AppColors.darkRedLight : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Escape hatch: never trap a user on this screen. If the email
                // genuinely isn't verified (wrong account, no inbox access, an
                // admin-created record, etc.) they can sign out and return to
                // login instead of being stuck.
                Center(
                  child: TextButton(
                    onPressed: _signOut,
                    child: Text(
                      'Use a different account',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
