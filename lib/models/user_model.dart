import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String name;
  final String avatarInitials;
  final Color avatarColor;
  final int totalPoints;
  final int currentLevel;
  final int currentStreak;
  final int longestStreak;
  final int quizzesCompleted;
  final int totalCorrectAnswers;
  final int totalQuestionsAttempted;
  final DateTime? lastQuizDate;
  final DateTime? lastActivityDate;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.avatarInitials,
    this.avatarColor = const Color(0xFF4A90E2),
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.quizzesCompleted = 0,
    this.totalCorrectAnswers = 0,
    this.totalQuestionsAttempted = 0,
    this.lastQuizDate,
    this.lastActivityDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get averageScore {
    if (totalQuestionsAttempted == 0) return 0;
    return ((totalCorrectAnswers / totalQuestionsAttempted) * 100).round();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarInitials: json['avatar_initials'] as String,
      avatarColor: _parseColor(json['avatar_color'] as String?),
      totalPoints: json['total_points'] as int? ?? 0,
      currentLevel: json['current_level'] as int? ?? 1,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      quizzesCompleted: json['quizzes_completed'] as int? ?? 0,
      totalCorrectAnswers: json['total_correct_answers'] as int? ?? 0,
      totalQuestionsAttempted: json['total_questions_attempted'] as int? ?? 0,
      lastQuizDate: json['last_quiz_date'] != null
          ? DateTime.parse(json['last_quiz_date'] as String)
          : null,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_initials': avatarInitials,
      'avatar_color': _colorToHex(avatarColor),
      'total_points': totalPoints,
      'current_level': currentLevel,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'quizzes_completed': quizzesCompleted,
      'total_correct_answers': totalCorrectAnswers,
      'total_questions_attempted': totalQuestionsAttempted,
      'last_quiz_date': lastQuizDate?.toIso8601String().split('T')[0],
      'last_activity_date': lastActivityDate?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'avatar_initials': avatarInitials,
      'avatar_color': _colorToHex(avatarColor),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? avatarInitials,
    Color? avatarColor,
    int? totalPoints,
    int? currentLevel,
    int? currentStreak,
    int? longestStreak,
    int? quizzesCompleted,
    int? totalCorrectAnswers,
    int? totalQuestionsAttempted,
    DateTime? lastQuizDate,
    DateTime? lastActivityDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      avatarColor: avatarColor ?? this.avatarColor,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalQuestionsAttempted: totalQuestionsAttempted ?? this.totalQuestionsAttempted,
      lastQuizDate: lastQuizDate ?? this.lastQuizDate,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      createdAt: createdAt,
    );
  }

  static Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFF4A90E2);
    }
    final hex = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
