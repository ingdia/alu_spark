import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/glassmorphism_container.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBlue,
              AppColors.darkBlueLight,
              AppColors.darkRed,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Glassmorphism Logo Card
              GlassmorphicContainer(
                blur: 15,
                borderRadius: 40,
                padding: const EdgeInsets.all(30),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ignite Your Career Journey',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Call to Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                      );
                    },
                    child: const Text('Get Started'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}