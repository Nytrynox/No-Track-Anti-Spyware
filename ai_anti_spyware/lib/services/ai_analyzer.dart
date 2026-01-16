import 'dart:math';

import '../models/threat.dart';

/// Mock AI analyzer that simulates behavioral anomaly detection.
/// In a real product, this would run on-device ML models and system telemetry.
class AIAnalyzerService {
  final Random _rng = Random();

  /// Simulate a scan over recent telemetry and produce 0..N threats
  Future<List<Threat>> runScan() async {
    await Future.delayed(const Duration(seconds: 1));
    final n = _rng.nextInt(3); // 0-2 threats per scan
    return List.generate(n, (i) => _randomThreat(i));
  }

  /// Continuous monitoring tick
  Future<List<Threat>> monitorTick() async {
    // Lower chance to detect during passive monitoring
    if (_rng.nextDouble() < 0.2) {
      return [_randomThreat(0)];
    }
    return [];
  }

  Threat _randomThreat(int i) {
    final severities = ThreatSeverity.values;
    final types = ThreatType.values;
    return Threat(
      id: '${DateTime.now().millisecondsSinceEpoch}_$i',
      detectedAt: DateTime.now(),
      severity: severities[_rng.nextInt(severities.length)],
      type: types[_rng.nextInt(types.length)],
      title: 'Anomaly ${_rng.nextInt(9999)}',
      description:
          'Behavioral anomaly detected in background process. Potential spyware signature overlap.',
      confidence: 0.6 + _rng.nextDouble() * 0.4,
    );
  }
}
