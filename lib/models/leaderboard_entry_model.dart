import 'package:flutter/material.dart';

class LeaderboardEntryModel {
  final String id;
  final int rank;
  final String name;
  final int points;
  final String avatarInitials;
  final Color avatarColor;
  final String? avatarUrl;
  final int quizzesCompleted;
  final int averageScore;
  final int currentStreak;
  final bool isCurrentUser;

  LeaderboardEntryModel({
    required this.id,
    required this.rank,
    required this.name,
    required this.points,
    required this.avatarInitials,
    this.avatarColor = const Color(0xFF4A90E2),
    this.avatarUrl,
    this.quizzesCompleted = 0,
    this.averageScore = 0,
    this.currentStreak = 0,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntryModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    return LeaderboardEntryModel(
      id: json['id'] as String,
      rank: json['rank'] as int? ?? 0,
      name: json['name'] as String,
      points: json['total_points'] as int? ?? 0,
      avatarInitials: json['avatar_initials'] as String? ?? '',
      avatarColor: _parseColor(json['avatar_color'] as String?),
      avatarUrl: json['avatar_url'] as String?,
      quizzesCompleted: json['quizzes_completed'] as int? ?? 0,
      averageScore: (json['average_score'] as num?)?.toInt() ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      isCurrentUser: currentUserId != null && json['id'] == currentUserId,
    );
  }

  Map<String, dynamic> toDisplayMap() {
    return {
      "id": id,
      "rank": rank,
      "name": name,
      "points": points,
      "avatar": avatarInitials,
      "color": avatarColor,
      "avatarUrl": avatarUrl,
      "quizzesCompleted": quizzesCompleted,
      "averageScore": averageScore,
      "currentStreak": currentStreak,
      "isCurrentUser": isCurrentUser,
    };
  }

  static Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFF4A90E2);
    }
    final hex = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
