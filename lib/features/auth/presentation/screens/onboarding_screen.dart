import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
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
      imageAsset: 'assets/images/onboarding_1.jpg',
      tag: 'DISCOVER',
      title: 'Find Your\nDream Role',
      description:
          'Browse internships and projects from verified student-led startups within the ALU ecosystem.',
      icon: Icons.search_rounded,
    ),
    _OnboardingData(
      imageAsset: 'assets/images/onboarding_2.jpg',
      tag: 'CONNECT',
      title: 'Meet the\nFounders',
      description:
          'Apply directly, chat with startup founders, and showcase your skills to the right teams.',
      icon: Icons.handshake_rounded,
    ),
    _OnboardingData(
      imageAsset: 'assets/images/onboarding_3.jpg',
      tag: 'GROW',
      title: 'Build Your\nFuture',
      description:
          'Track applications, manage your portfolio, and gain real-world experience before graduation.',
      icon: Icons.trending_up_rounded,
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
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _onSkip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, index) => _FullScreenPage(
              data: _pages[index],
              size: size,
            ),
          ),
          // Skip button — 16px from right, 12px from top of SafeArea
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 12),
                child: GestureDetector(
                  onTap: _onSkip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.glassWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderGlass, width: 1),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomCard(
              pages: _pages,
              currentPage: _currentPage,
              bottomPadding: bottomPadding,
              onNext: _onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenPage extends StatelessWidget {
  final _OnboardingData data;
  final Size size;

  const _FullScreenPage({required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          data.imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          ),
        ),
        // Gradient: lighter at top, heavier at bottom
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.3, 0.65, 1.0],
              colors: [
                Color(0x550B132B),
                Color(0x220B132B),
                Color(0xBB0B132B),
                Color(0xFF0B132B),
              ],
            ),
          ),
        ),
        // Tag — 24px left, 56px below SafeArea top
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 24, top: 56),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.darkRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data.tag,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomCard extends StatelessWidget {
  final List<_OnboardingData> pages;
  final int currentPage;
  final double bottomPadding;
  final VoidCallback onNext;

  const _BottomCard({
    required this.pages,
    required this.currentPage,
    required this.bottomPadding,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final page = pages[currentPage];
    final isLast = currentPage == pages.length - 1;

    return Container(
      // 8pt grid: 24px horizontal, 28px top, safe bottom + 24
      padding: EdgeInsets.fromLTRB(24, 28, 24, bottomPadding + 24),
      decoration: const BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon badge: 48×48, radius 14
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.redGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(page.icon, color: AppColors.white, size: 24),
          ),
          const SizedBox(height: 16),
          // Title: 30px, tight tracking, line-height 1.2
          Text(
            page.title,
            style: AppTextStyles.headingLarge.copyWith(
              fontSize: 30,
              height: 1.2,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          // Description: 14px, line-height 1.55
          Text(
            page.description,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          // Indicators + button
          Row(
            children: [
              Row(
                children: List.generate(
                  pages.length,
                  (i) => AnimatedContainer(
                    margin: const EdgeInsets.only(right: 6),
                    // Active: 24px wide, inactive: 6px — height 6px (8pt grid)
                    width: currentPage == i ? 24 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: currentPage == i
                          ? AppColors.darkRed
                          : AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    duration: const Duration(milliseconds: 280),
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onNext,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  // Button: 48px tall (8pt grid), horizontal padding scales with label
                  padding: EdgeInsets.symmetric(
                    horizontal: isLast ? 24 : 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.redGradient,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkRed.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLast ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String imageAsset;
  final String tag;
  final String title;
  final String description;
  final IconData icon;

  _OnboardingData({
    required this.imageAsset,
    required this.tag,
    required this.title,
    required this.description,
    required this.icon,
  });
}
