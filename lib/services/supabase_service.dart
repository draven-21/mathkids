import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/quiz_result_model.dart';
import '../models/achievement_model.dart';
import '../models/skill_progress_model.dart';
import '../models/daily_activity_model.dart';
import '../models/leaderboard_entry_model.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static String supabaseUrl = '';
  static String supabaseAnonKey = '';

  static const String _userIdKey = 'current_user_id';

  // Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    // Try to get from environment variables first (for production)
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      supabaseUrl = const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: '',
      );
      supabaseAnonKey = const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: '',
      );
    }

    // If still empty, try to read from env.json file
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      try {
        final String envString = await rootBundle.loadString('env.json');
        final Map<String, dynamic> envData = json.decode(envString);
        supabaseUrl = envData['SUPABASE_URL'] ?? '';
        supabaseAnonKey = envData['SUPABASE_ANON_KEY'] ?? '';
        debugPrint('Loaded Supabase credentials from env.json');
        debugPrint('URL from env.json: $supabaseUrl');
        debugPrint(
          'Key from env.json: ${supabaseAnonKey.isNotEmpty ? 'Present' : 'Missing'}',
        );
      } catch (e) {
        debugPrint('Could not load env.json: $e');
        debugPrint(
          'Make sure env.json is in the root directory and added to pubspec.yaml assets',
        );
      }
    }

    debugPrint('Supabase URL: ${supabaseUrl.isNotEmpty ? 'Set' : 'Not set'}');
    debugPrint(
      'Supabase Anon Key: ${supabaseAnonKey.isNotEmpty ? 'Set' : 'Not set'}',
    );

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      debugPrint(
        'WARNING: Supabase credentials not found. App will run in offline mode.',
      );
      debugPrint('To fix this, either:');
      debugPrint('1. Run with dart-define flags');
      debugPrint('2. Ensure env.json exists in root directory');
      return; // Don't throw exception, just continue without Supabase
    }

    try {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
      debugPrint('App will continue in offline mode');
      // Don't rethrow, just continue without Supabase
    }
  }

  // Get Supabase client
  SupabaseClient get client {
    if (!Supabase.instance.isInitialized) {
      throw Exception('Supabase is not initialized - running in offline mode');
    }
    return Supabase.instance.client;
  }

  // Check if Supabase is available
  bool get isAvailable => Supabase.instance.isInitialized;

  // ============================================================
  // USER MANAGEMENT
  // ============================================================

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<void> setCurrentUserId(String oderId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, oderId);
  }

  Future<UserModel?> getCurrentUser() async {
    if (!isAvailable) return null;
    final oderId = await getCurrentUserId();
    if (oderId == null) return null;
    return getUserById(oderId);
  }

  Future<UserModel?> getUserById(String oderId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', oderId)
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  /// Check if a name is available (not already taken by another user)
  Future<bool> isNameAvailable(String name) async {
    if (!isAvailable) {
      // In offline mode, assume name is available
      return true;
    }

    try {
      final response = await client
          .from('users')
          .select('id')
          .ilike('name', name)
          .limit(1);

      // If response is empty, name is available
      return response.isEmpty;
    } catch (e) {
      debugPrint('Error checking name availability: $e');
      // On error, assume name is available to not block user
      return true;
    }
  }

  Future<UserModel?> createUser(String name) async {
    try {
      if (!isAvailable) {
        debugPrint('Supabase not available - creating user locally');
        // Create a mock user for offline mode
        final mockUser = UserModel(
          id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          avatarInitials: _generateAvatarInitials(name),
          avatarColor: _generateRandomColorObject(),
          totalPoints: 0,
          currentLevel: 1,
          currentStreak: 0,
          longestStreak: 0,
          quizzesCompleted: 0,
          totalCorrectAnswers: 0,
          totalQuestionsAttempted: 0,
          lastQuizDate: DateTime.now(),
          lastActivityDate: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await setCurrentUserId(mockUser.id);
        debugPrint('User created locally: ${mockUser.id}');
        return mockUser;
      }

      debugPrint('Creating user: $name');
      final avatarInitials = _generateAvatarInitials(name);
      final avatarColor = _generateRandomColor();

      final response = await client
          .from('users')
          .insert({
            'name': name,
            'avatar_initials': avatarInitials,
            'avatar_color': avatarColor,
          })
          .select()
          .single();

      final user = UserModel.fromJson(response);
      await setCurrentUserId(user.id);
      debugPrint('User created successfully: ${user.id}');

      // Initialize skill progress for all operations
      await _initializeSkillProgress(user.id);

      return user;
    } catch (e) {
      debugPrint('Error creating user: $e');
      return null;
    }
  }

  Future<void> _initializeSkillProgress(String oderId) async {
    final skills = ['addition', 'subtraction', 'multiplication', 'division'];
    for (final skill in skills) {
      try {
        await client.from('skill_progress').insert({
          'user_id': oderId,
          'skill_name': skill,
          'total_attempted': 0,
          'total_correct': 0,
          'mastery_percentage': 0.0,
        });
      } catch (e) {
        debugPrint('Error initializing skill $skill: $e');
      }
    }
  }

  Future<UserModel?> updateUser(UserModel user) async {
    try {
      final response = await client
          .from('users')
          .update(user.toJson())
          .eq('id', user.id)
          .select()
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Error updating user: $e');
      return null;
    }
  }

  String _generateAvatarInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _generateRandomColor() {
    final colors = [
      '#4A90E2',
      '#F39C12',
      '#27AE60',
      '#9B59B6',
      '#E74C3C',
      '#3498DB',
      '#1ABC9C',
      '#E91E63',
      '#FF5722',
      '#607D8B',
    ];
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }

  Color _generateRandomColorObject() {
    final colorString = _generateRandomColor();
    return _parseColor(colorString);
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFF4A90E2);
    }
    final hex = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  // ============================================================
  // QUIZ RESULTS
  // ============================================================

  Future<QuizResultModel?> saveQuizResult(QuizResultModel result) async {
    try {
      final response = await client
          .from('quiz_results')
          .insert(result.toJson())
          .select()
          .single();

      // Update user stats
      await _updateUserStatsAfterQuiz(result);

      // Update skill progress if operation type is specified
      if (result.operationType != null) {
        await _updateSkillProgress(
          result.userId,
          result.operationType!,
          result.totalQuestions,
          result.correctAnswers,
        );
      }

      // Update daily activity
      await _updateDailyActivity(result);

      // Check for new achievements
      await _checkAndUnlockAchievements(result.userId);

      return QuizResultModel.fromJson(response);
    } catch (e) {
      debugPrint('Error saving quiz result: $e');
      return null;
    }
  }

  Future<void> _updateUserStatsAfterQuiz(QuizResultModel result) async {
    try {
      final user = await getUserById(result.userId);
      if (user == null) return;

      final today = DateTime.now();
      final lastQuizDate = user.lastQuizDate;

      int newStreak = user.currentStreak;
      if (lastQuizDate == null) {
        newStreak = 1;
      } else {
        final daysDiff = today.difference(lastQuizDate).inDays;
        if (daysDiff == 0) {
          // Same day, keep streak
        } else if (daysDiff == 1) {
          // Next day, increment streak
          newStreak = user.currentStreak + 1;
        } else {
          // Gap in days, reset streak
          newStreak = 1;
        }
      }

      await client
          .from('users')
          .update({
            'total_points': user.totalPoints + result.pointsEarned,
            'quizzes_completed': user.quizzesCompleted + 1,
            'total_correct_answers':
                user.totalCorrectAnswers + result.correctAnswers,
            'total_questions_attempted':
                user.totalQuestionsAttempted + result.totalQuestions,
            'current_streak': newStreak,
            'longest_streak': newStreak > user.longestStreak
                ? newStreak
                : user.longestStreak,
            'last_quiz_date': today.toIso8601String().split('T')[0],
            'last_activity_date': today.toIso8601String(),
          })
          .eq('id', result.userId);
    } catch (e) {
      debugPrint('Error updating user stats: $e');
    }
  }

  Future<void> _updateSkillProgress(
    String userId,
    String skillName,
    int attempted,
    int correct,
  ) async {
    try {
      // Get existing progress
      final existing = await client
          .from('skill_progress')
          .select()
          .eq('user_id', userId)
          .eq('skill_name', skillName)
          .maybeSingle();

      if (existing != null) {
        final newAttempted = (existing['total_attempted'] as int) + attempted;
        final newCorrect = (existing['total_correct'] as int) + correct;
        final mastery = newAttempted > 0
            ? (newCorrect / newAttempted) * 100
            : 0.0;

        await client
            .from('skill_progress')
            .update({
              'total_attempted': newAttempted,
              'total_correct': newCorrect,
              'mastery_percentage': mastery,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id']);
      } else {
        final mastery = attempted > 0 ? (correct / attempted) * 100 : 0.0;
        await client.from('skill_progress').insert({
          'user_id': userId,
          'skill_name': skillName,
          'total_attempted': attempted,
          'total_correct': correct,
          'mastery_percentage': mastery,
        });
      }
    } catch (e) {
      debugPrint('Error updating skill progress: $e');
    }
  }

  Future<void> _updateDailyActivity(QuizResultModel result) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final existing = await client
          .from('daily_activity')
          .select()
          .eq('user_id', result.userId)
          .eq('activity_date', today)
          .maybeSingle();

      if (existing != null) {
        final quizzes = (existing['quizzes_completed'] as int) + 1;
        final points = (existing['points_earned'] as int) + result.pointsEarned;
        final currentAvg = existing['average_score'] as num;
        final newAvg =
            ((currentAvg * (quizzes - 1)) + result.percentage) / quizzes;

        await client
            .from('daily_activity')
            .update({
              'quizzes_completed': quizzes,
              'points_earned': points,
              'average_score': newAvg,
            })
            .eq('id', existing['id']);
      } else {
        await client.from('daily_activity').insert({
          'user_id': result.userId,
          'activity_date': today,
          'quizzes_completed': 1,
          'points_earned': result.pointsEarned,
          'average_score': result.percentage.toDouble(),
        });
      }
    } catch (e) {
      debugPrint('Error updating daily activity: $e');
    }
  }

  Future<List<QuizResultModel>> getUserQuizHistory(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final response = await client
          .from('quiz_results')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => QuizResultModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting quiz history: $e');
      return [];
    }
  }

  // ============================================================
  // LEADERBOARD
  // ============================================================

  Future<List<LeaderboardEntryModel>> getLeaderboard({int limit = 50}) async {
    try {
      final currentUserId = await getCurrentUserId();

      final response = await client
          .from('leaderboard')
          .select()
          .order('rank')
          .limit(limit);

      return (response as List)
          .map(
            (json) => LeaderboardEntryModel.fromJson(
              json,
              currentUserId: currentUserId,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
      return [];
    }
  }

  Future<int?> getCurrentUserRank() async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return null;

      final response = await client
          .from('leaderboard')
          .select('rank')
          .eq('id', userId)
          .single();

      return response['rank'] as int?;
    } catch (e) {
      debugPrint('Error getting user rank: $e');
      return null;
    }
  }

  // ============================================================
  // SKILL PROGRESS
  // ============================================================

  Future<List<SkillProgressModel>> getUserSkillProgress(String userId) async {
    try {
      final response = await client
          .from('skill_progress')
          .select()
          .eq('user_id', userId);

      return (response as List)
          .map((json) => SkillProgressModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting skill progress: $e');
      return [];
    }
  }

  // ============================================================
  // DAILY ACTIVITY
  // ============================================================

  Future<Map<DateTime, int>> getUserActivityMap(
    String userId, {
    int days = 30,
  }) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await client
          .from('daily_activity')
          .select()
          .eq('user_id', userId)
          .gte('activity_date', startDate.toIso8601String().split('T')[0])
          .order('activity_date');

      final Map<DateTime, int> activityMap = {};
      for (final item in response as List) {
        final date = DateTime.parse(item['activity_date'] as String);
        activityMap[date] = item['quizzes_completed'] as int;
      }
      return activityMap;
    } catch (e) {
      debugPrint('Error getting activity map: $e');
      return {};
    }
  }

  Future<List<WeeklyScoreModel>> getWeeklyScores(String userId) async {
    try {
      final response = await client
          .from('weekly_scores')
          .select()
          .eq('user_id', userId);

      if ((response as List).isEmpty) {
        // Return default empty week data
        return _getDefaultWeeklyScores();
      }

      return response.map((json) => WeeklyScoreModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting weekly scores: $e');
      return _getDefaultWeeklyScores();
    }
  }

  List<WeeklyScoreModel> _getDefaultWeeklyScores() {
    return [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ].map((day) => WeeklyScoreModel(day: day, averageScore: 0)).toList();
  }

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  Future<List<AchievementModel>> getAllAchievements() async {
    try {
      final response = await client.from('achievements').select();
      return (response as List)
          .map((json) => AchievementModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting achievements: $e');
      return [];
    }
  }

  Future<List<UserAchievementModel>> getUserAchievements(String userId) async {
    try {
      final response = await client
          .from('user_achievements')
          .select('*, achievements(*)')
          .eq('user_id', userId);

      return (response as List)
          .map((json) => UserAchievementModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting user achievements: $e');
      return [];
    }
  }

  Future<void> _checkAndUnlockAchievements(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return;

      final allAchievements = await getAllAchievements();
      final userAchievements = await getUserAchievements(userId);
      final unlockedIds = userAchievements.map((a) => a.achievementId).toSet();

      for (final achievement in allAchievements) {
        if (unlockedIds.contains(achievement.id)) continue;

        bool shouldUnlock = false;

        switch (achievement.requirementType) {
          case 'quizzes_completed':
            shouldUnlock =
                user.quizzesCompleted >= achievement.requirementValue;
            break;
          case 'streak':
            shouldUnlock =
                user.currentStreak >= achievement.requirementValue ||
                user.longestStreak >= achievement.requirementValue;
            break;
          case 'points':
            shouldUnlock = user.totalPoints >= achievement.requirementValue;
            break;
          case 'perfect_score':
            // Check quiz history for perfect scores
            final perfectCount = await _countPerfectScores(userId);
            shouldUnlock = perfectCount >= achievement.requirementValue;
            break;
        }

        if (shouldUnlock) {
          await _unlockAchievement(userId, achievement.id);
        }
      }
    } catch (e) {
      debugPrint('Error checking achievements: $e');
    }
  }

  Future<int> _countPerfectScores(String userId) async {
    try {
      final response = await client
          .from('quiz_results')
          .select()
          .eq('user_id', userId);

      int count = 0;
      for (final result in response as List) {
        if (result['correct_answers'] == result['total_questions']) {
          count++;
        }
      }
      return count;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _unlockAchievement(String userId, String achievementId) async {
    try {
      await client.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': achievementId,
      });
    } catch (e) {
      debugPrint('Error unlocking achievement: $e');
    }
  }

  // ============================================================
  // COMBINED DATA FETCHING
  // ============================================================

  Future<Map<String, dynamic>> getUserProgressData(String userId) async {
    try {
      final results = await Future.wait([
        getUserById(userId),
        getUserSkillProgress(userId),
        getUserActivityMap(userId),
        getWeeklyScores(userId),
        getUserAchievements(userId),
        getAllAchievements(),
      ]);

      return {
        'user': results[0] as UserModel?,
        'skills': results[1] as List<SkillProgressModel>,
        'activityMap': results[2] as Map<DateTime, int>,
        'weeklyScores': results[3] as List<WeeklyScoreModel>,
        'userAchievements': results[4] as List<UserAchievementModel>,
        'allAchievements': results[5] as List<AchievementModel>,
      };
    } catch (e) {
      debugPrint('Error getting progress data: $e');
      return {};
    }
  }
}
