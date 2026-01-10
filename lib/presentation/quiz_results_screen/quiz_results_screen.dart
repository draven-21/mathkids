import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:vibration/vibration.dart';

import '../../services/supabase_service.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/celebration_animation_widget.dart';
import './widgets/encouragement_message_widget.dart';
import './widgets/score_display_widget.dart';
import './widgets/statistics_breakdown_widget.dart';

/// Quiz Results Screen - Celebrates student achievement with engaging feedback
class QuizResultsScreen extends StatefulWidget {
  const QuizResultsScreen({Key? key}) : super(key: key);

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _score = 0;
  int _totalQuestions = 0;
  int _pointsEarned = 0;
  int _currentStreak = 0;
  int _timeTaken = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _initializeResults();
  }

  Future<void> _initializeResults() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final prefs = await SharedPreferences.getInstance();

    // Get data from SharedPreferences (set by QuizScreen)
    final score = prefs.getInt('last_quiz_score') ?? 8;
    final total = prefs.getInt('last_quiz_total') ?? 10;
    final time = prefs.getInt('last_quiz_time') ?? 45;

    // Get current streak from Supabase
    int streak = 0;
    try {
      final user = await SupabaseService.instance.getCurrentUser();
      if (user != null) {
        streak = user.currentStreak;
        // Update SharedPreferences with latest streak
        await prefs.setInt('current_streak', streak);
      } else {
        streak = prefs.getInt('current_streak') ?? 0;
      }
    } catch (e) {
      streak = prefs.getInt('current_streak') ?? 0;
    }

    setState(() {
      _score = score;
      _totalQuestions = total;
      _pointsEarned = score * 10;
      _currentStreak = streak;
      _timeTaken = time;
      _isLoading = false;
    });

    _fadeController.forward();
    _triggerCelebrationHaptics();
  }

  Future<void> _triggerCelebrationHaptics() async {
    final percentage = (_score / _totalQuestions) * 100;

    if (await Vibration.hasVibrator() ?? false) {
      if (percentage == 100) {
        Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 100]);
      } else if (percentage >= 80) {
        Vibration.vibrate(pattern: [0, 100, 50, 100]);
      } else {
        Vibration.vibrate(duration: 100);
      }
    }

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _saveResultsToDatabase() async {
    final prefs = await SharedPreferences.getInstance();

    final totalPoints = (prefs.getInt('total_points') ?? 0) + _pointsEarned;
    await prefs.setInt('total_points', totalPoints);

    final quizzesCompleted = (prefs.getInt('quizzes_completed') ?? 0) + 1;
    await prefs.setInt('quizzes_completed', quizzesCompleted);

    final lastQuizDate = DateTime.now().toIso8601String();
    await prefs.setString('last_quiz_date', lastQuizDate);
  }

  void _handlePlayAgain() {
    _saveResultsToDatabase();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed('/quiz-screen');
  }

  void _handleViewLeaderboard() {
    _saveResultsToDatabase();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed('/leaderboard-screen');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            CelebrationAnimationWidget(
              score: _score,
              totalQuestions: _totalQuestions,
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 2.h),
                      ScoreDisplayWidget(
                        score: _score,
                        totalQuestions: _totalQuestions,
                      ),
                      SizedBox(height: 3.h),
                      StatisticsBreakdownWidget(
                        correctAnswers: _score,
                        totalQuestions: _totalQuestions,
                        pointsEarned: _pointsEarned,
                        currentStreak: _currentStreak,
                      ),
                      SizedBox(height: 3.h),
                      AchievementBadgesWidget(
                        score: _score,
                        totalQuestions: _totalQuestions,
                        timeTaken: _timeTaken,
                        currentStreak: _currentStreak,
                      ),
                      SizedBox(height: 3.h),
                      EncouragementMessageWidget(
                        score: _score,
                        totalQuestions: _totalQuestions,
                      ),
                      SizedBox(height: 4.h),
                      ActionButtonsWidget(
                        onPlayAgain: _handlePlayAgain,
                        onViewLeaderboard: _handleViewLeaderboard,
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
