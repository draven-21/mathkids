import 'package:flutter/foundation.dart';

/// Global state manager for avatar updates across the app
/// Notifies all listeners when avatar changes, ensuring consistent display
class AvatarStateManager extends ChangeNotifier {
  static final AvatarStateManager _instance = AvatarStateManager._internal();

  factory AvatarStateManager() => _instance;

  AvatarStateManager._internal();

  String? _currentAvatarUrl;
  String? _currentUserId;

  /// Get current avatar URL
  String? get currentAvatarUrl => _currentAvatarUrl;

  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Update avatar URL and notify all listeners
  void updateAvatar(String? avatarUrl, String userId) {
    if (_currentAvatarUrl != avatarUrl || _currentUserId != userId) {
      _currentAvatarUrl = avatarUrl;
      _currentUserId = userId;
      debugPrint('AvatarStateManager: Avatar updated for user $userId');
      notifyListeners();
    }
  }

  /// Clear avatar (for logout or removal)
  void clearAvatar() {
    _currentAvatarUrl = null;
    _currentUserId = null;
    debugPrint('AvatarStateManager: Avatar cleared');
    notifyListeners();
  }

  /// Initialize avatar from user data
  void initializeAvatar(String? avatarUrl, String userId) {
    _currentAvatarUrl = avatarUrl;
    _currentUserId = userId;
    debugPrint('AvatarStateManager: Avatar initialized for user $userId');
  }

  /// Check if avatar is set for current user
  bool hasAvatar() {
    return _currentAvatarUrl != null &&
        _currentAvatarUrl!.isNotEmpty &&
        _currentUserId != null;
  }
}
