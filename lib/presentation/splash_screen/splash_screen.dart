import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'widgets/animated_mascot_widget.dart';
import 'widgets/animated_title_widget.dart';
import 'widgets/particle_background_widget.dart';
import '../../widgets/smooth_page_transition.dart';
import '../name_entry_screen/name_entry_screen.dart';
import '../main_menu_screen/main_menu_screen.dart';
import '../../services/device_id_service.dart';
import '../../services/supabase_service.dart';

/// Modern splash screen with polished animations and smooth transitions
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Main animation controller for orchestrating entrance
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Shimmer effect controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Pulse controller for subtle breathing effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    // Fade in animation (0-1)
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Scale animation with overshoot
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Slide up animation
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // Shimmer animation
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(_shimmerController);

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start main animation
    await _mainController.forward();

    // Check for device account while animation plays
    await _checkDeviceAccount();
  }

  Future<void> _checkDeviceAccount() async {
    // Ensure minimum splash duration
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      // 1. Get Device ID
      final deviceId = await DeviceIdService.instance.getDeviceId();
      if (deviceId == null) {
        debugPrint('Could not get device ID, going to name entry');
        _navigateToNameEntry();
        return;
      }

      // 2. Check if we have a locally saved user ID (Legacy/Offline support)
      final currentUserId = await SupabaseService.instance.getCurrentUserId();

      if (currentUserId != null) {
        // User is locally logged in. Check if they need device ID migration.
        if (SupabaseService.instance.isAvailable) {
          final user = await SupabaseService.instance.getUserById(
            currentUserId,
          );
          if (user != null && user.deviceId == null) {
            debugPrint('Migrating existing user to device ID');
            await SupabaseService.instance.updateUserDeviceId(
              userId: user.id,
              deviceId: deviceId,
            );
          }
        }
        _navigateToMainMenu();
        return;
      }

      // 3. Check if this device has an account on server (for fresh install/cleared data)
      final existingUser = await SupabaseService.instance.getUserByDeviceId(
        deviceId,
      );

      if (existingUser != null) {
        debugPrint(
          'Device account found: ${existingUser.name}, auto-logging in',
        );
        await SupabaseService.instance.setCurrentUserId(existingUser.id);
        _navigateToMainMenu();
      } else {
        debugPrint('No account found for this device, going to name entry');
        _navigateToNameEntry();
      }
    } catch (e) {
      debugPrint('Error in splash check: $e');
      // Fallback to name entry on error
      _navigateToNameEntry();
    }
  }

  void _navigateToMainMenu() {
    if (mounted && !_navigated) {
      _navigated = true;
      Navigator.of(context).pushReplacement(
        SmoothPageTransition(
          page: const MainMenuScreen(),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _navigateToNameEntry() {
    if (mounted && !_navigated) {
      _navigated = true;
      Navigator.of(context).pushReplacement(
        SmoothPageTransition(
          page: const NameEntryScreen(),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Animated particle background
          const ParticleBackgroundWidget(),

          // Main content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Animated mascot with advanced effects
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _fadeInAnimation,
                      _scaleAnimation,
                      _pulseAnimation,
                    ]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeInAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value * _pulseAnimation.value,
                          child: const AnimatedMascotWidget(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 6.h),

                  // Animated title with shimmer effect
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _fadeInAnimation,
                      _slideAnimation,
                      _shimmerAnimation,
                    ]),
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: Opacity(
                          opacity: _fadeInAnimation.value,
                          child: AnimatedTitleWidget(
                            shimmerValue: _shimmerAnimation.value,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 3.h),

                  // Animated tagline
                  AnimatedBuilder(
                    animation: _fadeInAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: (_fadeInAnimation.value - 0.3).clamp(0.0, 1.0),
                        child: Text(
                          'Where Learning Meets Fun',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 3),

                  // Loading indicator
                  AnimatedBuilder(
                    animation: _fadeInAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: (_fadeInAnimation.value - 0.5).clamp(0.0, 1.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 8.w,
                              height: 8.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Loading...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 6.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
