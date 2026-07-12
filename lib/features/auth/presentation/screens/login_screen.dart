import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/widgets/alu_logo.dart';
import 'package:alu_spark/features/auth/presentation/providers/auth_provider.dart';
import 'package:alu_spark/features/auth/presentation/providers/auth_state.dart';
import 'package:alu_spark/features/auth/presentation/widgets/auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onStateChange(AuthState? previous, AuthState next) {
    if (next.status == AuthStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.successMessage ?? '')),
      );
      ref.read(authNotifierProvider.notifier).reset();
    } else if (next.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.errorMessage ?? 'An error occurred')),
      );
      ref.read(authNotifierProvider.notifier).reset();
    }
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  void _handleForgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address first')),
      );
      return;
    }
    ref.read(authNotifierProvider.notifier).forgotPassword(email: email);
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
                const SizedBox(height: 40),
                const Center(child: AluLogo()),
                const SizedBox(height: 32),
                Text('Welcome Back', style: AppTextStyles.headingLarge.copyWith(color: AppColors.white)),
                const SizedBox(height: 8),
                Text('Log in to continue your journey',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 40),

                AuthTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your email';
                    if (!value.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _handleForgotPassword,
                    child: Text('Forgot Password?',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkRed,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                          )
                        : Text('Log In', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
                  ),
                ),
                const SizedBox(height: 24),

                AuthLinkRow(
                  label: "Don't have an account? ",
                  linkText: 'Register',
                  onTap: () => Navigator.pushNamed(context, RouteNames.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
