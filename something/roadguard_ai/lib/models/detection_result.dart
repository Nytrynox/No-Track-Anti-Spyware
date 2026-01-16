import 'package:flutter/material.dart';

/// Detected object from AI model
class DetectionResult {
  final String label;
  final double confidence;
  final Rect boundingBox;
  final double? distance;
  final DateTime timestamp;
  
  DetectionResult({
    required this.label,
    required this.confidence,
    required this.boundingBox,
    this.distance,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// Get priority level (1 = highest, 3 = lowest)
  int get priority {
    const highPriority = ['person', 'bicycle', 'car', 'motorcycle', 'bus', 'truck'];
    const mediumPriority = ['traffic light', 'stop sign'];
    
    if (highPriority.contains(label.toLowerCase())) return 1;
    if (mediumPriority.contains(label.toLowerCase())) return 2;
    return 3;
  }
  
  /// Check if detection is in danger zone
  bool get isInDangerZone => distance != null && distance! < 10.0;
  
  /// Check if detection is in warning zone
  bool get isInWarningZone => distance != null && distance! >= 10.0 && distance! < 25.0;
  
  /// Get color based on distance
  Color get distanceColor {
    if (distance == null) return Colors.white;
    if (distance! < 10.0) return const Color(0xFFFF3366); // Danger
    if (distance! < 25.0) return const Color(0xFFFFB800); // Warning
    return const Color(0xFF00FF88); // Safe
  }
  
  /// Get human-readable label
  String get displayLabel {
    final labels = {
      'person': 'Pedestrian',
      'bicycle': 'Cyclist',
      'car': 'Vehicle',
      'motorcycle': 'Motorcycle',
      'bus': 'Bus',
      'truck': 'Truck',
      'traffic light': 'Traffic Light',
      'stop sign': 'Stop Sign',
      'dog': 'Animal',
      'cat': 'Animal',
      'cow': 'Animal',
    };
    return labels[label.toLowerCase()] ?? label;
  }
  
  @override
  String toString() => 'DetectionResult($label, ${(confidence * 100).toStringAsFixed(1)}%)';
  
  Map<String, dynamic> toJson() => {
    'label': label,
    'confidence': confidence,
    'boundingBox': {
      'left': boundingBox.left,
      'top': boundingBox.top,
      'right': boundingBox.right,
      'bottom': boundingBox.bottom,
    },
    'distance': distance,
    'timestamp': timestamp.toIso8601String(),
  };
  
  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    final bbox = json['boundingBox'] as Map<String, dynamic>;
    return DetectionResult(
      label: json['label'] as String,
      confidence: json['confidence'] as double,
      boundingBox: Rect.fromLTRB(
        bbox['left'] as double,
        bbox['top'] as double,
        bbox['right'] as double,
        bbox['bottom'] as double,
      ),
      distance: json['distance'] as double?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Lane detection result
class LaneDetection {
  final List<Offset> leftLane;
  final List<Offset> rightLane;
  final double deviation; // -1 to 1, 0 = centered
  final bool isValid;
  
  LaneDetection({
    required this.leftLane,
    required this.rightLane,
    required this.deviation,
    this.isValid = true,
  });
  
  /// Check if vehicle is departing from lane
  bool get isLaneDeparture => deviation.abs() > 0.3;
  
  /// Get lane position description
  String get positionDescription {
    if (deviation < -0.2) return 'Drifting Left';
    if (deviation > 0.2) return 'Drifting Right';
    return 'Centered';
  }
  
  /// Get color based on deviation
  Color get deviationColor {
    final absDeviation = deviation.abs();
    if (absDeviation > 0.3) return const Color(0xFFFF3366); // Danger
    if (absDeviation > 0.15) return const Color(0xFFFFB800); // Warning
    return const Color(0xFF00FF88); // Safe
  }
}

/// Traffic sign detection
class TrafficSign {
  final String type;
  final String? value; // e.g., speed limit value
  final Rect boundingBox;
  final double confidence;
  
  TrafficSign({
    required this.type,
    this.value,
    required this.boundingBox,
    required this.confidence,
  });
  
  /// Get display text
  String get displayText {
    if (value != null) return '$type: $value';
    return type;
  }
  
  /// Check if this is a speed limit sign
  bool get isSpeedLimit => type.toLowerCase().contains('speed');
  
  /// Get speed limit value if applicable
  int? get speedLimitValue {
    if (!isSpeedLimit || value == null) return null;
    return int.tryParse(value!.replaceAll(RegExp(r'[^0-9]'), ''));
  }
}

/// Traffic light state
enum TrafficLightState {
  red,
  yellow,
  green,
  unknown,
}

/// Traffic light detection
class TrafficLight {
  final TrafficLightState state;
  final Rect boundingBox;
  final double confidence;
  
  TrafficLight({
    required this.state,
    required this.boundingBox,
    required this.confidence,
  });
  
  Color get stateColor {
    switch (state) {
      case TrafficLightState.red:
        return const Color(0xFFFF3366);
      case TrafficLightState.yellow:
        return const Color(0xFFFFB800);
      case TrafficLightState.green:
        return const Color(0xFF00FF88);
      case TrafficLightState.unknown:
        return Colors.grey;
    }
  }
  
  String get stateText {
    switch (state) {
      case TrafficLightState.red:
        return 'STOP';
      case TrafficLightState.yellow:
        return 'CAUTION';
      case TrafficLightState.green:
        return 'GO';
      case TrafficLightState.unknown:
        return '---';
    }
  }
}
