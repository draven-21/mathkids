import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Encouragement message widget with personalized feedback
class EncouragementMessageWidget extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const EncouragementMessageWidget({
    Key? key,
    required this.score,
    required this.totalQuestions,
  }) : super(key: key);

  String _getMessage() {
    final percentage = (score / totalQuestions) * 100;

    if (percentage == 100) {
      return 'Incredible! You got every single question right! You\'re a true math genius! 🌟';
    } else if (percentage >= 90) {
      return 'Wow! Almost perfect! Just a tiny bit more practice and you\'ll be unstoppable! 💪';
    } else if (percentage >= 80) {
      return 'Fantastic work! You really understand these math concepts. Keep up the great effort! 🎯';
    } else if (percentage >= 70) {
      return 'Good job! You\'re making solid progress. A little more practice will make you even better! 📚';
    } else if (percentage >= 60) {
      return 'Nice try! You\'re learning and improving. Keep practicing and you\'ll master these skills! 🚀';
    } else {
      return 'Great effort! Every quiz helps you learn. Keep practicing and you\'ll see amazing improvement! 💡';
    }
  }

  IconData _getIcon() {
    final percentage = (score / totalQuestions) * 100;

    if (percentage == 100) return Icons.emoji_events;
    if (percentage >= 80) return Icons.thumb_up;
    if (percentage >= 60) return Icons.trending_up;
    return Icons.lightbulb;
  }

  Color _getColor(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (score / totalQuestions) * 100;

    if (percentage == 100) return const Color(0xFFF39C12);
    if (percentage >= 80) return theme.colorScheme.primary;
    if (percentage >= 60) return const Color(0xFF27AE60);
    return const Color(0xFF9B59B6);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = _getMessage();
    final icon = _getIcon();
    final color = _getColor(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
