import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'platform/app_inspector.dart';

import '../models/threat.dart';

class AIEngineService {
  Map<String, dynamic>? _heuristic;
  // Optional ML interpreter placeholder (removed for compatibility)
  // dynamic _interpreter;

  late final AppInspector _inspector;

  Future<void> initialize() async {
    _inspector = createAppInspector();
    // Load heuristic weights
    try {
      final txt = await rootBundle.loadString(
        'assets/models/heuristic_weights.json',
      );
      _heuristic = jsonDecode(txt) as Map<String, dynamic>;
    } catch (_) {
      _heuristic = null;
    }
    // Try to create a TFLite interpreter if a model is packaged later
    // Model interpreter initialization intentionally disabled for now.
  }

  Future<List<Threat>> scan() async {
    // Get installed apps via platform abstraction
    final apps = await _inspector.getInstalledApps();

    final List<Threat> threats = [];
    for (final app in apps) {
      final score = await _scoreApp(app);
      if (score >= 0.6) {
        threats.add(
          Threat(
            id: 'pkg:${app.packageName}',
            detectedAt: DateTime.now(),
            severity: _severityFromScore(score),
            type: ThreatType.spyware,
            title: 'Suspicious app: ${app.appName}',
            description:
                'Behavior and metadata indicate potential spyware activity (score ${(score * 100).toStringAsFixed(0)}%).',
            confidence: min(0.95, score),
          ),
        );
      }
    }
    return threats;
  }

  ThreatSeverity _severityFromScore(double s) {
    if (s > 0.85) return ThreatSeverity.critical;
    if (s > 0.75) return ThreatSeverity.high;
    if (s > 0.65) return ThreatSeverity.medium;
    return ThreatSeverity.low;
  }

  Future<double> _scoreApp(AppInfo app) async {
    final features = await _extractFeatures(app);
    // TFLite path (if model added later)
    // ML path removed; using heuristic path for now
    // Heuristic path
    if (_heuristic != null) {
      final weights = (_heuristic!["weights"] as List)
          .cast<num>()
          .map((e) => e.toDouble())
          .toList();
      final bias = (_heuristic!["bias"] as num).toDouble();
      final keys = (_heuristic!["features"] as List).cast<String>();
      double z = bias;
      for (int i = 0; i < keys.length && i < weights.length; i++) {
        z += (features[keys[i]] ?? 0.0) * weights[i];
      }
      // Sigmoid
      final score = 1.0 / (1.0 + exp(-z));
      return score;
    }
    // Fallback random-ish scoring when no model/heuristic loaded
    return (app.appName.hashCode % 100) / 100.0;
  }

  Future<Map<String, double>> _extractFeatures(AppInfo app) async {
    // Simple signals; can be expanded with platform channels for deeper telemetry
    final isSystem = app.systemApp == true;
    final hasLaunch = app.hasLauncher;
    final nameLower = app.appName.toLowerCase();
    final suspiciousNames = [
      'spy',
      'monitor',
      'track',
      'stealth',
      'sms',
      'keylog',
    ];
    final nameSuspicious = suspiciousNames.any((k) => nameLower.contains(k))
        ? 1.0
        : 0.0;

    // Approximate features (0/1 flags)
    return {
      'perm_contacts': nameLower.contains('contacts') ? 1.0 : 0.0,
      'perm_sms': nameLower.contains('sms') ? 1.0 : 0.0,
      'perm_usage_stats': isSystem ? 0.5 : 0.0,
      'bg_net_conn':
          0.5, // placeholder constant; replace with net stats if available
      'launcher_hidden': hasLaunch ? 0.0 : 1.0,
      'install_source_unknown':
          0.3, // placeholder until install source is queried
      'name_suspicious': nameSuspicious,
    };
  }
}
