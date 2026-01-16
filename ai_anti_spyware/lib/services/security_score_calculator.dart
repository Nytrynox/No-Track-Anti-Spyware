import '../models/threat.dart';

class SecurityScoreCalculator {
  // Calculates an overall security score (0..100)
  // Inputs: current threats list; optional device risk modifiers in future
  static int calculate(List<Threat> threats) {
    if (threats.isEmpty) return 100;

    // Base deductions by severity
    double deduction = 0.0;
    for (final t in threats) {
      final sev = t.severity;
      final mitigatedFactor = t.mitigated
          ? 0.4
          : 1.0; // mitigated items count less
      switch (sev) {
        case ThreatSeverity.critical:
          deduction += 25 * mitigatedFactor;
          break;
        case ThreatSeverity.high:
          deduction += 15 * mitigatedFactor;
          break;
        case ThreatSeverity.medium:
          deduction += 8 * mitigatedFactor;
          break;
        case ThreatSeverity.low:
          deduction += 3 * mitigatedFactor;
          break;
      }
      // AI-like weighting based on tags and types
      if (t.tags.contains('C2 suspected')) deduction += 10 * mitigatedFactor;
      if (t.tags.contains('Beaconing')) deduction += 6 * mitigatedFactor;
      if (t.type == ThreatType.permissionAbuse) {
        deduction += 5 * mitigatedFactor;
      }
      if (t.tags.contains('Hidden app') ||
          t.tags.contains('Obfuscated package')) {
        deduction += 6 * mitigatedFactor;
      }
    }

    // Cap deduction and compute score
    deduction = deduction.clamp(0.0, 95.0);
    final score = (100 - deduction).round();
    // Minimum floor
    return score.clamp(0, 100);
  }
}
