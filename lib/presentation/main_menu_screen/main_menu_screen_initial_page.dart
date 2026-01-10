import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/action_card_widget.dart';
import './widgets/pixel_mascot_widget.dart';

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
      // Try to get user from Supabase
      final user = await SupabaseService.instance.getCurrentUser();
      
      if (user != null) {
        setState(() {
          studentName = user.name;
          currentStreak = user.currentStreak;
          totalPoints = user.totalPoints;
          currentLevel = user.currentLevel;
        });
        
        // Update SharedPreferences for offline access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('student_name', user.name);
        await prefs.setInt('current_streak', user.currentStreak);
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          studentName = prefs.getString('student_name') ?? 'Student';
          currentStreak = prefs.getInt('current_streak') ?? 0;
        });
      }
    } catch (e) {
      // Fallback to SharedPreferences on error
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
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Choose Your Challenge',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 3.h),
            _buildDifficultyOption(
              context: context,
              title: 'Addition',
              icon: 'add',
              color: const Color(0xFF27AE60),
              operation: 'addition',
            ),
            SizedBox(height: 1.5.h),
            _buildDifficultyOption(
              context: context,
              title: 'Subtraction',
              icon: 'remove',
              color: const Color(0xFFF39C12),
              operation: 'subtraction',
            ),
            SizedBox(height: 1.5.h),
            _buildDifficultyOption(
              context: context,
              title: 'Multiplication',
              icon: 'close',
              color: const Color(0xFF9B59B6),
              operation: 'multiplication',
            ),
            SizedBox(height: 1.5.h),
            _buildDifficultyOption(
              context: context,
              title: 'Division',
              icon: 'horizontal_rule',
              color: const Color(0xFFE74C3C),
              operation: 'division',
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyOption({
    required BuildContext context,
    required String title,
    required String icon,
    required Color color,
    required String operation,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed('/quiz-screen', arguments: {'operation': operation});
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 3),
          ),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: icon,
                    color: theme.colorScheme.surface,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $studentName!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Ready to learn today?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true)
                              .pushNamed('/settings-screen');
                        },
                        icon: CustomIconWidget(
                          iconName: 'settings',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 28,
                        ),
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
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
                  GestureDetector(
                    onLongPress: _showDifficultySelection,
                    child: ActionCardWidget(
                      title: 'Start Quiz',
                      subtitle: 'Test your math skills',
                      icon: 'play_arrow',
                      color: const Color(0xFF4A90E2),
                      badge: currentStreak > 0
                          ? '$currentStreak day streak! 🔥'
                          : null,
                      onTap: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed('/quiz-screen');
                      },
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ActionCardWidget(
                    title: 'View Leaderboard',
                    subtitle: 'See top performers',
                    icon: 'emoji_events',
                    color: const Color(0xFFF39C12),
                    badge: 'Top 3 this week',
                    onTap: () {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed('/leaderboard-screen');
                    },
                  ),
                  SizedBox(height: 2.h),
                  ActionCardWidget(
                    title: 'My Progress',
                    subtitle: 'Track your achievements',
                    icon: 'trending_up',
                    color: const Color(0xFF27AE60),
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
    );
  }
}
