import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/location_service.dart';
import '../services/sensor_service.dart';
import '../models/trip.dart';

/// Trip provider for managing ride sessions
class TripProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final SensorService _sensorService = SensorService();
  
  bool _isInitialized = false;
  
  // Current trip
  Trip? _currentTrip;
  bool _isRiding = false;
  
  // Real-time data
  double _currentSpeed = 0;
  double _heading = 0;
  
  // Trip history
  final List<Trip> _tripHistory = [];
  
  // Subscriptions
  StreamSubscription? _positionSubscription;
  StreamSubscription? _speedSubscription;
  StreamSubscription? _crashSubscription;
  StreamSubscription? _fatigueSubscription;
  
  // Callbacks for alerts
  Function(String message)? onCrashDetected;
  Function(String message)? onFatigueDetected;
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isRiding => _isRiding;
  Trip? get currentTrip => _currentTrip;
  double get currentSpeed => _currentSpeed;
  double get heading => _heading;
  List<Trip> get tripHistory => List.unmodifiable(_tripHistory);
  
  /// Initialize services
  Future<bool> initialize() async {
    try {
      final locationInit = await _locationService.initialize();
      final sensorInit = await _sensorService.initialize();
      
      if (!locationInit) {
        debugPrint('Location service failed to initialize');
        return false;
      }
      
      // Sensor is optional
      if (!sensorInit) {
        debugPrint('Sensor service failed - crash detection disabled');
      }
      
      // Subscribe to speed updates
      _speedSubscription = _locationService.speedStream.listen((speed) {
        _currentSpeed = speed;
        notifyListeners();
      });
      
      // Subscribe to crash detection
      _crashSubscription = _sensorService.crashStream.listen((_) {
        _onCrashDetected();
      });
      
      // Subscribe to fatigue detection
      _fatigueSubscription = _sensorService.fatigueStream.listen((_) {
        _onFatigueDetected();
      });
      
      _isInitialized = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Trip provider init error: $e');
      return false;
    }
  }
  
  /// Start a new ride
  Future<void> startRide() async {
    if (!_isInitialized || _isRiding) return;
    
    // Create new trip
    _currentTrip = Trip(startTime: DateTime.now());
    
    // Start location tracking
    await _locationService.startTracking();
    
    // Start sensor monitoring
    _sensorService.startMonitoring();
    
    // Subscribe to position updates
    _positionSubscription = _locationService.positionStream.listen((position) {
      final tripPoint = _locationService.getCurrentTripPoint();
      if (tripPoint != null && _currentTrip != null) {
        _currentTrip!.addPoint(tripPoint);
        _heading = position.heading;
        notifyListeners();
      }
    });
    
    _isRiding = true;
    notifyListeners();
    debugPrint('Ride started');
  }
  
  /// End current ride
  Future<Trip?> endRide() async {
    if (!_isRiding || _currentTrip == null) return null;
    
    // Stop tracking
    await _locationService.stopTracking();
    _sensorService.stopMonitoring();
    _positionSubscription?.cancel();
    
    // Finalize trip
    _currentTrip!.end();
    
    // Save to history
    final completedTrip = _currentTrip!;
    _tripHistory.insert(0, completedTrip);
    
    _currentTrip = null;
    _isRiding = false;
    notifyListeners();
    
    debugPrint('Ride ended: ${completedTrip.formattedDistance}, ${completedTrip.formattedDuration}');
    return completedTrip;
  }
  
  /// Add alert to current trip
  void addAlert(TripAlert alert) {
    if (_currentTrip == null) return;
    _currentTrip!.addAlert(alert);
    notifyListeners();
  }
  
  void _onCrashDetected() {
    debugPrint('Crash detected!');
    
    if (_currentTrip != null) {
      final alert = TripAlert(
        type: 'crash',
        message: 'Potential crash detected',
        severity: AlertSeverity.critical,
        latitude: _locationService.currentPosition?.latitude,
        longitude: _locationService.currentPosition?.longitude,
      );
      _currentTrip!.addAlert(alert);
    }
    
    onCrashDetected?.call('Crash detected! Are you okay?');
    notifyListeners();
  }
  
  void _onFatigueDetected() {
    debugPrint('Fatigue pattern detected');
    
    if (_currentTrip != null) {
      final alert = TripAlert(
        type: 'fatigue',
        message: 'Fatigue pattern detected - consider taking a break',
        severity: AlertSeverity.warning,
      );
      _currentTrip!.addAlert(alert);
    }
    
    onFatigueDetected?.call('You\'ve been riding for a while. Consider taking a break.');
    notifyListeners();
  }
  
  /// Get trip statistics
  Map<String, dynamic> getTripStats() {
    if (_tripHistory.isEmpty) {
      return {
        'totalTrips': 0,
        'totalDistance': 0.0,
        'totalDuration': Duration.zero,
        'avgSafetyScore': 0,
        'bestSafetyScore': 0,
      };
    }
    
    final totalDistance = _tripHistory.fold<double>(
      0, (sum, trip) => sum + trip.totalDistance,
    );
    
    final totalDuration = _tripHistory.fold<Duration>(
      Duration.zero, (sum, trip) => sum + trip.duration,
    );
    
    final avgSafetyScore = _tripHistory.fold<int>(
      0, (sum, trip) => sum + trip.safetyScore,
    ) ~/ _tripHistory.length;
    
    final bestSafetyScore = _tripHistory.fold<int>(
      0, (best, trip) => trip.safetyScore > best ? trip.safetyScore : best,
    );
    
    return {
      'totalTrips': _tripHistory.length,
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'avgSafetyScore': avgSafetyScore,
      'bestSafetyScore': bestSafetyScore,
    };
  }
  
  /// Clear trip history
  void clearHistory() {
    _tripHistory.clear();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _positionSubscription?.cancel();
    _speedSubscription?.cancel();
    _crashSubscription?.cancel();
    _fatigueSubscription?.cancel();
    _locationService.dispose();
    _sensorService.dispose();
    super.dispose();
  }
}
