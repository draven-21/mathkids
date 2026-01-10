import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Achievement badges widget displaying earned milestones
class AchievementBadgesWidget extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int timeTaken;
  final int currentStreak;

  const AchievementBadgesWidget({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
    required this.currentStreak,
  }) : super(key: key);

  @override
  State<AchievementBadgesWidget> createState() =>
      _AchievementBadgesWidgetState();
}

class _AchievementBadgesWidgetState extends State<AchievementBadgesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Achievement> _achievements;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _achievements = _getAchievements();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Achievement> _getAchievements() {
    final achievements = <Achievement>[];

    if (widget.score == widget.totalQuestions) {
      achievements.add(
        Achievement(
          icon: 'emoji_events',
          title: 'Perfect Score',
          description: 'Answered all questions correctly!',
          color: const Color(0xFFF39C12),
        ),
      );
    }

    if (widget.timeTaken < 60) {
      achievements.add(
        Achievement(
          icon: 'flash_on',
          title: 'Speed Demon',
          description: 'Completed in under 1 minute!',
          color: const Color(0xFF4A90E2),
        ),
      );
    }

    if (widget.currentStreak >= 7) {
      achievements.add(
        Achievement(
          icon: 'local_fire_department',
          title: 'Streak Master',
          description: '7+ day learning streak!',
          color: const Color(0xFFE74C3C),
        ),
      );
    }

    if (widget.score >= (widget.totalQuestions * 0.8).ceil()) {
      achievements.add(
        Achievement(
          icon: 'star',
          title: 'Math Champion',
          description: 'Scored 80% or higher!',
          color: const Color(0xFF9B59B6),
        ),
      );
    }

    return achievements;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Achievements Unlocked!',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 16.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: _achievements.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              return _buildAchievementCard(
                context: context,
                achievement: _achievements[index],
                delay: index * 200,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard({
    required BuildContext context,
    required Achievement achievement,
    required int delay,
  }) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final delayedProgress =
            (_controller.value * 1000 - delay).clamp(0.0, 800.0) / 800.0;
        final scale = Curves.elasticOut.transform(delayedProgress);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 35.w,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: achievement.color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: achievement.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: achievement.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: achievement.icon,
                    color: achievement.color,
                    size: 32,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  achievement.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: achievement.color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  achievement.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Achievement {
  final String icon;
  final String title;
  final String description;
  final Color color;

  Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
