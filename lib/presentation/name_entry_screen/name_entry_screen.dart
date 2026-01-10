import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import './widgets/name_input_widget.dart';
import './widgets/start_button_widget.dart';
import './widgets/welcome_header_widget.dart';

/// Name Entry Screen - First launch screen for capturing student information
/// Uses stack navigation pattern, accessible only from splash for new users
class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({Key? key}) : super(key: key);

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _isButtonEnabled = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _nameController.addListener(_validateInput);

    // Auto-focus input field after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _nameFocusNode.requestFocus();
      }
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  void _validateInput() {
    final text = _nameController.text.trim();
    setState(() {
      _errorMessage = null;

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

      // Check for special characters and numbers
      final validNameRegex = RegExp(r'^[a-zA-Z\s]+$');
      if (!validNameRegex.hasMatch(text)) {
        _isButtonEnabled = false;
        _errorMessage = 'Please use only letters and spaces';
        return;
      }

      _isButtonEnabled = true;
    });
  }

  Future<void> _handleStartLearning() async {
    if (!_isButtonEnabled) return;

    final name = _nameController.text.trim();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    try {
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
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _animationController.dispose();
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
              body: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 4.h),

                            // Welcome header with mascot
                            WelcomeHeaderWidget(),

                            SizedBox(height: 6.h),

                            // Name input field
                            NameInputWidget(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              errorMessage: _errorMessage,
                            ),

                            SizedBox(height: 8.h),

                            // Start learning button
                            StartButtonWidget(
                              isEnabled: _isButtonEnabled,
                              onPressed: _handleStartLearning,
                            ),

                            SizedBox(height: 4.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
