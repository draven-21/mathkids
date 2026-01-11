import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/settings_service.dart';
import '../../services/supabase_service.dart';
import '../../services/avatar_state_manager.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/user_avatar_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService.instance;
  String _studentName = '';
  String? _avatarUrl;
  String _avatarInitials = 'S';
  Color _avatarColor = const Color(0xFF4A90E2);
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadStudentName();
    _loadUserData();

    // Listen to avatar changes
    AvatarStateManager().addListener(_onAvatarChanged);
  }

  @override
  void dispose() {
    AvatarStateManager().removeListener(_onAvatarChanged);
    super.dispose();
  }

  void _onAvatarChanged() {
    if (!mounted) return;

    final currentAvatar = AvatarStateManager().currentAvatarUrl;
    final currentUser = AvatarStateManager().currentUserId;

    if (currentUser == _userId && currentAvatar != _avatarUrl) {
      setState(() {
        _avatarUrl = currentAvatar;
      });
    }
  }

  Future<void> _loadStudentName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentName = prefs.getString('student_name') ?? 'Student';
    });
  }

  Future<void> _loadUserData() async {
    if (!SupabaseService.instance.isAvailable) return;

    try {
      final userId = await SupabaseService.instance.getCurrentUserId();
      if (userId == null || !mounted) return;

      final user = await SupabaseService.instance.getUserById(userId);
      if (user == null || !mounted) return;

      setState(() {
        _userId = userId;
        _studentName = user.name;
        _avatarUrl = user.avatarUrl;
        _avatarInitials = user.avatarInitials;
        _avatarColor = user.avatarColor; // Already a Color object
      });

      // Initialize AvatarStateManager
      AvatarStateManager().initializeAvatar(user.avatarUrl, userId);
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings', style: theme.appBarTheme.titleTextStyle),
        centerTitle: true,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color:
                theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(theme),
                SizedBox(height: 3.h),
                _buildAppearanceSection(theme),
                SizedBox(height: 3.h),
                _buildPreferencesSection(theme),
                SizedBox(height: 3.h),
                _buildAboutSection(theme),
                SizedBox(height: 3.h),
                _buildResetSection(theme),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // User avatar (read-only, no editing)
          ResponsiveUserAvatar(
            avatarUrl: _avatarUrl,
            initials: _avatarInitials,
            backgroundColor: _avatarColor,
            sizePercentage: 15.0,
            borderWidth: 3.0,
            borderColor: Colors.white.withOpacity(0.3),
            showEditIcon: false, // Read-only display
            onTap: null, // No tap handler - editing only in progress screen
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _studentName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Math Explorer',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appearance',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildThemeOption(
                theme,
                ThemeMode.system,
                'System',
                'brightness_auto',
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              _buildThemeOption(theme, ThemeMode.light, 'Light', 'light_mode'),
              Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              _buildThemeOption(theme, ThemeMode.dark, 'Dark', 'dark_mode'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    ThemeData theme,
    ThemeMode mode,
    String label,
    String icon,
  ) {
    final isSelected = _settingsService.themeMode == mode;
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? CustomIconWidget(
              iconName: 'check_circle',
              color: theme.colorScheme.primary,
              size: 24,
            )
          : null,
      onTap: () async {
        await _settingsService.setThemeMode(mode);
        setState(() {});
      },
    );
  }

  Widget _buildPreferencesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                theme: theme,
                title: 'Sound Effects',
                subtitle: 'Play sounds during quizzes',
                icon: 'volume_up',
                value: _settingsService.soundEnabled,
                onChanged: (value) async {
                  await _settingsService.setSoundEnabled(value);
                  setState(() {});
                },
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              _buildSwitchTile(
                theme: theme,
                title: 'Vibration',
                subtitle: 'Haptic feedback for answers',
                icon: 'vibration',
                value: _settingsService.vibrationEnabled,
                onChanged: (value) async {
                  await _settingsService.setVibrationEnabled(value);
                  setState(() {});
                },
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              _buildSwitchTile(
                theme: theme,
                title: 'Notifications',
                subtitle: 'Daily learning reminders',
                icon: 'notifications',
                value: _settingsService.notificationsEnabled,
                onChanged: (value) async {
                  await _settingsService.setNotificationsEnabled(value);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required String icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: CustomIconWidget(
        iconName: icon,
        color: theme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      value: value,
      activeColor: theme.colorScheme.primary,
      onChanged: onChanged,
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'info',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(
                  'Version',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                trailing: Text(
                  '1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'school',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(
                  'Math Quiz Kids',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Fun learning for young minds',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResetSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        leading: CustomIconWidget(
          iconName: 'restart_alt',
          color: theme.colorScheme.error,
          size: 24,
        ),
        title: Text(
          'Reset All Settings',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Restore default settings',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error.withValues(alpha: 0.7),
          ),
        ),
        onTap: () => _showResetConfirmation(theme),
      ),
    );
  }

  void _showResetConfirmation(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Settings?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will restore all settings to their default values.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _settingsService.resetAllSettings();
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
