import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import '../../widgets/animated_math_background.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/modern_card.dart';
import './widgets/pixel_mascot_widget.dart';

/// Main menu screen with modern design, animated background, and floating action cards
class MainMenuScreenInitialPage extends StatefulWidget {
  const MainMenuScreenInitialPage({Key? key}) : super(key: key);

  @override
  State<MainMenuScreenInitialPage> createState() =>
      _MainMenuScreenInitialPageState();
}

class _MainMenuScreenInitialPageState extends State<MainMenuScreenInitialPage>
    with SingleTickerProviderStateMixin {
  String studentName = '';
  int currentStreak = 0;
  int totalPoints = 0;
  int currentLevel = 1;
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadStudentData() async {
    try {
      final user = await SupabaseService.instance.getCurrentUser();

      if (user != null) {
        setState(() {
          studentName = user.name;
          currentStreak = user.currentStreak;
          totalPoints = user.totalPoints;
          currentLevel = user.currentLevel;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('student_name', user.name);
        await prefs.setInt('current_streak', user.currentStreak);
      } else {
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          studentName = prefs.getString('student_name') ?? 'Student';
          currentStreak = prefs.getInt('current_streak') ?? 0;
        });
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        studentName = prefs.getString('student_name') ?? 'Student';
        currentStreak = prefs.getInt('current_streak') ?? 0;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showDifficultySelection() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Choose Your Challenge',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 3.h),
                _buildDifficultyOption(
                  context: context,
                  title: 'Addition',
                  subtitle: 'Practice adding numbers',
                  icon: Icons.add_circle_outline,
                  color: const Color(0xFF27AE60),
                  operation: 'addition',
                ),
                SizedBox(height: 2.h),
                _buildDifficultyOption(
                  context: context,
                  title: 'Subtraction',
                  subtitle: 'Practice subtracting numbers',
                  icon: Icons.remove_circle_outline,
                  color: const Color(0xFFF39C12),
                  operation: 'subtraction',
                ),
                SizedBox(height: 2.h),
                _buildDifficultyOption(
                  context: context,
                  title: 'Multiplication',
                  subtitle: 'Practice multiplying numbers',
                  icon: Icons.close,
                  color: const Color(0xFF9B59B6),
                  operation: 'multiplication',
                ),
                SizedBox(height: 2.h),
                _buildDifficultyOption(
                  context: context,
                  title: 'Division',
                  subtitle: 'Practice dividing numbers',
                  icon: Icons.horizontal_rule,
                  color: const Color(0xFFE74C3C),
                  operation: 'division',
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String operation,
  }) {
    final theme = Theme.of(context);
    return ModernCard(
      onTap: () {
        Navigator.pop(context);
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed('/quiz-screen', arguments: {'operation': operation});
      },
      padding: EdgeInsets.all(4.w),
      elevation: 3,
      child: Row(
        children: [
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3.5.w),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 7.w),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: color, size: 5.w),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated math background
          Positioned.fill(
            child: AnimatedMathBackground(
              symbolColor: theme.colorScheme.primary,
              opacity: 0.04,
              symbolCount: 20,
              animationSpeed: 0.6,
            ),
          ),

          // Main content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadStudentData,
              color: theme.colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, $studentName! 👋',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  'Ready to learn today?',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Settings button
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(3.w),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pushNamed('/settings-screen');
                              },
                              icon: CustomIconWidget(
                                iconName: 'settings',
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                              tooltip: 'Settings',
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 3.h),

                      // Mascot with bounce animation
                      AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -_bounceAnimation.value),
                            child: child,
                          );
                        },
                        child: const PixelMascotWidget(),
                      ),

                      SizedBox(height: 4.h),

                      // Stats row
                      if (currentStreak > 0 || totalPoints > 0)
                        Row(
                          children: [
                            if (currentStreak > 0)
                              Expanded(
                                child: ModernCard(
                                  padding: EdgeInsets.all(3.w),
                                  elevation: 3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(2.w),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE74C3C),
                                          borderRadius: BorderRadius.circular(
                                            2.w,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFFE74C3C,
                                              ).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.local_fire_department,
                                          color: Colors.white,
                                          size: 5.w,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$currentStreak days',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                          ),
                                          Text(
                                            'Streak',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (currentStreak > 0 && totalPoints > 0)
                              SizedBox(width: 3.w),
                            if (totalPoints > 0)
                              Expanded(
                                child: ModernCard(
                                  padding: EdgeInsets.all(3.w),
                                  elevation: 3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(2.w),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.secondary,
                                          borderRadius: BorderRadius.circular(
                                            2.w,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorScheme.secondary
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.stars,
                                          color: Colors.white,
                                          size: 5.w,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$totalPoints',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                          ),
                                          Text(
                                            'Points',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),

                      if (currentStreak > 0 || totalPoints > 0)
                        SizedBox(height: 3.h),

                      // Main action cards
                      FloatingActionCard(
                        title: 'Start Quiz',
                        subtitle: 'Test your math skills',
                        icon: Icons.play_circle_filled,
                        accentColor: theme.colorScheme.primary,
                        badge: currentStreak > 0
                            ? '$currentStreak day streak! 🔥'
                            : 'Let\'s begin!',
                        onTap: () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed('/quiz-screen');
                        },
                      ),

                      FloatingActionCard(
                        title: 'Practice Mode',
                        subtitle: 'Choose your operation',
                        icon: Icons.school,
                        accentColor: const Color(0xFF9B59B6),
                        badge: 'Pick a challenge',
                        onTap: _showDifficultySelection,
                      ),

                      FloatingActionCard(
                        title: 'Leaderboard',
                        subtitle: 'See top performers',
                        icon: Icons.emoji_events,
                        accentColor: theme.colorScheme.secondary,
                        badge: 'Compete with friends',
                        onTap: () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed('/leaderboard-screen');
                        },
                      ),

                      FloatingActionCard(
                        title: 'My Progress',
                        subtitle: 'Track your achievements',
                        icon: Icons.trending_up,
                        accentColor: const Color(0xFF27AE60),
                        onTap: () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed('/progress-tracking-screen');
                        },
                      ),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
