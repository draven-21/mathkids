import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import '../../widgets/animated_math_background.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/leaderboard_header_widget.dart';
import './widgets/podium_widget.dart';
import './widgets/ranking_list_widget.dart';
import './widgets/user_stats_widget.dart';

/// Leaderboard Screen with modern design, animated math background, and layout inspired by reference
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
      duration: const Duration(milliseconds: 2000),
    );
    _celebrationController.repeat();

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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToCurrentUser();
        });
      } else {
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

  void _scrollToCurrentUser() {
    final currentUserIndex = _leaderboardData.indexWhere(
      (user) => (user["isCurrentUser"] as bool) == true,
    );

    if (currentUserIndex != -1 && currentUserIndex >= 3) {
      final scrollPosition = (currentUserIndex - 3) * 10.h;

      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

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

    if (mounted) _scrollToCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Map<String, dynamic> currentUser = {};
    if (_leaderboardData.isNotEmpty) {
      currentUser = _leaderboardData.firstWhere(
        (user) => (user["isCurrentUser"] as bool?) == true,
        orElse: () => _leaderboardData[0],
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated math background
          Positioned.fill(
            child: AnimatedMathBackground(
              symbolColor: theme.colorScheme.primary,
              opacity: 0.05,
              symbolCount: 25,
              animationSpeed: 0.8,
            ),
          ),

          // Main content
          Column(
            children: [
              // Header
              LeaderboardHeaderWidget(
                onRefresh: _refreshLeaderboard,
                isRefreshing: _isRefreshing,
              ),

              // Scrollable content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshLeaderboard,
                  color: theme.colorScheme.primary,
                  child: _isLoading
                      ? Center(
                          child: Container(
                            padding: EdgeInsets.all(5.w),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(4.w),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                              strokeWidth: 3,
                            ),
                          ),
                        )
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

                            SizedBox(height: 3.h).sliverBox,

                            // Ranking list (4th place onwards)
                            SliverToBoxAdapter(
                              child: RankingListWidget(
                                rankings: _leaderboardData.skip(3).toList(),
                              ),
                            ),

                            SizedBox(height: 2.h).sliverBox,
                          ],
                        ),
                ),
              ),

              // User statistics at bottom
              if (currentUser.isNotEmpty)
                UserStatsWidget(
                  quizzesCompleted:
                      currentUser["quizzesCompleted"] as int? ?? 0,
                  averageScore: currentUser["averageScore"] as int? ?? 0,
                  currentStreak: currentUser["currentStreak"] as int? ?? 0,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy illustration
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'emoji_events',
                    size: 25.w,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // Title
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(3.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Start Your Journey!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 2.h),

              // Description
              Text(
                'Complete quizzes to earn points and climb the leaderboard.\nEvery correct answer brings you closer to becoming a Math Champion!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 4.h),

              // Point explanation cards
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(4.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPointExplanation(
                      theme,
                      'Complete a quiz',
                      '+50 points',
                      'videogame_asset',
                      theme.colorScheme.primary,
                    ),
                    SizedBox(height: 3.h),
                    _buildPointExplanation(
                      theme,
                      'Perfect score',
                      '+100 bonus',
                      'star',
                      const Color(0xFFF39C12),
                    ),
                    SizedBox(height: 3.h),
                    _buildPointExplanation(
                      theme,
                      'Daily streak',
                      '+25 points',
                      'local_fire_department',
                      const Color(0xFFE74C3C),
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

  Widget _buildPointExplanation(
    ThemeData theme,
    String action,
    String points,
    String iconName,
    Color accentColor,
  ) {
    return Row(
      children: [
        // Icon container
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(3.5.w),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomIconWidget(
            iconName: iconName,
            size: 7.w,
            color: Colors.white,
          ),
        ),

        SizedBox(width: 4.w),

        // Action text
        Expanded(
          child: Text(
            action,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Points badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
          ),
          child: Text(
            points,
            style: theme.textTheme.titleSmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// Extension for easier sliver conversion
extension SliverBoxAdapter on SizedBox {
  Widget get sliverBox => SliverToBoxAdapter(child: this);
}
