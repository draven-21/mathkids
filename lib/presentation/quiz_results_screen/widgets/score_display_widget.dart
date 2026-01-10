import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Score display widget with animated counter and performance rating
class ScoreDisplayWidget extends StatefulWidget {
  final int score;
  final int totalQuestions;

  const ScoreDisplayWidget({
    Key? key,
    required this.score,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  State<ScoreDisplayWidget> createState() => _ScoreDisplayWidgetState();
}

class _ScoreDisplayWidgetState extends State<ScoreDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scoreAnimation = IntTween(
      begin: 0,
      end: widget.score,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getPerformanceRating() {
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage == 100) return 'Math Superstar!';
    if (percentage >= 80) return 'Great Job!';
    if (percentage >= 60) return 'Good Work!';
    return 'Keep Practicing!';
  }

  Color _getRatingColor(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (widget.score / widget.totalQuestions) * 100;
    if (percentage == 100) return const Color(0xFFF39C12);
    if (percentage >= 80) return theme.colorScheme.primary;
    if (percentage >= 60) return const Color(0xFF27AE60);
    return const Color(0xFF9B59B6);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rating = _getPerformanceRating();
    final ratingColor = _getRatingColor(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            rating,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: ratingColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${_scoreAnimation.value}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: ratingColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 60.sp,
                    ),
                  ),
                  Text(
                    ' / ${widget.totalQuestions}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 1.h),
          Text(
            'Questions Correct',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
