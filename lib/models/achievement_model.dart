import 'package:flutter/material.dart';

class AchievementModel {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final Color badgeColor;
  final String requirementType;
  final int requirementValue;

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.badgeColor,
    required this.requirementType,
    required this.requirementValue,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['icon_name'] as String,
      badgeColor: _parseColor(json['badge_color'] as String),
      requirementType: json['requirement_type'] as String,
      requirementValue: json['requirement_value'] as int,
    );
  }

  static Color _parseColor(String hexColor) {
    final hex = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class UserAchievementModel {
  final String id;
  final String oderId;
  final String achievementId;
  final DateTime unlockedAt;
  final AchievementModel? achievement;

  UserAchievementModel({
    required this.id,
    required this.oderId,
    required this.achievementId,
    required this.unlockedAt,
    this.achievement,
  });

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementModel(
      id: json['id'] as String,
      oderId: json['user_id'] as String,
      achievementId: json['achievement_id'] as String,
      unlockedAt: DateTime.parse(json['unlocked_at'] as String),
      achievement: json['achievements'] != null
          ? AchievementModel.fromJson(json['achievements'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': oderId,
      'achievement_id': achievementId,
    };
  }
}
