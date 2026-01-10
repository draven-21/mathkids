import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/leaderboard_screen/leaderboard_screen.dart';
import '../presentation/name_entry_screen/name_entry_screen.dart';
import '../presentation/progress_tracking_screen/progress_tracking_screen.dart';
import '../presentation/quiz_results_screen/quiz_results_screen.dart';
import '../presentation/main_menu_screen/main_menu_screen.dart';
import '../presentation/quiz_screen/quiz_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String leaderboard = '/leaderboard-screen';
  static const String nameEntry = '/name-entry-screen';
  static const String progressTracking = '/progress-tracking-screen';
  static const String quizResults = '/quiz-results-screen';
  static const String mainMenu = '/main-menu-screen';
  static const String quiz = '/quiz-screen';
  static const String settings = '/settings-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    leaderboard: (context) => const LeaderboardScreen(),
    nameEntry: (context) => const NameEntryScreen(),
    progressTracking: (context) => const ProgressTrackingScreen(),
    quizResults: (context) => const QuizResultsScreen(),
    mainMenu: (context) => const MainMenuScreen(),
    quiz: (context) => const QuizScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
