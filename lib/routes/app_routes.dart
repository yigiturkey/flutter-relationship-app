import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/analysis/instant_analysis_screen.dart';
import '../screens/analysis/general_analysis_screen.dart';
import '../screens/analysis/couple_mode_screen.dart';
import '../screens/analysis/future_report_screen.dart';
import '../screens/training/training_list_screen.dart';
import '../screens/games/games_home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/store/store_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String instantAnalysis = '/instant-analysis';
  static const String generalAnalysis = '/general-analysis';
  static const String coupleMode = '/couple-mode';
  static const String futureReport = '/future-report';
  static const String training = '/training';
  static const String games = '/games';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String store = '/store';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      dashboard: (context) => const DashboardScreen(),
      instantAnalysis: (context) => const InstantAnalysisScreen(),
      generalAnalysis: (context) => const GeneralAnalysisScreen(),
      coupleMode: (context) => const CoupleModeScreen(),
      futureReport: (context) => const FutureReportScreen(),
      training: (context) => const TrainingListScreen(),
      games: (context) => const GamesHomeScreen(),
      profile: (context) => const ProfileScreen(),
      settings: (context) => const SettingsScreen(),
      store: (context) => const StoreScreen(),
      notifications: (context) => const NotificationsScreen(),
    };
  }
}