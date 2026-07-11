import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/glassmorphism_container.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.search_rounded,
      title: 'Discover Opportunities',
      description: 'Browse internships and projects from verified student-led startups within the ALU ecosystem.',
    ),
    _OnboardingData(
      icon: Icons.handshake_rounded,
      title: 'Connect with Founders',
      description: 'Apply directly, chat with startup founders, and showcase your skills to the right teams.',
    ),
    _OnboardingData(
      icon: Icons.trending_up_rounded,
      title: 'Build Your Future',
      description: 'Track your applications, manage your portfolio, and gain real-world experience before graduation.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut,
      );
    } else {
      // Placeholder navigation for the next commit (Login Screen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Skip / Finish Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _onNext,
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Finish' : 'Skip',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.darkRed, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              // Swipeable Content
              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glassmorphism Icon Container
                        GlassmorphicContainer(
                          blur: 10,
                          borderRadius: 100,
                          padding: const EdgeInsets.all(40),
                          margin: const EdgeInsets.only(bottom: 40),
                          child: Icon(
                            page.icon,
                            size: 80,
                            color: AppColors.darkRed,
                          ),
                        ),
                        Text(
                          page.title,
                          style: AppTextStyles.headingMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: AppTextStyles.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Animated Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.darkRed : AppColors.lightGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    duration: const Duration(milliseconds: 300),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Next / Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onNext,
                  child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  _OnboardingData({required this.icon, required this.title, required this.description});
}
