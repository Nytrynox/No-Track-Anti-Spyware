import 'package:uuid/uuid.dart';

/// Trip record
class Trip {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final List<TripPoint> points;
  final List<TripAlert> alerts;
  double totalDistance; // in meters
  double maxSpeed; // in km/h
  double avgSpeed; // in km/h
  int safetyScore; // 0-100
  
  Trip({
    String? id,
    required this.startTime,
    this.endTime,
    List<TripPoint>? points,
    List<TripAlert>? alerts,
    this.totalDistance = 0,
    this.maxSpeed = 0,
    this.avgSpeed = 0,
    this.safetyScore = 100,
  }) : id = id ?? const Uuid().v4(),
       points = points ?? [],
       alerts = alerts ?? [];
  
  /// Check if trip is active
  bool get isActive => endTime == null;
  
  /// Get trip duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
  
  /// Get formatted duration
  String get formattedDuration {
    final d = duration;
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes % 60}m';
    }
    return '${d.inMinutes}m ${d.inSeconds % 60}s';
  }
  
  /// Get formatted distance
  String get formattedDistance {
    if (totalDistance >= 1000) {
      return '${(totalDistance / 1000).toStringAsFixed(1)} km';
    }
    return '${totalDistance.toStringAsFixed(0)} m';
  }
  
  /// Get safety grade
  String get safetyGrade {
    if (safetyScore >= 90) return 'A';
    if (safetyScore >= 80) return 'B';
    if (safetyScore >= 70) return 'C';
    if (safetyScore >= 60) return 'D';
    return 'F';
  }
  
  /// Add a point to the trip
  void addPoint(TripPoint point) {
    if (points.isNotEmpty) {
      final lastPoint = points.last;
      totalDistance += _calculateDistance(
        lastPoint.latitude, lastPoint.longitude,
        point.latitude, point.longitude,
      );
    }
    
    if (point.speed > maxSpeed) {
      maxSpeed = point.speed;
    }
    
    points.add(point);
    _updateAvgSpeed();
  }
  
  /// Add an alert to the trip
  void addAlert(TripAlert alert) {
    alerts.add(alert);
    _updateSafetyScore();
  }
  
  /// End the trip
  void end() {
    endTime = DateTime.now();
  }
  
  void _updateAvgSpeed() {
    if (points.isEmpty) return;
    avgSpeed = points.map((p) => p.speed).reduce((a, b) => a + b) / points.length;
  }
  
  void _updateSafetyScore() {
    // Deduct points for each alert based on severity
    int deductions = 0;
    for (final alert in alerts) {
      switch (alert.severity) {
        case AlertSeverity.critical:
          deductions += 10;
          break;
        case AlertSeverity.warning:
          deductions += 5;
          break;
        case AlertSeverity.info:
          deductions += 2;
          break;
      }
    }
    safetyScore = (100 - deductions).clamp(0, 100);
  }
  
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula for distance calculation
    const double earthRadius = 6371000; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
        _sin(dLon / 2) * _sin(dLon / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  double _toRadians(double degree) => degree * 3.141592653589793 / 180;
  double _sin(double x) => _sine(x);
  double _cos(double x) => _sine(x + 1.5707963267948966);
  double _sqrt(double x) => x > 0 ? _newtonSqrt(x) : 0;
  double _atan2(double y, double x) => _arctan2(y, x);
  
  double _sine(double x) {
    x = x % 6.283185307179586;
    if (x < 0) x += 6.283185307179586;
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / (2 * i * (2 * i + 1));
      result += term;
    }
    return result;
  }
  
  double _newtonSqrt(double n) {
    double x = n;
    for (int i = 0; i < 10; i++) {
      x = (x + n / x) / 2;
    }
    return x;
  }
  
  double _arctan2(double y, double x) {
    if (x > 0) return _arctan(y / x);
    if (x < 0 && y >= 0) return _arctan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _arctan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 1.5707963267948966;
    if (x == 0 && y < 0) return -1.5707963267948966;
    return 0;
  }
  
  double _arctan(double x) {
    double result = x;
    double term = x;
    for (int i = 1; i <= 15; i++) {
      term *= -x * x * (2 * i - 1) / (2 * i + 1);
      result += term / (2 * i + 1);
    }
    return result;
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'points': points.map((p) => p.toJson()).toList(),
    'alerts': alerts.map((a) => a.toJson()).toList(),
    'totalDistance': totalDistance,
    'maxSpeed': maxSpeed,
    'avgSpeed': avgSpeed,
    'safetyScore': safetyScore,
  };
  
  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
    points: (json['points'] as List).map((p) => TripPoint.fromJson(p)).toList(),
    alerts: (json['alerts'] as List).map((a) => TripAlert.fromJson(a)).toList(),
    totalDistance: json['totalDistance'] as double,
    maxSpeed: json['maxSpeed'] as double,
    avgSpeed: json['avgSpeed'] as double,
    safetyScore: json['safetyScore'] as int,
  );
}

/// Trip point (GPS location)
class TripPoint {
  final double latitude;
  final double longitude;
  final double speed; // km/h
  final double heading; // degrees
  final DateTime timestamp;
  
  TripPoint({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'speed': speed,
    'heading': heading,
    'timestamp': timestamp.toIso8601String(),
  };
  
  factory TripPoint.fromJson(Map<String, dynamic> json) => TripPoint(
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    speed: json['speed'] as double,
    heading: json['heading'] as double,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

/// Alert severity
enum AlertSeverity { critical, warning, info }

/// Trip alert
class TripAlert {
  final String id;
  final String type;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  
  TripAlert({
    String? id,
    required this.type,
    required this.message,
    required this.severity,
    DateTime? timestamp,
    this.latitude,
    this.longitude,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'message': message,
    'severity': severity.name,
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
  };
  
  factory TripAlert.fromJson(Map<String, dynamic> json) => TripAlert(
    id: json['id'] as String,
    type: json['type'] as String,
    message: json['message'] as String,
    severity: AlertSeverity.values.firstWhere((s) => s.name == json['severity']),
    timestamp: DateTime.parse(json['timestamp'] as String),
    latitude: json['latitude'] as double?,
    longitude: json['longitude'] as double?,
  );
}
