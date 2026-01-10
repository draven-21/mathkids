class DailyActivityModel {
  final String? id;
  final String userId;
  final DateTime activityDate;
  final int quizzesCompleted;
  final int pointsEarned;
  final double averageScore;

  DailyActivityModel({
    this.id,
    required this.userId,
    required this.activityDate,
    this.quizzesCompleted = 0,
    this.pointsEarned = 0,
    this.averageScore = 0.0,
  });

  factory DailyActivityModel.fromJson(Map<String, dynamic> json) {
    return DailyActivityModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      activityDate: DateTime.parse(json['activity_date'] as String),
      quizzesCompleted: json['quizzes_completed'] as int? ?? 0,
      pointsEarned: json['points_earned'] as int? ?? 0,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'activity_date': activityDate.toIso8601String().split('T')[0],
      'quizzes_completed': quizzesCompleted,
      'points_earned': pointsEarned,
      'average_score': averageScore,
    };
  }
}

class WeeklyScoreModel {
  final String day;
  final double averageScore;
  final int quizzesCount;

  WeeklyScoreModel({
    required this.day,
    required this.averageScore,
    this.quizzesCount = 0,
  });

  factory WeeklyScoreModel.fromJson(Map<String, dynamic> json) {
    return WeeklyScoreModel(
      day: json['day_name'] as String? ?? json['day'] as String? ?? '',
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
      quizzesCount: json['quizzes_count'] as int? ?? 0,
    );
  }
}
