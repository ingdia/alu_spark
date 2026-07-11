import 'package:flutter/material.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';

// --- Auth Screens ---
import 'package:alu_spark/features/auth/presentation/screens/splash_screen.dart';
import 'package:alu_spark/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:alu_spark/features/auth/presentation/screens/login_screen.dart';
import 'package:alu_spark/features/auth/presentation/screens/register_screen.dart';
import 'package:alu_spark/features/auth/presentation/screens/otp_verification_screen.dart';

// --- Home & Core Navigation ---
import 'package:alu_spark/features/home/presentation/screens/home_shell.dart';

// --- Opportunities ---
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/features/opportunities/presentation/screens/discover_screen.dart';
import 'package:alu_spark/features/opportunities/presentation/screens/search_screen.dart';
import 'package:alu_spark/features/opportunities/presentation/screens/opportunity_detail_screen.dart';

class RouteNames {
  // Auth & Onboarding
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  
  // Core Navigation
  static const String home = '/home';
  static const String discover = '/discover';
  static const String search = '/search';
  static const String postOpportunity = '/post-opportunity';
  
  // Opportunities
  static const String opportunityDetail = '/opportunity-detail';
  
  // Profiles
  static const String studentProfile = '/student-profile';
  static const String studentProfileEdit = '/student-profile-edit';
  static const String startupProfile = '/startup-profile';
  static const String startupProfileEdit = '/startup-profile-edit';
  
  // Applications
  static const String applyOpportunity = '/apply-opportunity';
  static const String applicationTracking = '/application-tracking';
  static const String applicationsReceived = '/applications-received';
  
  // Admin
  static const String adminVerification = '/admin-verification';
  static const String adminUserManagement = '/admin-user-management';
  static const String adminAnalytics = '/admin-analytics';
  
  // Secondary Features
  static const String chatList = '/chat-list';
  static const String chatDetail = '/chat-detail';
  static const String notifications = '/notifications';
  static const String bookmarks = '/bookmarks';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ==========================================
      // --- Implemented Screens ---
      // ==========================================
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case RouteNames.otpVerification:
        return MaterialPageRoute(builder: (_) => const OtpVerificationScreen(email: 'student@alu.ac.ke'));
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeShell());
      case RouteNames.discover:
        return MaterialPageRoute(builder: (_) => const DiscoverScreen());
      case RouteNames.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case RouteNames.opportunityDetail:
        final opportunity = settings.arguments as Opportunity;
        return MaterialPageRoute(
          builder: (_) => OpportunityDetailScreen(opportunity: opportunity),
        );

      // ==========================================
      // --- Placeholder Routes ---
      // ==========================================
      case RouteNames.postOpportunity:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Post Opportunity'));
      case RouteNames.studentProfile:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Student Profile'));
      case RouteNames.studentProfileEdit:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Student Profile Edit'));
      case RouteNames.startupProfile:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Startup Profile'));
      case RouteNames.startupProfileEdit:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Startup Profile Edit'));
      case RouteNames.applyOpportunity:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Apply to Opportunity'));
      case RouteNames.applicationTracking:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Application Tracking'));
      case RouteNames.applicationsReceived:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Applications Received'));
      case RouteNames.adminVerification:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Admin Verification'));
      case RouteNames.adminUserManagement:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Admin User Management'));
      case RouteNames.adminAnalytics:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Admin Analytics'));
      case RouteNames.chatList:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Chat List'));
      case RouteNames.chatDetail:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Chat Detail'));
      case RouteNames.notifications:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Notifications'));
      case RouteNames.bookmarks:
        return MaterialPageRoute(builder: (_) => _placeholderScreen('Bookmarks'));

      // ==========================================
      // --- Fallback Route ---
      // ==========================================
      default:
        return MaterialPageRoute(
          builder: (_) => _placeholderScreen('Unknown Route: ${settings.name}'),
        );
    }
  }

  static Widget _placeholderScreen(String name) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Center(
        child: Text(
          'Coming soon: $name',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}