import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/widgets/alu_logo.dart';
import 'package:alu_spark/features/auth/presentation/providers/auth_provider.dart';
import 'package:alu_spark/features/auth/presentation/providers/auth_state.dart';
import 'package:alu_spark/features/auth/presentation/widgets/auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isStudent = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onStateChange(AuthState? previous, AuthState next) {
    if (next.status == AuthStatus.success) {
      if (_isStudent) {
        Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (_) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.startupOnboarding,
          (_) => false,
          arguments: _emailController.text.trim(),
        );
      }
      ref.read(authNotifierProvider.notifier).reset();
    } else if (next.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(next.errorMessage ?? 'An error occurred'),
          backgroundColor: AppColors.darkRed,
        ),
      );
      ref.read(authNotifierProvider.notifier).reset();
    }
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authNotifierProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _nameController.text.trim(),
          isStartup: !_isStudent,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, _onStateChange);
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Center(child: AluLogo()),
                const SizedBox(height: 28),
                Text('Create Account', style: AppTextStyles.headingLarge),
                const SizedBox(height: 6),
                Text('Who are you joining as?',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 20),

                // Role selector
                Row(
                  children: [
                    Expanded(child: _RoleCard(
                      icon: Icons.school_rounded,
                      label: 'Student',
                      subtitle: 'Find internships & projects',
                      selected: _isStudent,
                      onTap: () => setState(() => _isStudent = true),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _RoleCard(
                      icon: Icons.rocket_launch_rounded,
                      label: 'Startup',
                      subtitle: 'Post roles & find talent',
                      selected: !_isStudent,
                      onTap: () => setState(() => _isStudent = false),
                    )),
                  ],
                ),
                const SizedBox(height: 28),

                AuthTextField(
                  controller: _nameController,
                  hintText: _isStudent ? 'Full Name' : 'Your Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                if (!_isStudent)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'After registration you\'ll complete your startup profile for admin review.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: GestureDetector(
                    onTap: isLoading ? null : _handleRegister,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.redGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkRed.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                              )
                            : Text(
                                _isStudent ? 'Create Account' : 'Continue',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                AuthLinkRow(
                  label: 'Already have an account? ',
                  linkText: 'Log In',
                  onTap: () => Navigator.pushNamed(context, RouteNames.login),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.redGradient : null,
          color: selected ? null : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.borderGlass,
            width: 1.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.darkRed.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withValues(alpha: 0.2) : AppColors.darkRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: selected ? AppColors.white : AppColors.darkRed, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? Colors.white.withValues(alpha: 0.75) : AppColors.textSecondary,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
