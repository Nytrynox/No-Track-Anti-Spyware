enum ThreatSeverity { low, medium, high, critical }

enum ThreatType { spyware, malware, networkAnomaly, permissionAbuse, unknown }

class Threat {
  final String id;
  final DateTime detectedAt;
  final ThreatSeverity severity;
  final ThreatType type;
  final String title;
  final String description;
  final double confidence; // 0..1
  final bool mitigated;
  final List<String> tags;

  Threat({
    required this.id,
    required this.detectedAt,
    required this.severity,
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    this.mitigated = false,
    this.tags = const [],
  });

  Threat copyWith({bool? mitigated, List<String>? tags}) => Threat(
    id: id,
    detectedAt: detectedAt,
    severity: severity,
    type: type,
    title: title,
    description: description,
    confidence: confidence,
    mitigated: mitigated ?? this.mitigated,
    tags: tags ?? this.tags,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'detectedAt': detectedAt.millisecondsSinceEpoch,
    'severity': severity.name,
    'type': type.name,
    'title': title,
    'description': description,
    'confidence': confidence,
    'mitigated': mitigated,
    'tags': tags,
  };

  static Threat fromJson(Map<String, dynamic> m) => Threat(
    id: m['id'] as String,
    detectedAt: DateTime.fromMillisecondsSinceEpoch(
      (m['detectedAt'] as num).toInt(),
    ),
    severity: ThreatSeverity.values.firstWhere(
      (e) => e.name == (m['severity'] as String),
    ),
    type: ThreatType.values.firstWhere((e) => e.name == (m['type'] as String)),
    title: m['title'] as String,
    description: m['description'] as String,
    confidence: (m['confidence'] as num).toDouble(),
    mitigated: (m['mitigated'] as bool?) ?? false,
    tags: ((m['tags'] as List?) ?? const <dynamic>[]).cast<String>(),
  );
}
