import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/user_model.dart';
import '../../models/skill_progress_model.dart';
import '../../models/achievement_model.dart';
import '../../models/daily_activity_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/animated_math_background.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/avatar_picker_widget.dart';
import '../../widgets/user_avatar_widget.dart';
import '../../services/avatar_state_manager.dart';
import './widgets/achievement_badge_widget.dart';
import './widgets/progress_chart_widget.dart';
import './widgets/skill_progress_widget.dart';
import './widgets/stats_card_widget.dart';
import './widgets/weekly_activity_widget.dart';

/// Progress Tracking Screen - Modern design with animated background
/// Displays comprehensive learning statistics and achievements
class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({Key? key}) : super(key: key);

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  bool _isLoading = true;

  // User info
  String studentName = '';
  String? avatarUrl;
  String avatarInitials = '';
  Color avatarColor = const Color(0xFF4A90E2);
  int totalPoints = 0;
  int currentLevel = 1;
  int currentStreak = 0;
  int quizzesCompleted = 0;
  double averageScore = 0.0;
  String? _currentUserId;

  // Activity and performance data
  Map<DateTime, int> activityData = {};

  // Weekly scores
  List<Map<String, dynamic>> weeklyScores = [];

  // Skills data
  List<Map<String, dynamic>> skillsData = [];

  // Achievements data
  List<Map<String, dynamic>> achievementsData = [];

  @override
  void initState() {
    super.initState();
    _loadProgressData();
    // Listen to avatar changes
    AvatarStateManager().addListener(_onAvatarChanged);
  }

  @override
  void dispose() {
    AvatarStateManager().removeListener(_onAvatarChanged);
    super.dispose();
  }

  void _onAvatarChanged() {
    // Update avatar when global state changes
    if (mounted && _currentUserId != null) {
      final currentAvatar = AvatarStateManager().currentAvatarUrl;
      final currentUser = AvatarStateManager().currentUserId;

      // Only update if it's for the current user
      if (currentUser == _currentUserId && currentAvatar != avatarUrl) {
        setState(() {
          avatarUrl = currentAvatar;
        });
        debugPrint('ProgressTrackingScreen: Avatar updated from state manager');
      }
    }
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);

    try {
      final userId = await SupabaseService.instance.getCurrentUserId();
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final progressData = await SupabaseService.instance.getUserProgressData(
        userId,
      );

      final user = progressData['user'] as UserModel?;
      final skills = progressData['skills'] as List<SkillProgressModel>;
      final activity = progressData['activityMap'] as Map<DateTime, int>;
      final weekly = progressData['weeklyScores'] as List<WeeklyScoreModel>;
      final userAchievements =
          progressData['userAchievements'] as List<UserAchievementModel>;
      final allAchievements =
          progressData['allAchievements'] as List<AchievementModel>;

      if (user != null) {
        setState(() {
          _currentUserId = userId;
          studentName = user.name;
          avatarUrl = user.avatarUrl;
          avatarInitials = user.avatarInitials;
          avatarColor = user.avatarColor;
          currentStreak = user.currentStreak;
          totalPoints = user.totalPoints;
          currentLevel = user.currentLevel;
          quizzesCompleted = user.quizzesCompleted;
          averageScore = user.averageScore.toDouble();

          // Initialize global avatar state
          AvatarStateManager().initializeAvatar(user.avatarUrl, userId);

          activityData = activity;

          weeklyScores = weekly
              .map((w) => {"day": w.day, "score": w.averageScore.round()})
              .toList();

          // Ensure we have all 7 days
          if (weeklyScores.isEmpty) {
            weeklyScores = [
              {"day": "Mon", "score": 0},
              {"day": "Tue", "score": 0},
              {"day": "Wed", "score": 0},
              {"day": "Thu", "score": 0},
              {"day": "Fri", "score": 0},
              {"day": "Sat", "score": 0},
              {"day": "Sun", "score": 0},
            ];
          }

          skillsData = skills
              .map(
                (s) => {
                  "name":
                      s.skillName[0].toUpperCase() + s.skillName.substring(1),
                  "icon": s.iconName,
                  "progress": s.progress,
                  "color": s.skillColor,
                },
              )
              .toList();

          // If no skills data, show defaults with 0 progress
          if (skillsData.isEmpty) {
            skillsData = [
              {
                "name": "Addition",
                "icon": "add_circle",
                "progress": 0.0,
                "color": const Color(0xFF4A90E2),
              },
              {
                "name": "Subtraction",
                "icon": "remove_circle",
                "progress": 0.0,
                "color": const Color(0xFFF39C12),
              },
              {
                "name": "Multiplication",
                "icon": "close",
                "progress": 0.0,
                "color": const Color(0xFF27AE60),
              },
              {
                "name": "Division",
                "icon": "horizontal_rule",
                "progress": 0.0,
                "color": const Color(0xFF9B59B6),
              },
            ];
          }

          // Build achievements data
          final unlockedIds = userAchievements
              .map((a) => a.achievementId)
              .toSet();
          achievementsData = allAchievements.map((a) {
            final userAchievement = userAchievements.firstWhere(
              (ua) => ua.achievementId == a.id,
              orElse: () => UserAchievementModel(
                id: '',
                oderId: userId,
                achievementId: a.id,
                unlockedAt: DateTime.now(),
              ),
            );
            final isUnlocked = unlockedIds.contains(a.id);
            return {
              "name": a.name,
              "description": a.description,
              "icon": a.iconName,
              "color": a.badgeColor,
              "unlockDate": isUnlocked
                  ? DateFormat('MMM d, yyyy').format(userAchievement.unlockedAt)
                  : "",
              "isUnlocked": isUnlocked,
            };
          }).toList();

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading progress data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Progress', style: theme.appBarTheme.titleTextStyle),
        centerTitle: true,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color:
                theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushReplacementNamed('/main-menu-screen');
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // Animated math background
          Positioned.fill(
            child: AnimatedMathBackground(
              symbolColor: theme.colorScheme.primary,
              opacity: 0.04,
              symbolCount: 20,
              animationSpeed: 0.5,
            ),
          ),

          // Main content
          SafeArea(
            child: _isLoading
                ? Center(
                    child: GlassCard(
                      padding: EdgeInsets.all(5.w),
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                        strokeWidth: 3,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStudentHeader(theme),
                          SizedBox(height: 3.h),
                          _buildStatsOverview(theme),
                          SizedBox(height: 3.h),
                          WeeklyActivityWidget(
                            activityData: activityData,
                            currentStreak: currentStreak,
                          ),
                          SizedBox(height: 3.h),
                          _buildSkillsMastery(theme),
                          SizedBox(height: 3.h),
                          ProgressChartWidget(weeklyScores: weeklyScores),
                          SizedBox(height: 3.h),
                          _buildAchievements(theme),
                          SizedBox(height: 3.h),
                          _buildMotivationalMessage(theme),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentHeader(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.w),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.brightness == Brightness.dark
                  ? [
                      theme.colorScheme.primary.withOpacity(0.3),
                      theme.colorScheme.primary.withOpacity(0.15),
                      theme.colorScheme.secondary.withOpacity(0.2),
                    ]
                  : [
                      theme.colorScheme.primary.withOpacity(0.6),
                      theme.colorScheme.primary.withOpacity(0.4),
                      theme.colorScheme.secondary.withOpacity(0.3),
                    ],
            ),
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final userId = await SupabaseService.instance
                      .getCurrentUserId();
                  if (userId != null && mounted) {
                    await showAvatarPicker(
                      context: context,
                      userId: userId,
                      onAvatarUploaded: (newAvatarUrl) {
                        // Avatar is automatically updated via AvatarStateManager
                        // No need to manually setState or reload data
                        debugPrint(
                          'Progress: Avatar upload callback received: $newAvatarUrl',
                        );
                      },
                    );
                  }
                },
                child: Stack(
                  children: [
                    ResponsiveUserAvatar(
                      avatarUrl: avatarUrl,
                      initials: avatarInitials,
                      backgroundColor: avatarColor,
                      sizePercentage: 20,
                      borderWidth: 3,
                      borderColor: theme.colorScheme.onPrimary.withOpacity(0.3),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.onPrimary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 3.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'military_tech',
                                color: theme.colorScheme.onPrimary,
                                size: 18,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Level $currentLevel',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'stars',
                                color: theme.colorScheme.onPrimary,
                                size: 18,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                '$totalPoints pts',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            'Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatsCardWidget(
              title: 'Quizzes Completed',
              value: '$quizzesCompleted',
              iconName: 'quiz',
              iconColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.primary,
            ),
            StatsCardWidget(
              title: 'Average Score',
              value: '$averageScore%',
              iconName: 'trending_up',
              iconColor: theme.colorScheme.tertiary,
              backgroundColor: theme.colorScheme.tertiary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsMastery(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            'Skills Mastery',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        ...skillsData.map((skill) {
          return SkillProgressWidget(
            skillName: skill['name'] as String,
            iconName: skill['icon'] as String,
            progress: skill['progress'] as double,
            skillColor: skill['color'] as Color,
          );
        }),
      ],
    );
  }

  Widget _buildAchievements(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            'Achievements',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 28.w,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: achievementsData.length,
            itemBuilder: (context, index) {
              final achievement = achievementsData[index];
              return AchievementBadgeWidget(
                badgeName: achievement['name'] as String,
                description: achievement['description'] as String,
                iconName: achievement['icon'] as String,
                badgeColor: achievement['color'] as Color,
                unlockDate: achievement['unlockDate'] as String,
                isUnlocked: achievement['isUnlocked'] as bool,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalMessage(ThemeData theme) {
    return GlassCard(
      padding: EdgeInsets.all(4.w),
      borderRadius: 4.w,
      opacity: 0.15,
      borderColor: theme.colorScheme.tertiary.withOpacity(0.3),
      borderWidth: 2,
      gradientColors: theme.brightness == Brightness.dark
          ? [
              theme.colorScheme.tertiary.withOpacity(0.15),
              theme.colorScheme.tertiary.withOpacity(0.08),
            ]
          : [
              theme.colorScheme.tertiary.withOpacity(0.2),
              theme.colorScheme.tertiary.withOpacity(0.1),
            ],
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary,
              borderRadius: BorderRadius.circular(3.w),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.tertiary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.lightbulb,
              color: theme.colorScheme.onPrimary,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep Going!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'You\'re doing great! Practice more to improve your skills.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
