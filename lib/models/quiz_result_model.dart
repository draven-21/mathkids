class QuizResultModel {
  final String? id;
  final String userId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int pointsEarned;
  final int timeTakenSeconds;
  final String? operationType;
  final DateTime completedAt;

  QuizResultModel({
    this.id,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.pointsEarned,
    this.timeTakenSeconds = 0,
    this.operationType,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  int get percentage => totalQuestions > 0
      ? ((correctAnswers / totalQuestions) * 100).round()
      : 0;

  bool get isPerfectScore => correctAnswers == totalQuestions;

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      score: json['score'] as int,
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      pointsEarned: json['points_earned'] as int,
      timeTakenSeconds: json['time_taken_seconds'] as int? ?? 0,
      operationType: json['operation_type'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'points_earned': pointsEarned,
      'time_taken_seconds': timeTakenSeconds,
      'operation_type': operationType,
    };
  }
}
