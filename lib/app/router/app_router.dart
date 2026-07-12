import 'package:flutter/material.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';

import 'package:alu_spark/features/auth/presentation/screens/splash_screen.dart';
import 'package:alu_spark/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:alu_spark/features/auth/presentation/screens/login_screen.dart';
import 'package:alu_spark/features/auth/presentation/screens/register_screen.dart';
import 'package:alu_spark/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:alu_spark/features/home/presentation/screens/home_shell.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/features/opportunities/presentation/screens/discover_screen.dart';
import 'package:alu_spark/features/opportunities/presentation/screens/search_screen.dart';
import 'package:alu_spark/features/opportunities/presentation/screens/opportunity_detail_screen.dart';
import 'package:alu_spark/features/opportunities/presentation/screens/post_opportunity_screen.dart';
import 'package:alu_spark/features/student_profile/presentation/screens/student_profile_screen.dart';
import 'package:alu_spark/features/student_profile/presentation/screens/student_profile_edit_screen.dart';
import 'package:alu_spark/features/startup_profile/presentation/screens/startup_profile_screen.dart';
import 'package:alu_spark/features/startup_profile/presentation/screens/startup_profile_edit_screen.dart';
import 'package:alu_spark/features/applications/presentation/screens/apply_opportunity_screen.dart';
import 'package:alu_spark/features/applications/presentation/screens/application_tracking_screen.dart';
import 'package:alu_spark/features/applications/presentation/screens/applications_received_screen.dart';
import 'package:alu_spark/features/admin_verification/presentation/screens/admin_verification_screen.dart';
import 'package:alu_spark/features/admin_user_management/presentation/screens/admin_user_management_screen.dart';
import 'package:alu_spark/features/admin_analytics/presentation/screens/admin_analytics_screen.dart';
import 'package:alu_spark/features/messaging/presentation/screens/chat_list_screen.dart';
import 'package:alu_spark/features/messaging/presentation/screens/chat_detail_screen.dart';
import 'package:alu_spark/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:alu_spark/features/bookmarks/presentation/screens/bookmarks_screen.dart';

class RouteNames {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home';
  static const String discover = '/discover';
  static const String search = '/search';
  static const String postOpportunity = '/post-opportunity';
  static const String opportunityDetail = '/opportunity-detail';
  static const String studentProfile = '/student-profile';
  static const String studentProfileEdit = '/student-profile-edit';
  static const String startupProfile = '/startup-profile';
  static const String startupProfileEdit = '/startup-profile-edit';
  static const String applyOpportunity = '/apply-opportunity';
  static const String applicationTracking = '/application-tracking';
  static const String applicationsReceived = '/applications-received';
  static const String adminVerification = '/admin-verification';
  static const String adminUserManagement = '/admin-user-management';
  static const String adminAnalytics = '/admin-analytics';
  static const String chatList = '/chat-list';
  static const String chatDetail = '/chat-detail';
  static const String notifications = '/notifications';
  static const String bookmarks = '/bookmarks';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash: return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.onboarding: return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case RouteNames.login: return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.register: return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case RouteNames.otpVerification:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(builder: (_) => OtpVerificationScreen(email: email));
      case RouteNames.home: return MaterialPageRoute(builder: (_) => const HomeShell());
      case RouteNames.discover: return MaterialPageRoute(builder: (_) => const DiscoverScreen());
      case RouteNames.search: return MaterialPageRoute(builder: (_) => const SearchScreen());
      case RouteNames.postOpportunity: return MaterialPageRoute(builder: (_) => const PostOpportunityScreen());
      
      case RouteNames.opportunityDetail:
        final opportunity = settings.arguments as Opportunity;
        return MaterialPageRoute(builder: (_) => OpportunityDetailScreen(opportunity: opportunity));
        
      case RouteNames.studentProfile: return MaterialPageRoute(builder: (_) => const StudentProfileScreen());
      case RouteNames.studentProfileEdit: return MaterialPageRoute(builder: (_) => const StudentProfileEditScreen());
      case RouteNames.startupProfile: return MaterialPageRoute(builder: (_) => const StartupProfileScreen());
      case RouteNames.startupProfileEdit: return MaterialPageRoute(builder: (_) => const StartupProfileEditScreen());
      
      case RouteNames.applyOpportunity:
        final opportunity = settings.arguments as Opportunity;
        return MaterialPageRoute(builder: (_) => ApplyOpportunityScreen(opportunity: opportunity));
        
      case RouteNames.applicationTracking: return MaterialPageRoute(builder: (_) => const ApplicationTrackingScreen());
      case RouteNames.applicationsReceived: return MaterialPageRoute(builder: (_) => const ApplicationsReceivedScreen());
      case RouteNames.adminVerification: return MaterialPageRoute(builder: (_) => const AdminVerificationScreen());
      case RouteNames.adminUserManagement: return MaterialPageRoute(builder: (_) => const AdminUserManagementScreen());
      case RouteNames.adminAnalytics: return MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen());
      case RouteNames.chatList: return MaterialPageRoute(builder: (_) => const ChatListScreen());
      
      case RouteNames.chatDetail:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            contactId: args['contactId'] ?? '',
            contactName: args['contactName'] ?? 'Unknown',
          ),
        );
        
      case RouteNames.notifications: return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case RouteNames.bookmarks: return MaterialPageRoute(builder: (_) => const BookmarksScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: AppColors.darkBlue,
            body: Center(
              child: Text(
                'Route not found: ${settings.name}',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
              ),
            ),
          ),
        );
    }
  }
}
