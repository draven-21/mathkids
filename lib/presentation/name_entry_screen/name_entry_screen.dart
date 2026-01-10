import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import './widgets/name_input_widget.dart';
import './widgets/start_button_widget.dart';
import './widgets/welcome_header_widget.dart';
import '../splash_screen/widgets/particle_background_widget.dart';

/// Name Entry Screen - Modern redesign with advanced animations
/// First launch screen for capturing student information
class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({Key? key}) : super(key: key);

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _isButtonEnabled = false;
  String? _errorMessage;
  String? _suggestedName;
  bool _isCheckingName = false;

  late AnimationController _mainAnimationController;
  late AnimationController _headerAnimationController;
  late AnimationController _floatAnimationController;
  late AnimationController _pulseAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _headerScaleAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _nameController.addListener(_validateInput);

    // Auto-focus input field after animation
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _nameFocusNode.requestFocus();
      }
    });
  }

  void _setupAnimations() {
    // Main content animation
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainAnimationController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Header animation
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Continuous floating animation
    _floatAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _floatAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Pulse animation for button
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _mainAnimationController.forward();
      }
    });
  }

  void _validateInput() {
    final text = _nameController.text.trim();
    setState(() {
      _errorMessage = null;
      _suggestedName = null;

      if (text.isEmpty) {
        _isButtonEnabled = false;
        return;
      }

      // Check for minimum length
      if (text.length < 2) {
        _isButtonEnabled = false;
        _errorMessage = 'Name must be at least 2 characters';
        return;
      }

      // Check for maximum length
      if (text.length > 20) {
        _isButtonEnabled = false;
        _errorMessage = 'Name must be 20 characters or less';
        return;
      }

      // Check name availability in database
      _checkNameAvailability(text);
    });
  }

  Future<void> _checkNameAvailability(String name) async {
    setState(() {
      _isCheckingName = true;
      _isButtonEnabled = false;
    });

    try {
      final isAvailable = await SupabaseService.instance.isNameAvailable(name);

      if (!mounted) return;

      if (isAvailable) {
        setState(() {
          _isButtonEnabled = true;
          _isCheckingName = false;
        });
      } else {
        // Name exists, generate suggestions
        final suggestion = await _generateUniqueName(name);
        setState(() {
          _errorMessage = 'This name is already taken';
          _suggestedName = suggestion;
          _isButtonEnabled = false;
          _isCheckingName = false;
        });
      }
    } catch (e) {
      // If check fails, allow user to proceed (offline mode)
      if (mounted) {
        setState(() {
          _isButtonEnabled = true;
          _isCheckingName = false;
        });
      }
    }
  }

  Future<String> _generateUniqueName(String baseName) async {
    // Try adding numbers 1-99
    for (int i = 1; i <= 99; i++) {
      final suggestion = '$baseName$i';
      final isAvailable = await SupabaseService.instance.isNameAvailable(
        suggestion,
      );
      if (isAvailable) {
        return suggestion;
      }
    }

    // If all numbers taken, add random suffix
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    return '$baseName$random';
  }

  void _useSuggestedName() {
    if (_suggestedName != null) {
      _nameController.text = _suggestedName!;
      setState(() {
        _errorMessage = null;
        _suggestedName = null;
      });
    }
  }

  Future<void> _handleStartLearning() async {
    if (!_isButtonEnabled || _isCheckingName) return;

    final name = _nameController.text.trim();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Double-check name availability before creating user
    setState(() => _isCheckingName = true);

    try {
      final isAvailable = await SupabaseService.instance.isNameAvailable(name);

      if (!isAvailable) {
        // Name was taken between validation and submission
        final suggestion = await _generateUniqueName(name);
        if (mounted) {
          setState(() {
            _errorMessage = 'This name was just taken by someone else';
            _suggestedName = suggestion;
            _isButtonEnabled = false;
            _isCheckingName = false;
          });
        }
        return;
      }

      // Create user in Supabase
      final user = await SupabaseService.instance.createUser(name);

      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Save name to SharedPreferences for quick access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('student_name', name);
      await prefs.setBool('is_first_launch', false);

      // Navigate to main menu with personalized welcome
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushReplacementNamed(
          '/main-menu-screen',
          arguments: {'studentName': name, 'isFirstTime': true},
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Oops! Something went wrong. Please try again.';
          _isCheckingName = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _mainAnimationController.dispose();
    _headerAnimationController.dispose();
    _floatAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always use light theme for name entry screen
    return Theme(
      data: AppTheme.lightTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return WillPopScope(
            onWillPop: () async => false, // Disable back gesture
            child: Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: Stack(
                children: [
                  // Particle background (matching splash screen)
                  const ParticleBackgroundWidget(),

                  // Main content
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 4.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 2.h),

                            // Animated welcome header
                            AnimatedBuilder(
                              animation: Listenable.merge([
                                _headerFadeAnimation,
                                _headerScaleAnimation,
                                _floatAnimation,
                              ]),
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _headerFadeAnimation.value,
                                  child: Transform.scale(
                                    scale: _headerScaleAnimation.value,
                                    child: Transform.translate(
                                      offset: Offset(0, _floatAnimation.value),
                                      child: const WelcomeHeaderWidget(),
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 6.h),

                            // Animated input section
                            AnimatedBuilder(
                              animation: Listenable.merge([
                                _fadeAnimation,
                                _slideAnimation,
                              ]),
                              builder: (context, child) {
                                return SlideTransition(
                                  position: _slideAnimation,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Column(
                                      children: [
                                        // Enhanced name input with glow effect
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: theme.colorScheme.primary
                                                    .withValues(alpha: 0.2),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: NameInputWidget(
                                            controller: _nameController,
                                            focusNode: _nameFocusNode,
                                            errorMessage: _errorMessage,
                                          ),
                                        ),

                                        // Suggested name with animation
                                        if (_suggestedName != null) ...[
                                          SizedBox(height: 2.h),
                                          TweenAnimationBuilder<double>(
                                            duration: const Duration(
                                              milliseconds: 400,
                                            ),
                                            tween: Tween(begin: 0.0, end: 1.0),
                                            curve: Curves.elasticOut,
                                            builder: (context, value, child) {
                                              return Transform.scale(
                                                scale: value,
                                                child: Opacity(
                                                  opacity: value,
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: GestureDetector(
                                              onTap: _useSuggestedName,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 5.w,
                                                  vertical: 2.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      theme.colorScheme.primary
                                                          .withValues(
                                                            alpha: 0.15,
                                                          ),
                                                      theme
                                                          .colorScheme
                                                          .secondary
                                                          .withValues(
                                                            alpha: 0.15,
                                                          ),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: theme
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.4),
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: theme
                                                          .colorScheme
                                                          .primary
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                      blurRadius: 12,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.auto_fix_high,
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                      size: 24,
                                                    ),
                                                    SizedBox(width: 3.w),
                                                    Flexible(
                                                      child: Text(
                                                        'Try "$_suggestedName" instead? 💡',
                                                        style: theme
                                                            .textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                              color: theme
                                                                  .colorScheme
                                                                  .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],

                                        // Checking indicator with pulsing animation
                                        if (_isCheckingName) ...[
                                          SizedBox(height: 2.h),
                                          TweenAnimationBuilder<double>(
                                            duration: const Duration(
                                              milliseconds: 600,
                                            ),
                                            tween: Tween(begin: 0.0, end: 1.0),
                                            builder: (context, value, child) {
                                              return Opacity(
                                                opacity: value,
                                                child: child,
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4.w,
                                                vertical: 1.5.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: theme
                                                    .colorScheme
                                                    .surfaceVariant
                                                    .withValues(alpha: 0.5),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: theme
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.3),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(
                                                            theme
                                                                .colorScheme
                                                                .primary,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 3.w),
                                                  Text(
                                                    'Checking availability...',
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 8.h),

                            // Animated start button with pulse effect
                            AnimatedBuilder(
                              animation: Listenable.merge([
                                _fadeAnimation,
                                _slideAnimation,
                                _pulseAnimation,
                              ]),
                              builder: (context, child) {
                                return SlideTransition(
                                  position: _slideAnimation,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Transform.scale(
                                      scale: _isButtonEnabled
                                          ? _pulseAnimation.value
                                          : 1.0,
                                      child: StartButtonWidget(
                                        isEnabled: _isButtonEnabled,
                                        onPressed: _handleStartLearning,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 4.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
