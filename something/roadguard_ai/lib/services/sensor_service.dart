import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Sensor service for crash detection and motion analysis
class SensorService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSub;
  
  bool _isInitialized = false;
  bool _isMonitoring = false;
  
  // Current sensor values
  double _accelerationMagnitude = 0;
  double _rotationRate = 0;
  
  // Crash detection thresholds
  final double _crashAccelerationThreshold = 30.0; // m/s²
  final double _crashRotationThreshold = 15.0; // rad/s
  
  // Fatigue detection
  int _straightLineCounter = 0;
  final int _fatigueThreshold = 600; // ~10 minutes at 1 update/second
  
  // Stream controllers
  final StreamController<bool> _crashController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _fatigueController =
      StreamController<bool>.broadcast();
  final StreamController<SensorData> _sensorDataController =
      StreamController<SensorData>.broadcast();
  
  /// Crash detection stream
  Stream<bool> get crashStream => _crashController.stream;
  
  /// Fatigue detection stream
  Stream<bool> get fatigueStream => _fatigueController.stream;
  
  /// Sensor data stream
  Stream<SensorData> get sensorDataStream => _sensorDataController.stream;
  
  bool get isInitialized => _isInitialized;
  bool get isMonitoring => _isMonitoring;
  
  /// Initialize sensor service
  Future<bool> initialize() async {
    try {
      // Test sensor availability
      accelerometerEventStream();
      gyroscopeEventStream();
      
      _isInitialized = true;
      debugPrint('Sensor service initialized');
      return true;
    } catch (e) {
      debugPrint('Sensor init error: $e');
      return false;
    }
  }
  
  /// Start sensor monitoring
  void startMonitoring() {
    if (!_isInitialized || _isMonitoring) return;
    
    // Accelerometer for crash detection
    _accelerometerSub = accelerometerEventStream().listen((event) {
      _processAccelerometerData(event);
    });
    
    // Gyroscope for rotation detection
    _gyroscopeSub = gyroscopeEventStream().listen((event) {
      _processGyroscopeData(event);
    });
    
    _isMonitoring = true;
    debugPrint('Sensor monitoring started');
  }
  
  /// Stop sensor monitoring
  void stopMonitoring() {
    _accelerometerSub?.cancel();
    _gyroscopeSub?.cancel();
    _accelerometerSub = null;
    _gyroscopeSub = null;
    _isMonitoring = false;
    _straightLineCounter = 0;
    debugPrint('Sensor monitoring stopped');
  }
  
  void _processAccelerometerData(AccelerometerEvent event) {
    // Calculate acceleration magnitude
    _accelerationMagnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    
    // Emit sensor data
    if (!_sensorDataController.isClosed) {
      _sensorDataController.add(SensorData(
        accelerationX: event.x,
        accelerationY: event.y,
        accelerationZ: event.z,
        accelerationMagnitude: _accelerationMagnitude,
        rotationRate: _rotationRate,
      ));
    }
    
    // Check for crash
    if (_accelerationMagnitude > _crashAccelerationThreshold) {
      _detectCrash();
    }
    
    // Fatigue detection - check if riding in straight line
    if (_rotationRate < 0.5 && _accelerationMagnitude < 12) {
      _straightLineCounter++;
      if (_straightLineCounter >= _fatigueThreshold) {
        _detectFatigue();
      }
    } else {
      _straightLineCounter = 0;
    }
  }
  
  void _processGyroscopeData(GyroscopeEvent event) {
    // Calculate rotation rate magnitude
    _rotationRate = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    
    // Check for sudden rotation (potential crash)
    if (_rotationRate > _crashRotationThreshold) {
      _detectCrash();
    }
  }
  
  void _detectCrash() {
    debugPrint('Crash detected! Accel: $_accelerationMagnitude, Rotation: $_rotationRate');
    if (!_crashController.isClosed) {
      _crashController.add(true);
    }
  }
  
  void _detectFatigue() {
    debugPrint('Fatigue pattern detected');
    if (!_fatigueController.isClosed) {
      _fatigueController.add(true);
    }
    _straightLineCounter = 0; // Reset after detection
  }
  
  /// Get current acceleration magnitude
  double get accelerationMagnitude => _accelerationMagnitude;
  
  /// Get current rotation rate
  double get rotationRate => _rotationRate;
  
  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _crashController.close();
    _fatigueController.close();
    _sensorDataController.close();
    debugPrint('Sensor service disposed');
  }
}

/// Sensor data container
class SensorData {
  final double accelerationX;
  final double accelerationY;
  final double accelerationZ;
  final double accelerationMagnitude;
  final double rotationRate;
  final DateTime timestamp;
  
  SensorData({
    required this.accelerationX,
    required this.accelerationY,
    required this.accelerationZ,
    required this.accelerationMagnitude,
    required this.rotationRate,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
