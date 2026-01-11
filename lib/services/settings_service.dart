import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static SettingsService? _instance;
  static SettingsService get instance => _instance ??= SettingsService._();

  SettingsService._();

  static const String _themeModeKey = 'theme_mode';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  ThemeMode _themeMode = ThemeMode.dark;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Default to Dark Mode
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.dark.index;
    _themeMode = ThemeMode.values[themeModeIndex];

    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    _vibrationEnabled = prefs.getBool(_vibrationEnabledKey) ?? true;
    _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeModeKey);
    await prefs.remove(_soundEnabledKey);
    await prefs.remove(_vibrationEnabledKey);
    await prefs.remove(_notificationsEnabledKey);

    _themeMode = ThemeMode.dark; // Default to Dark Mode
    _soundEnabled = true;
    _vibrationEnabled = true;
    _notificationsEnabled = true;

    notifyListeners();
  }

  String getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
