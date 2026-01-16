import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/trip.dart';

/// Location service for GPS tracking and route monitoring
class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  Position? _lastPosition;
  
  bool _isInitialized = false;
  bool _isTracking = false;
  
  // Speed calculation
  double _currentSpeed = 0; // km/h
  double _heading = 0; // degrees
  
  // Route deviation tracking
  List<Position>? _plannedRoute;
  double _routeDeviationThreshold = 100; // meters
  
  // Stream controllers
  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();
  final StreamController<double> _speedController =
      StreamController<double>.broadcast();
  final StreamController<bool> _routeDeviationController =
      StreamController<bool>.broadcast();
  
  /// Stream of position updates
  Stream<Position> get positionStream => _positionController.stream;
  
  /// Stream of speed updates
  Stream<double> get speedStream => _speedController.stream;
  
  /// Stream of route deviation alerts
  Stream<bool> get routeDeviationStream => _routeDeviationController.stream;
  
  /// Current position
  Position? get currentPosition => _currentPosition;
  
  /// Current speed in km/h
  double get currentSpeed => _currentSpeed;
  
  /// Current heading in degrees
  double get heading => _heading;
  
  /// Check if initialized
  bool get isInitialized => _isInitialized;
  
  /// Check if tracking
  bool get isTracking => _isTracking;
  
  /// Initialize location service
  Future<bool> initialize() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return false;
      }
      
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied');
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied');
        return false;
      }
      
      // Get initial position
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      _isInitialized = true;
      debugPrint('Location service initialized');
      return true;
    } catch (e) {
      debugPrint('Location init error: $e');
      return false;
    }
  }
  
  /// Start continuous location tracking
  Future<void> startTracking() async {
    if (!_isInitialized || _isTracking) return;
    
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5, // Update every 5 meters
      );
      
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        _updatePosition(position);
      });
      
      _isTracking = true;
      debugPrint('Location tracking started');
    } catch (e) {
      debugPrint('Start tracking error: $e');
    }
  }
  
  /// Stop location tracking
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    debugPrint('Location tracking stopped');
  }
  
  void _updatePosition(Position position) {
    _lastPosition = _currentPosition;
    _currentPosition = position;
    
    // Update heading
    _heading = position.heading;
    
    // Calculate speed
    if (position.speed >= 0) {
      // GPS-provided speed (m/s to km/h)
      _currentSpeed = position.speed * 3.6;
    } else if (_lastPosition != null) {
      // Calculate speed from distance and time
      _currentSpeed = _calculateSpeed(_lastPosition!, position);
    }
    
    // Emit position
    if (!_positionController.isClosed) {
      _positionController.add(position);
    }
    
    // Emit speed
    if (!_speedController.isClosed) {
      _speedController.add(_currentSpeed);
    }
    
    // Check route deviation
    if (_plannedRoute != null && _plannedRoute!.isNotEmpty) {
      _checkRouteDeviation(position);
    }
  }
  
  double _calculateSpeed(Position from, Position to) {
    final distance = Geolocator.distanceBetween(
      from.latitude, from.longitude,
      to.latitude, to.longitude,
    );
    
    final timeDiff = to.timestamp.difference(from.timestamp).inMilliseconds;
    if (timeDiff <= 0) return 0;
    
    // m/ms to km/h
    return (distance / timeDiff) * 3600000;
  }
  
  /// Set planned route for deviation detection
  void setPlannedRoute(List<Position> route) {
    _plannedRoute = route;
  }
  
  /// Clear planned route
  void clearPlannedRoute() {
    _plannedRoute = null;
  }
  
  void _checkRouteDeviation(Position currentPos) {
    if (_plannedRoute == null || _plannedRoute!.isEmpty) return;
    
    // Find minimum distance to any point on the route
    double minDistance = double.infinity;
    
    for (final routePoint in _plannedRoute!) {
      final distance = Geolocator.distanceBetween(
        currentPos.latitude, currentPos.longitude,
        routePoint.latitude, routePoint.longitude,
      );
      
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
    
    // Check if deviated from route
    final isDeviated = minDistance > _routeDeviationThreshold;
    
    if (!_routeDeviationController.isClosed) {
      _routeDeviationController.add(isDeviated);
    }
  }
  
  /// Calculate distance between two points
  double distanceTo(double lat, double lng) {
    if (_currentPosition == null) return 0;
    
    return Geolocator.distanceBetween(
      _currentPosition!.latitude, _currentPosition!.longitude,
      lat, lng,
    );
  }
  
  /// Calculate bearing to destination
  double bearingTo(double lat, double lng) {
    if (_currentPosition == null) return 0;
    
    return Geolocator.bearingBetween(
      _currentPosition!.latitude, _currentPosition!.longitude,
      lat, lng,
    );
  }
  
  /// Get trip point from current position
  TripPoint? getCurrentTripPoint() {
    if (_currentPosition == null) return null;
    
    return TripPoint(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      speed: _currentSpeed,
      heading: _heading,
    );
  }
  
  /// Open location settings
  Future<bool> openSettings() async {
    return await Geolocator.openLocationSettings();
  }
  
  /// Dispose resources
  void dispose() {
    stopTracking();
    _positionController.close();
    _speedController.close();
    _routeDeviationController.close();
    debugPrint('Location service disposed');
  }
}
