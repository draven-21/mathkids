import 'package:flutter/material.dart';

class SkillProgressModel {
  final String? id;
  final String userId;
  final String skillName;
  final int totalAttempted;
  final int totalCorrect;
  final double masteryPercentage;

  SkillProgressModel({
    this.id,
    required this.userId,
    required this.skillName,
    this.totalAttempted = 0,
    this.totalCorrect = 0,
    this.masteryPercentage = 0.0,
  });

  double get progress => masteryPercentage / 100;

  Color get skillColor {
    switch (skillName.toLowerCase()) {
      case 'addition':
        return const Color(0xFF4A90E2);
      case 'subtraction':
        return const Color(0xFFF39C12);
      case 'multiplication':
        return const Color(0xFF27AE60);
      case 'division':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF4A90E2);
    }
  }

  String get iconName {
    switch (skillName.toLowerCase()) {
      case 'addition':
        return 'add_circle';
      case 'subtraction':
        return 'remove_circle';
      case 'multiplication':
        return 'close';
      case 'division':
        return 'horizontal_rule';
      default:
        return 'help';
    }
  }

  factory SkillProgressModel.fromJson(Map<String, dynamic> json) {
    return SkillProgressModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      skillName: json['skill_name'] as String,
      totalAttempted: json['total_attempted'] as int? ?? 0,
      totalCorrect: json['total_correct'] as int? ?? 0,
      masteryPercentage: (json['mastery_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'skill_name': skillName,
      'total_attempted': totalAttempted,
      'total_correct': totalCorrect,
      'mastery_percentage': masteryPercentage,
    };
  }

  SkillProgressModel copyWith({
    int? totalAttempted,
    int? totalCorrect,
    double? masteryPercentage,
  }) {
    return SkillProgressModel(
      id: id,
      userId: userId,
      skillName: skillName,
      totalAttempted: totalAttempted ?? this.totalAttempted,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      masteryPercentage: masteryPercentage ?? this.masteryPercentage,
    );
  }
}
