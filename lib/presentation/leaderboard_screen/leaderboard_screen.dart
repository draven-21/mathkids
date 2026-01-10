import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/leaderboard_header_widget.dart';
import './widgets/podium_widget.dart';
import './widgets/ranking_list_widget.dart';
import './widgets/user_stats_widget.dart';

/// Leaderboard Screen displays local student rankings through engaging competition interface
/// that motivates continued learning. Features pixel-style podium design for top performers,
/// scrollable ranking list, and current user statistics.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isRefreshing = false;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _celebrationController;

  List<Map<String, dynamic>> _leaderboardData = [];

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _celebrationController.repeat();

    // Load leaderboard data from Supabase
    _loadLeaderboardData();
  }

  Future<void> _loadLeaderboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      if (SupabaseService.instance.isAvailable) {
        final entries = await SupabaseService.instance.getLeaderboard();
        
        if (!mounted) return;
        setState(() {
          _leaderboardData = entries.map((e) => e.toDisplayMap()).toList();
          _isLoading = false;
        });

        // Auto-scroll to current user after data loads
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToCurrentUser();
        });
      } else {
        // Offline mode - show empty state
        if (!mounted) return;
        setState(() {
          _leaderboardData = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading leaderboard: $e');
      if (!mounted) return;
      setState(() {
        _leaderboardData = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  /// Scrolls to current user's position in the leaderboard
  void _scrollToCurrentUser() {
    final currentUserIndex = _leaderboardData.indexWhere(
      (user) => (user["isCurrentUser"] as bool) == true,
    );

    if (currentUserIndex != -1 && currentUserIndex >= 3) {
      // Calculate scroll position (accounting for podium and header)
      final scrollPosition = (currentUserIndex - 3) * 10.h;

      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Refreshes leaderboard data from Supabase
  Future<void> _refreshLeaderboard() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);

    try {
      if (SupabaseService.instance.isAvailable) {
        final entries = await SupabaseService.instance.getLeaderboard();
        
        if (!mounted) return;
        setState(() {
          _leaderboardData = entries.map((e) => e.toDisplayMap()).toList();
          _isRefreshing = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isRefreshing = false);
      }
    } catch (e) {
      debugPrint('Error refreshing leaderboard: $e');
      if (!mounted) return;
      setState(() => _isRefreshing = false);
    }

    // Scroll to current user again after refresh
    if (mounted) _scrollToCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Handle empty or missing data gracefully
    Map<String, dynamic> currentUser = {};
    if (_leaderboardData.isNotEmpty) {
      currentUser = _leaderboardData.firstWhere(
        (user) => (user["isCurrentUser"] as bool?) == true,
        orElse: () => _leaderboardData[0],
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.scaffoldBackgroundColor,
            theme.scaffoldBackgroundColor,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Header with title and refresh button
          LeaderboardHeaderWidget(
            onRefresh: _refreshLeaderboard,
            isRefreshing: _isRefreshing,
          ),

          // Main scrollable content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshLeaderboard,
              color: theme.colorScheme.primary,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                  : _leaderboardData.isEmpty
                  ? _buildEmptyState(theme)
                  : CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Top 3 podium
                        SliverToBoxAdapter(
                          child: PodiumWidget(
                            topThree: _leaderboardData.take(3).toList(),
                            celebrationController: _celebrationController,
                          ),
                        ),

                        SliverToBoxAdapter(child: SizedBox(height: 3.h)),

                        // Ranking list (4th place onwards)
                        SliverToBoxAdapter(
                          child: RankingListWidget(
                            rankings: _leaderboardData.skip(3).toList(),
                          ),
                        ),

                        SliverToBoxAdapter(child: SizedBox(height: 2.h)),
                      ],
                    ),
            ),
          ),

          // Current user statistics at bottom - only show if we have data
          if (currentUser.isNotEmpty)
            UserStatsWidget(
              quizzesCompleted: currentUser["quizzesCompleted"] as int? ?? 0,
              averageScore: currentUser["averageScore"] as int? ?? 0,
              currentStreak: currentUser["currentStreak"] as int? ?? 0,
            ),
        ],
      ),
    );
  }

  /// Builds empty state for first-time users
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cartoon mascot illustration
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: CustomIconWidget(
                  iconName: 'emoji_events',
                  size: 20.w,
                  color: theme.colorScheme.primary,
                ),
              ),

              SizedBox(height: 3.h),

              Text(
                'Start Your Journey!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),

              Text(
                'Complete quizzes to earn points and climb the leaderboard. Every correct answer brings you closer to becoming a Math Champion!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 3.h),

              // Point earning system explanation
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    _buildPointExplanation(
                      theme,
                      'Complete a quiz',
                      '+50 points',
                      'videogame_asset',
                    ),
                    SizedBox(height: 2.h),
                    _buildPointExplanation(
                      theme,
                      'Perfect score',
                      '+100 bonus',
                      'star',
                    ),
                    SizedBox(height: 2.h),
                    _buildPointExplanation(
                      theme,
                      'Daily streak',
                      '+25 points',
                      'local_fire_department',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds individual point explanation row
  Widget _buildPointExplanation(
    ThemeData theme,
    String action,
    String points,
    String iconName,
  ) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            size: 5.w,
            color: theme.colorScheme.primary,
          ),
        ),

        SizedBox(width: 3.w),

        Expanded(
          child: Text(
            action,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),

        Text(
          points,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
