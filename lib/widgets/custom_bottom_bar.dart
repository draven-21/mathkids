import 'package:flutter/material.dart';

/// Custom bottom navigation bar widget for the educational math app.
/// Implements tab bar navigation pattern with three core sections:
/// Play (Main Menu), Scores (Leaderboard), and Profile (Progress Tracking).
///
/// This widget is parameterized and reusable - navigation logic should be
/// handled by the parent widget using the onTap callback.
class CustomBottomBar extends StatelessWidget {
  /// Current selected index (0-2)
  final int currentIndex;

  /// Callback when a navigation item is tapped
  final Function(int) onTap;

  const CustomBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 4.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: theme.brightness == Brightness.light
              ? const Color(0xFF7F8C8D)
              : const Color(0xFFB0B3B8),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(
                icon: Icons.videogame_asset_rounded,
                isSelected: currentIndex == 0,
                colorScheme: colorScheme,
              ),
              activeIcon: _buildIcon(
                icon: Icons.videogame_asset,
                isSelected: true,
                colorScheme: colorScheme,
              ),
              label: 'Play',
              tooltip: 'Main Menu - Start learning activities',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(
                icon: Icons.emoji_events_outlined,
                isSelected: currentIndex == 1,
                colorScheme: colorScheme,
              ),
              activeIcon: _buildIcon(
                icon: Icons.emoji_events,
                isSelected: true,
                colorScheme: colorScheme,
              ),
              label: 'Scores',
              tooltip: 'Leaderboard - View rankings and achievements',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(
                icon: Icons.star_outline_rounded,
                isSelected: currentIndex == 2,
                colorScheme: colorScheme,
              ),
              activeIcon: _buildIcon(
                icon: Icons.star_rounded,
                isSelected: true,
                colorScheme: colorScheme,
              ),
              label: 'Profile',
              tooltip: 'Progress Tracking - Monitor learning journey',
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an icon with appropriate styling and animation
  Widget _buildIcon({
    required IconData icon,
    required bool isSelected,
    required ColorScheme colorScheme,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(8.0),
      decoration: isSelected
          ? BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.0),
            )
          : null,
      child: Icon(icon, size: 28),
    );
  }
}
