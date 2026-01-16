import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config/constants.dart';

/// Alert types
enum AlertCategory {
  collision,
  laneDeparture,
  speed,
  traffic,
  hazard,
  navigation,
  emergency,
  info,
}

/// Alert priority
enum AlertPriority {
  critical, // Immediate danger
  high,     // Urgent warning
  medium,   // Standard warning
  low,      // Informational
}

/// Alert data
class AlertData {
  final String id;
  final AlertCategory category;
  final AlertPriority priority;
  final String message;
  final String? voiceMessage;
  final DateTime timestamp;
  bool acknowledged;
  
  AlertData({
    String? id,
    required this.category,
    required this.priority,
    required this.message,
    this.voiceMessage,
    DateTime? timestamp,
    this.acknowledged = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       timestamp = timestamp ?? DateTime.now();
}

/// Alert service for voice, sound, and vibration alerts
class AlertService {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isInitialized = false;
  bool _isSpeaking = false;
  
  // Alert settings
  bool _voiceEnabled = true;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  double _voiceSpeed = 1.0;
  double _volume = 0.8;
  String _language = 'en-US';
  
  // Alert queue
  final List<AlertData> _alertQueue = [];
  Timer? _queueProcessor;
  
  // Cooldown tracking (prevent repeated alerts)
  final Map<String, DateTime> _alertCooldowns = {};
  final Duration _cooldownDuration = const Duration(seconds: 2);
  
  // Alert history
  final List<AlertData> _alertHistory = [];
  final int _maxHistorySize = 100;
  
  // Stream controller for UI updates
  final StreamController<AlertData> _alertController =
      StreamController<AlertData>.broadcast();
  
  Stream<AlertData> get alertStream => _alertController.stream;
  List<AlertData> get alertHistory => List.unmodifiable(_alertHistory);
  
  /// Initialize alert service
  Future<bool> initialize() async {
    try {
      // Initialize TTS
      await _tts.setLanguage(_language);
      await _tts.setSpeechRate(_voiceSpeed);
      await _tts.setVolume(_volume);
      await _tts.setPitch(1.0);
      
      // Set TTS callbacks
      _tts.setStartHandler(() {
        _isSpeaking = true;
      });
      
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        _processNextAlert();
      });
      
      _tts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        _isSpeaking = false;
      });
      
      // Check vibration capability
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (!hasVibrator) {
        _vibrationEnabled = false;
        debugPrint('Device does not support vibration');
      }
      
