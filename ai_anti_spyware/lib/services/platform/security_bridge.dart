import 'dart:io';
import 'package:flutter/services.dart';

class PlatformSecurityBridge {
  static const MethodChannel _channel = MethodChannel(
    'com.example.ai_anti_spyware/security',
  );

  /// Get detailed security info for a specific app
  static Future<Map<String, dynamic>?> getAppSecurityInfo(
    String packageName,
  ) async {
    if (!Platform.isAndroid) return null;
    try {
      final result = await _channel.invokeMethod('getAppSecurityInfo', {
        'packageName': packageName,
      });
      return result != null ? Map<String, dynamic>.from(result) : null;
    } catch (e) {
      return null;
    }
  }

  /// Get security info for all installed apps
  static Future<List<Map<String, dynamic>>> getAllAppsSecurityInfo() async {
    if (!Platform.isAndroid) return [];
    try {
      final result = await _channel.invokeMethod('getAllAppsSecurityInfo');
      if (result is List) {
        return result.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> startMonitoringService() async {
    if (!Platform.isAndroid) return false;
    try {
      final result = await _channel.invokeMethod('startMonitoringService');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> stopMonitoringService() async {
    if (!Platform.isAndroid) return false;
    try {
      final result = await _channel.invokeMethod('stopMonitoringService');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> scanExternalApks() async {
    if (!Platform.isAndroid) return [];
    try {
      final result = await _channel.invokeMethod('scanExternalApks');
      if (result is List) {
        return result.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
