import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/app/router/app_router.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      
      final email = _emailController.text.trim();
      await authRepository.signUpWithEmail(
        email: email,
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
      );

      if (mounted) {
        _showToast('Account created! Please verify your email.');
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.otpVerification,
          (_) => false,
          arguments: {'name': _nameController.text.trim(), 'email': email},
        );
      }
    } catch (e) {
      if (mounted) {
        _showToast(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: AppColors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.darkRed : const Color(0xFF1B5E20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                Text('Create Account', style: AppTextStyles.headingLarge.copyWith(color: AppColors.white)),
                const SizedBox(height: 8),
                Text('Join the ALU Spark community', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 40),
                GlassmorphicContainer(
                  blur: 10,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _nameController,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.darkRed),
                      border: InputBorder.none,
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                  ),
                ),
                const SizedBox(height: 16),
                GlassmorphicContainer(
                  blur: 10,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.darkRed),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!value.contains('@')) return 'Please enter a valid email';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                GlassmorphicContainer(
                  blur: 10,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.darkRed),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your password';
                      if (value.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                          )
                        : Text('Create Account', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
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