      // Start queue processor
      _queueProcessor = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => _processNextAlert(),
      );
      
      _isInitialized = true;
      debugPrint('Alert service initialized');
      return true;
    } catch (e) {
      debugPrint('Alert service init error: $e');
      return false;
    }
  }
  
  /// Update settings
  void updateSettings({
    bool? voiceEnabled,
    bool? vibrationEnabled,
    bool? soundEnabled,
    double? voiceSpeed,
    double? volume,
    String? language,
  }) {
    if (voiceEnabled != null) _voiceEnabled = voiceEnabled;
    if (vibrationEnabled != null) _vibrationEnabled = vibrationEnabled;
    if (soundEnabled != null) _soundEnabled = soundEnabled;
    
    if (voiceSpeed != null) {
      _voiceSpeed = voiceSpeed;
      _tts.setSpeechRate(_voiceSpeed);
    }
    
    if (volume != null) {
      _volume = volume;
      _tts.setVolume(_volume);
    }
    
    if (language != null) {
      _language = language;
      _tts.setLanguage(_language);
    }
  }
  
  /// Send an alert
  Future<void> alert({
    required AlertCategory category,
    required AlertPriority priority,
    required String message,
    String? voiceMessage,
    bool bypassCooldown = false,
  }) async {
    if (!_isInitialized) return;
    
    // Check cooldown
    final cooldownKey = '${category.name}_$message';
    if (!bypassCooldown && _isOnCooldown(cooldownKey)) {
      return;
    }
    
    final alertData = AlertData(
      category: category,
      priority: priority,
      message: message,
      voiceMessage: voiceMessage ?? message,
    );
    
    // Add to history
    _addToHistory(alertData);
    
    // Emit to stream
    if (!_alertController.isClosed) {
      _alertController.add(alertData);
    }
    
    // Handle based on priority
    if (priority == AlertPriority.critical) {
      // Critical alerts bypass queue
      await _executeAlert(alertData);
    } else {
      // Add to queue based on priority
      _addToQueue(alertData);
    }
    
    // Update cooldown
    _alertCooldowns[cooldownKey] = DateTime.now();
  }
  
  /// Collision warning
  Future<void> collisionWarning({String? objectType, double? distance}) async {
    final distanceText = distance != null 
        ? '${distance.toStringAsFixed(0)} meters ahead' 
        : 'ahead';
    
    final message = objectType != null
        ? '$objectType detected $distanceText!'
        : 'Collision warning! Object $distanceText';
    
    await alert(
      category: AlertCategory.collision,
      priority: distance != null && distance < 10 
          ? AlertPriority.critical 
          : AlertPriority.high,
      message: message,
      voiceMessage: 'Warning! $message',
    );
  }
  
  /// Lane departure warning
  Future<void> laneDepartureWarning({String? direction}) async {
    final message = direction != null
        ? 'Lane departure! Drifting $direction'
        : 'Lane departure warning!';
    
    await alert(
      category: AlertCategory.laneDeparture,
      priority: AlertPriority.high,
      message: message,
    );
  }
  
  /// Speed warning
  Future<void> speedWarning({double? currentSpeed, double? limit}) async {
    final message = limit != null
        ? 'Speed limit exceeded! ${currentSpeed?.toStringAsFixed(0)} km/h in ${limit.toStringAsFixed(0)} zone'
        : 'Reduce speed!';
    
    await alert(
      category: AlertCategory.speed,
      priority: AlertPriority.medium,
      message: message,
    );
  }
  
  /// Traffic light alert
  Future<void> trafficLightAlert({required String state}) async {
    await alert(
      category: AlertCategory.traffic,
      priority: state == 'red' ? AlertPriority.high : AlertPriority.medium,
      message: 'Traffic light: $state',
      voiceMessage: state == 'red' ? 'Red light ahead, stop!' : 'Traffic light $state',
    );
  }
  
  /// Navigation alert
  Future<void> navigationAlert({required String message}) async {
    await alert(
      category: AlertCategory.navigation,
      priority: AlertPriority.low,
      message: message,
    );
  }
  
  /// SOS emergency alert
  Future<void> sosAlert() async {
    await alert(
      category: AlertCategory.emergency,
      priority: AlertPriority.critical,
      message: 'SOS Emergency activated!',
      voiceMessage: 'Emergency SOS activated. Sending location to emergency contacts.',
      bypassCooldown: true,
    );
  }
  
  bool _isOnCooldown(String key) {
    final lastAlert = _alertCooldowns[key];
    if (lastAlert == null) return false;
    return DateTime.now().difference(lastAlert) < _cooldownDuration;
  }
  
  void _addToQueue(AlertData alert) {
    // Insert based on priority
    int insertIndex = _alertQueue.length;
    for (int i = 0; i < _alertQueue.length; i++) {
      if (alert.priority.index < _alertQueue[i].priority.index) {
        insertIndex = i;
        break;
      }
    }
    _alertQueue.insert(insertIndex, alert);
  }
  
  void _addToHistory(AlertData alert) {
    _alertHistory.insert(0, alert);
    if (_alertHistory.length > _maxHistorySize) {
      _alertHistory.removeLast();
    }
  }
  
  void _processNextAlert() {
    if (_isSpeaking || _alertQueue.isEmpty) return;
    
    final alert = _alertQueue.removeAt(0);
    _executeAlert(alert);
  }
  
  Future<void> _executeAlert(AlertData alert) async {
    // Vibration
    if (_vibrationEnabled) {
      await _vibrate(alert.priority, alert.category);
    }
    
    // Sound
    if (_soundEnabled) {
      await _playSound(alert.category);
    }
    
    // Voice
    if (_voiceEnabled && alert.voiceMessage != null) {
      await _speak(alert.voiceMessage!);
    }
  }
  
  Future<void> _vibrate(AlertPriority priority, AlertCategory category) async {
    try {
      List<int> pattern;
      
      switch (category) {
        case AlertCategory.collision:
          pattern = VibrationPatterns.collision;
          break;
        case AlertCategory.laneDeparture:
          pattern = VibrationPatterns.laneDeparture;
          break;
        case AlertCategory.speed:
          pattern = VibrationPatterns.speedLimit;
          break;
        case AlertCategory.emergency:
          pattern = VibrationPatterns.collision;
          break;
        default:
          pattern = priority == AlertPriority.critical
              ? VibrationPatterns.collision
              : VibrationPatterns.warning;
      }
      
      await Vibration.vibrate(pattern: pattern);
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }
  
  Future<void> _playSound(AlertCategory category) async {
    try {
      String soundFile;
      
      switch (category) {
        case AlertCategory.collision:
          soundFile = 'sounds/collision_warning.mp3';
          break;
        case AlertCategory.laneDeparture:
          soundFile = 'sounds/lane_departure.mp3';
          break;
        case AlertCategory.speed:
          soundFile = 'sounds/speed_alert.mp3';
          break;
        default:
          soundFile = 'sounds/speed_alert.mp3';
      }
      
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play(AssetSource(soundFile));
    } catch (e) {
      debugPrint('Sound playback error: $e');
    }
  }
  
  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _tts.stop();
    }
    
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS error: $e');
      _isSpeaking = false;
    }
  }
  
  /// Stop all alerts
  Future<void> stopAll() async {
    _alertQueue.clear();
    await _tts.stop();
    _isSpeaking = false;
    await _audioPlayer.stop();
  }
  
  /// Dispose resources
  void dispose() {
    _queueProcessor?.cancel();
    _alertController.close();
    _tts.stop();
    _audioPlayer.dispose();
    debugPrint('Alert service disposed');
  }
}
