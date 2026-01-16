/// App constants
class AppConstants {
  // App info
  static const String appName = 'RoadGuard AI';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your AI Road Safety Companion';
  
  // Detection settings
  static const double defaultConfidenceThreshold = 0.5;
  static const int defaultFrameInterval = 100; // ms between detections
  static const int maxDetectionsPerFrame = 10;
  
  // Distance thresholds (in meters)
  static const double dangerZoneDistance = 10.0;
  static const double warningZoneDistance = 25.0;
  static const double safeZoneDistance = 50.0;
  
  // Speed thresholds (in km/h)
  static const double maxSafeSpeed = 80.0;
  static const double schoolZoneSpeed = 40.0;
  
  // Alert settings
  static const int vibrationDuration = 500; // ms
  static const double alertCooldown = 2.0; // seconds between same alert
  
  // Lane detection
  static const double laneDeviationThreshold = 0.3; // 30% deviation triggers alert
  
  // Recording settings
  static const int maxRecordingMinutes = 60;
  static const String videoFormat = 'mp4';
  
  // Storage keys
  static const String settingsBox = 'settings';
  static const String tripsBox = 'trips';
  static const String alertsBox = 'alerts';
}

/// Alert types
enum AlertType {
  collision,
  laneDeparture,
  speedLimit,
  wrongWay,
  pedestrian,
  trafficLight,
  obstacle,
  pothole,
  fatigue,
  routeDeviation,
  emergency,
}

/// Detection labels
class DetectionLabels {
  static const Map<String, String> labels = {
    'person': 'Pedestrian',
    'bicycle': 'Bicycle',
    'car': 'Car',
    'motorcycle': 'Motorcycle',
    'bus': 'Bus',
    'truck': 'Truck',
    'traffic light': 'Traffic Light',
    'stop sign': 'Stop Sign',
    'dog': 'Animal',
    'cat': 'Animal',
    'cow': 'Animal',
  };
  
  static const List<String> highPriorityLabels = [
    'person',
    'bicycle',
    'car',
    'motorcycle',
    'bus',
    'truck',
  ];
  
  static const List<String> mediumPriorityLabels = [
    'traffic light',
    'stop sign',
  ];
  
  static const List<String> lowPriorityLabels = [
    'dog',
    'cat',
    'cow',
  ];
}

/// Vibration patterns for different alert types
class VibrationPatterns {
  static const List<int> collision = [0, 200, 100, 200, 100, 200];
  static const List<int> laneDeparture = [0, 300, 100, 300];
  static const List<int> speedLimit = [0, 500];
  static const List<int> warning = [0, 200, 100, 200];
  static const List<int> info = [0, 150];
}
