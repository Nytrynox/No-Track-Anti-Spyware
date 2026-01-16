import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

/// Settings provider for managing app preferences
class SettingsProvider with ChangeNotifier {
  static const String _settingsKey = 'app_settings';
  
  AppSettings _settings = AppSettings();
  bool _isLoaded = false;
  
  // Getters
  AppSettings get settings => _settings;
  bool get isLoaded => _isLoaded;
  
  // Quick access getters
  bool get objectDetectionEnabled => _settings.objectDetectionEnabled;
  bool get laneDetectionEnabled => _settings.laneDetectionEnabled;
  bool get voiceAlertsEnabled => _settings.voiceAlertsEnabled;
  bool get vibrationAlertsEnabled => _settings.vibrationAlertsEnabled;
  bool get soundAlertsEnabled => _settings.soundAlertsEnabled;
  bool get hudModeEnabled => _settings.hudModeEnabled;
  double get confidenceThreshold => _settings.confidenceThreshold;
  double get speedLimitWarning => _settings.speedLimitWarning;
  
  /// Load settings from storage
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final map = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings = AppSettings.fromJson(map);
      }
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      _settings = AppSettings();
      _isLoaded = true;
      notifyListeners();
    }
  }
  
  /// Save settings to storage
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }
  
  /// Update settings
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    notifyListeners();
  }
  
  // Individual setting updates
  
  Future<void> setObjectDetection(bool enabled) async {
    _settings = _settings.copyWith(objectDetectionEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setLaneDetection(bool enabled) async {
    _settings = _settings.copyWith(laneDetectionEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setTrafficSignDetection(bool enabled) async {
    _settings = _settings.copyWith(trafficSignEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setTrafficLightDetection(bool enabled) async {
    _settings = _settings.copyWith(trafficLightEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setConfidenceThreshold(double threshold) async {
    _settings = _settings.copyWith(confidenceThreshold: threshold);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setVoiceAlerts(bool enabled) async {
    _settings = _settings.copyWith(voiceAlertsEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setVibrationAlerts(bool enabled) async {
    _settings = _settings.copyWith(vibrationAlertsEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setSoundAlerts(bool enabled) async {
    _settings = _settings.copyWith(soundAlertsEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setVoiceLanguage(String language) async {
    _settings = _settings.copyWith(voiceLanguage: language);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setVoiceSpeed(double speed) async {
    _settings = _settings.copyWith(voiceSpeed: speed);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setAlertVolume(double volume) async {
    _settings = _settings.copyWith(alertVolume: volume);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setSpeedMonitoring(bool enabled) async {
    _settings = _settings.copyWith(speedMonitoringEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setSpeedLimitWarning(double limit) async {
    _settings = _settings.copyWith(speedLimitWarning: limit);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setDashCam(bool enabled) async {
    _settings = _settings.copyWith(dashCamEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setShowBoundingBoxes(bool show) async {
    _settings = _settings.copyWith(showBoundingBoxes: show);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setShowConfidence(bool show) async {
    _settings = _settings.copyWith(showConfidence: show);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setShowDistance(bool show) async {
    _settings = _settings.copyWith(showDistance: show);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setShowLaneLines(bool show) async {
    _settings = _settings.copyWith(showLaneLines: show);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setHudMode(bool enabled) async {
    _settings = _settings.copyWith(hudModeEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setCrashDetection(bool enabled) async {
    _settings = _settings.copyWith(crashDetectionEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setSOS(bool enabled) async {
    _settings = _settings.copyWith(sosEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setEmergencyContact(String? contact) async {
    _settings = _settings.copyWith(emergencyContact: contact);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setNightModeAuto(bool enabled) async {
    _settings = _settings.copyWith(nightModeAuto: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setWeatherIntegration(bool enabled) async {
    _settings = _settings.copyWith(weatherIntegrationEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setOfflineMode(bool enabled) async {
    _settings = _settings.copyWith(offlineModeEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  Future<void> setCloudBackup(bool enabled) async {
    _settings = _settings.copyWith(cloudBackupEnabled: enabled);
    await _saveSettings();
    notifyListeners();
  }
  
  /// Reset to defaults
  Future<void> resetToDefaults() async {
    _settings = AppSettings();
    await _saveSettings();
    notifyListeners();
  }
}
