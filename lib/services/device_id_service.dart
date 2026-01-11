import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Service for managing device unique identifier
/// Used to ensure one account per device
class DeviceIdService {
  static final DeviceIdService _instance = DeviceIdService._internal();
  factory DeviceIdService() => _instance;
  DeviceIdService._internal();

  static DeviceIdService get instance => _instance;

  String? _cachedDeviceId;

  /// Get unique device identifier
  /// - Android: androidId (persists across app reinstalls)
  /// - iOS: identifierForVendor (persists until all vendor apps uninstalled)
  /// - Returns null if unable to get device ID
  Future<String?> getDeviceId() async {
    // Return cached value if available
    if (_cachedDeviceId != null) {
      return _cachedDeviceId;
    }

    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _cachedDeviceId = androidInfo.id; // Android ID
        debugPrint('Device ID (Android): $_cachedDeviceId');
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _cachedDeviceId = iosInfo.identifierForVendor; // UUID
        debugPrint('Device ID (iOS): $_cachedDeviceId');
      } else {
        debugPrint('Unsupported platform for device ID');
        return null;
      }

      return _cachedDeviceId;
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      return null;
    }
  }

  /// Clear cached device ID (useful for testing)
  void clearCache() {
    _cachedDeviceId = null;
    debugPrint('Device ID cache cleared');
  }
}
