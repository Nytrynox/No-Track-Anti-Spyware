import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';
import '../services/detection_service.dart';
import '../services/alert_service.dart';
import '../models/detection_result.dart';

/// Detection provider for managing AI detection state
class DetectionProvider with ChangeNotifier {
  final CameraService _cameraService = CameraService();
  final DetectionService _detectionService = DetectionService();
  final AlertService _alertService = AlertService();
  
  bool _isInitialized = false;
  bool _isRunning = false;
  bool _isProcessing = false;
  bool _detectionEnabled = true; // Master switch
  
  // Current detections
  List<DetectionResult> _detections = [];
  LaneDetection? _laneDetection;
  
  // Statistics
  int _totalDetections = 0;
  int _alertsTriggered = 0;
  
  // Subscriptions
  StreamSubscription? _frameSubscription;
  StreamSubscription? _detectionSubscription;
  StreamSubscription? _laneSubscription;
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isRunning => _isRunning;
  bool get isProcessing => _isProcessing;
  bool get detectionEnabled => _detectionEnabled;
  List<DetectionResult> get detections => _detectionEnabled ? _detections : [];
  LaneDetection? get laneDetection => _detectionEnabled ? _laneDetection : null;
  int get totalDetections => _totalDetections;
  int get alertsTriggered => _alertsTriggered;
  CameraController? get cameraController => _cameraService.controller;
  AlertService get alertService => _alertService;
  
  /// Set detection enabled/disabled
  void setDetectionEnabled(bool enabled) {
    _detectionEnabled = enabled;
    if (!enabled) {
      _detections = [];
      _laneDetection = null;
      if (_isRunning) {
        _detectionService.stopDetection();
        _isRunning = false;
      }
    } else if (_isInitialized && _cameraService.controller != null) {
      _detectionService.startDetection(_cameraService.controller!);
      _isRunning = true;
    }
    notifyListeners();
  }
  
  /// Initialize all services
  Future<bool> initialize() async {
    try {
      final cameraInit = await _cameraService.initialize();
      final detectionInit = await _detectionService.initialize();
      final alertInit = await _alertService.initialize();
      
      if (!cameraInit || !detectionInit || !alertInit) {
        debugPrint('Initialization failed: camera=$cameraInit, detection=$detectionInit, alert=$alertInit');
        return false;
      }
      
      // Subscribe to detection results
      _detectionSubscription = _detectionService.detectionStream.listen(_onDetections);
      _laneSubscription = _detectionService.laneStream.listen(_onLaneDetection);
      
      _isInitialized = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Provider init error: $e');
      return false;
    }
  }
  
  /// Start detection
  Future<void> start() async {
    if (!_isInitialized || _isRunning || !_detectionEnabled) return;
    
    if (_cameraService.controller != null) {
      _detectionService.startDetection(_cameraService.controller!);
    }
    
    _isRunning = true;
    notifyListeners();
    debugPrint('🎥 Detection provider started');
  }
  
  /// Stop detection
  Future<void> stop() async {
    _detectionService.stopDetection();
    _frameSubscription?.cancel();
    await _cameraService.stopStreaming();
    
    _isRunning = false;
    _detections = [];
    _laneDetection = null;
    notifyListeners();
    debugPrint('⏹️ Detection provider stopped');
  }
  
  void _onDetections(List<DetectionResult> results) {
    // Only process if detection is enabled
    if (!_detectionEnabled) {
      _detections = [];
      notifyListeners();
      return;
    }
    
    _detections = results;
    _totalDetections += results.length;
    
    // Check for dangerous situations and trigger alerts
    for (final detection in results) {
      final distance = detection.distance ?? 100;
      if (distance < 15) {
        _triggerCollisionAlert(detection);
      }
    }
    
    notifyListeners();
  }
  
  void _onLaneDetection(LaneDetection? lane) {
    if (!_detectionEnabled) {
      _laneDetection = null;
      notifyListeners();
      return;
    }
    
    final previousLane = _laneDetection;
    _laneDetection = lane;
    
    // Check for lane departure
    if (lane != null && lane.isLaneDeparture) {
      if (previousLane == null || !previousLane.isLaneDeparture) {
        _triggerLaneAlert(lane);
      }
    }
    
    notifyListeners();
  }
  
  void _triggerCollisionAlert(DetectionResult detection) {
    _alertsTriggered++;
    _alertService.collisionWarning(
      objectType: detection.displayLabel,
      distance: detection.distance,
    );
  }
  
  void _triggerLaneAlert(LaneDetection lane) {
    _alertsTriggered++;
    _alertService.laneDepartureWarning(
      direction: lane.positionDescription,
    );
  }
  
  /// Take a snapshot
  Future<XFile?> takeSnapshot() async {
    return await _cameraService.takePhoto();
  }
  
  /// Toggle camera
  Future<void> switchCamera() async {
    final wasRunning = _isRunning;
    if (wasRunning) await stop();
    
    await _cameraService.switchCamera();
    
    if (wasRunning && _detectionEnabled) await start();
  }
  
  /// Set confidence threshold
  void setConfidenceThreshold(double threshold) {
    _detectionService.setConfidenceThreshold(threshold);
  }
  
  @override
  void dispose() {
    stop();
    _frameSubscription?.cancel();
    _detectionSubscription?.cancel();
    _laneSubscription?.cancel();
    _cameraService.close();
    _detectionService.dispose();
    _alertService.dispose();
    super.dispose();
  }
}
