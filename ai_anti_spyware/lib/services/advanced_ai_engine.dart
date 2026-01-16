import 'dart:math';
import '../models/threat.dart';
import 'behavior_store.dart';
import 'platform/app_inspector.dart';
import 'platform/security_bridge.dart';

// Top-level helper for network sampling
class _NetSample {
  final DateTime t;
  final double rx;
  final double tx;
  _NetSample(this.t, this.rx, this.tx);
}

/// Advanced AI-powered spyware detection engine
/// Uses multi-layered analysis: heuristics, permissions, behavior patterns
class AdvancedAIEngine {
  late final AppInspector _inspector;
  // Per-package last network sample to compute deltas
  final Map<String, _NetSample> _lastNet = {};
  final BehaviorStore _store = BehaviorStore();

  // Risk weight matrices
  static const Map<String, double> _permissionRiskWeights = {
    'android.permission.READ_SMS': 2.5,
    'android.permission.SEND_SMS': 2.0,
    'android.permission.RECEIVE_SMS': 2.0,
    'android.permission.READ_CONTACTS': 1.8,
    'android.permission.WRITE_CONTACTS': 1.5,
    'android.permission.READ_CALL_LOG': 2.2,
    'android.permission.WRITE_CALL_LOG': 2.0,
    'android.permission.CALL_PHONE': 1.5,
    'android.permission.RECORD_AUDIO': 2.3,
    'android.permission.CAMERA': 1.7,
    'android.permission.ACCESS_FINE_LOCATION': 1.9,
    'android.permission.ACCESS_COARSE_LOCATION': 1.5,
    'android.permission.ACCESS_BACKGROUND_LOCATION': 2.4,
    'android.permission.SYSTEM_ALERT_WINDOW': 2.1,
    'android.permission.BIND_ACCESSIBILITY_SERVICE': 3.0,
    'android.permission.BIND_DEVICE_ADMIN': 2.8,
    'android.permission.REQUEST_INSTALL_PACKAGES': 2.5,
    'android.permission.PACKAGE_USAGE_STATS': 2.2,
  };

  static const List<String> _spywareKeywords = [
    'spy',
    'monitor',
    'track',
    'stealth',
    'hidden',
    'secret',
    'keylog',
    'surveillance',
    'watch',
    'detective',
    'inspect',
    'snoop',
    'eavesdrop',
    'intercept',
    'capture',
    'record',
  ];

  static const List<String> _trustedInstallers = [
    'com.android.vending', // Google Play Store
    'com.google.android.packageinstaller',
    'com.android.packageinstaller',
  ];

  Future<void> initialize() async {
    _inspector = createAppInspector();
    await _store.init();
  }

  /// Comprehensive security scan
  Future<List<Threat>> performDeepScan() async {
    final apps = await _inspector.getInstalledApps();
    final securityInfos = await PlatformSecurityBridge.getAllAppsSecurityInfo();

    final Map<String, Map<String, dynamic>> securityMap = {
      for (var info in securityInfos) info['packageName'] as String: info,
    };

    final List<Threat> threats = [];

    for (final app in apps) {
      final securityInfo = securityMap[app.packageName];
      final riskScore = await _calculateComprehensiveRisk(app, securityInfo);

      if (riskScore.score >= 0.5) {
        threats.add(_createThreat(app, riskScore));
      }
    }

    return threats..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  /// Quick scan focusing on high-risk indicators
  Future<List<Threat>> performQuickScan() async {
    final apps = await _inspector.getInstalledApps();
    final List<Threat> threats = [];

    for (final app in apps) {
      // Quick checks: name patterns and basic heuristics
      final nameRisk = _analyzeAppName(app.appName);
      final visibilityRisk = app.hasLauncher ? 0.0 : 1.5;

      final quickScore = (nameRisk + visibilityRisk) / 2;

      if (quickScore >= 0.6) {
        threats.add(
          Threat(
            id: 'pkg:${app.packageName}',
            detectedAt: DateTime.now(),
            severity: _severityFromScore(quickScore),
            type: ThreatType.spyware,
            title: 'Suspicious: ${app.appName}',
            description: 'Quick scan detected suspicious patterns',
            confidence: min(0.95, quickScore),
          ),
        );
      }
    }

    return threats;
  }

  Future<RiskScore> _calculateComprehensiveRisk(
    AppInfo app,
    Map<String, dynamic>? securityInfo,
  ) async {
    double totalScore = 0.0;
    final Map<String, double> factors = {};

    // 1. Name-based analysis
    final name = securityInfo != null
        ? (securityInfo['appLabel'] as String? ?? app.appName)
        : app.appName;
    final nameScore = _analyzeAppName(name);
    factors['name_risk'] = nameScore;
    totalScore += nameScore * 0.15;

    // 2. Visibility analysis
    final hasLauncher = securityInfo != null
        ? (securityInfo['hasLauncher'] as bool? ?? app.hasLauncher)
        : app.hasLauncher;
    final visibilityScore = hasLauncher ? 0.0 : 1.0;
    factors['hidden_launcher'] = visibilityScore;
    totalScore += visibilityScore * 0.20;

    // 2b. Package name obfuscation analysis
    final pkgObf = _analyzePackageName(app.packageName);
    if (pkgObf > 0) {
      factors['package_obfuscation'] = pkgObf;
      totalScore += pkgObf * 0.10;
    }

    // 3. System app analysis (system apps can be modified by spyware)
    final systemScore = app.systemApp ? 0.2 : 0.5;
    factors['system_app'] = systemScore;
    totalScore += systemScore * 0.05;

    if (securityInfo != null) {
      // 4. Permission risk analysis
      final dangerousPermissions =
          (securityInfo['dangerousPermissions'] as List?)?.cast<String>() ?? [];
      final permissionScore = _analyzePermissions(dangerousPermissions);
      factors['permission_risk'] = permissionScore;
      totalScore += permissionScore * 0.35;

      // Permission risk matrix emphasis for critical data exfil vectors
      final matrixBoost = _permissionMatrixBoost(dangerousPermissions);
      if (matrixBoost > 0) {
        factors['permission_matrix'] = matrixBoost;
        totalScore += matrixBoost * 0.10;
      }

      // 5. Install source analysis
      final installSource = securityInfo['installSource'] as String?;
      final sourceScore = _analyzeInstallSource(installSource);
      factors['install_source'] = sourceScore;
      totalScore += sourceScore * 0.15;

      // 6. Service/Receiver analysis (spyware often uses background components)
      final servicesCount = securityInfo['servicesCount'] as int? ?? 0;
      final receiversCount = securityInfo['receiversCount'] as int? ?? 0;
      final componentScore = _analyzeComponents(servicesCount, receiversCount);
      factors['components'] = componentScore;
      totalScore += componentScore * 0.10;

      // Hidden/disguised app detection: no launcher + benign name + background components
      final disguised = _detectDisguisedApp(
        hasLauncher,
        name,
        servicesCount,
        receiversCount,
      );
      if (disguised > 0) {
        factors['disguised_app'] = disguised;
        totalScore += disguised * 0.15;
      }

      // 7. Accessibility service enabled (common spyware vector)
      final isAccEnabled =
          securityInfo['isAccessibilityServiceEnabled'] as bool? ?? false;
      final hasAccService =
          securityInfo['hasAccessibilityService'] as bool? ?? false;
      final accScore = (isAccEnabled ? 1.0 : 0.0) * (hasAccService ? 1.0 : 0.6);
      if (hasAccService) {
        factors['accessibility_service'] = accScore;
        totalScore += accScore * 0.12; // prioritize if enabled
      }

      // 8. Network telemetry (sustained background traffic can be suspicious)
      final rx = (securityInfo['uidRxBytes'] as num?)?.toDouble() ?? 0.0;
      final tx = (securityInfo['uidTxBytes'] as num?)?.toDouble() ?? 0.0;
      final netScore = _analyzeNetworkDelta(app.packageName, rx, tx);
      if (netScore > 0) {
        factors['network_activity'] = netScore;
        totalScore += netScore * 0.08;
      }

      // Update baseline (even on first observation)
      await _store.upsertBaseline(
        pkg: app.packageName,
        permissions: dangerousPermissions,
        services: servicesCount,
        receivers: receiversCount,
        hasLauncher: hasLauncher,
        currentRate: null,
      );

      // Record network sample and compute anomaly vs. baseline if we have a previous sample
      final now = DateTime.now();
      final prev = _lastNet[app.packageName];
      if (prev != null) {
        final seconds = now.difference(prev.t).inSeconds.clamp(1, 3600);
        final drx = (rx - prev.rx).clamp(0, double.maxFinite);
        final dtx = (tx - prev.tx).clamp(0, double.maxFinite);
        final rate = (drx + dtx) / seconds;
        await _store.recordNetworkSample(
          app.packageName,
          RateSample(now, rate),
        );
        await _store.upsertBaseline(
          pkg: app.packageName,
          permissions: dangerousPermissions,
          services: servicesCount,
          receivers: receiversCount,
          hasLauncher: hasLauncher,
          currentRate: rate,
        );
        final anomaly = await _networkAnomalyScore(app.packageName, rate);
        if (anomaly > 0) {
          factors['network_anomaly'] = anomaly;
          totalScore += anomaly * 0.12;
        }
        final cnc = _cncSignalHeuristics(rate, hasLauncher, servicesCount);
        if (cnc > 0) {
          factors['cnc_signals'] = cnc;
          totalScore += cnc * 0.10;
        }

        // Beacon pattern over last few samples
        final beacon = await _beaconPatternScore(app.packageName);
        if (beacon > 0) {
          factors['beacon_pattern'] = beacon;
          totalScore += beacon * 0.08;
        }
      }

      // 9. Battery optimization exemption (can indicate persistent background behavior)
      final batteryExempt =
          securityInfo['batteryOptimizationExempt'] as bool? ?? false;
      if (batteryExempt) {
        factors['battery_optimization_exempt'] = 0.6;
        totalScore += 0.6 * 0.05;
      }
    }

    return RiskScore(
      score: totalScore.clamp(0.0, 1.0),
      factors: factors,
      packageName: app.packageName,
    );
  }

  // Detect package name obfuscation: long random last segment, high digit/rare char ratio
  double _analyzePackageName(String pkg) {
    final parts = pkg.split('.');
    if (parts.isEmpty) return 0.0;
    final tail = parts.last;
    if (tail.length < 5) return 0.0;
    final letters = RegExp(r'[a-z]');
    final digits = RegExp(r'\d');
    final others = RegExp(r'[^a-z0-9_]');
    final lower = tail.toLowerCase();
    int l = 0, d = 0;
    for (final c in lower.runes) {
      final ch = String.fromCharCode(c);
      if (letters.hasMatch(ch)) {
        l++;
      } else if (digits.hasMatch(ch)) {
        d++;
      } else if (others.hasMatch(ch)) {
        // ignore other chars but count impacts via unique ratio below
      }
    }
    final len = lower.length;
    final digitRatio = d / len;
    final letterRatio = l / len;
    // entropy approximation using variety of chars
    final unique = lower.split('').toSet().length;
    final uniqueRatio = unique / len;
    double score = 0.0;
    if (len >= 12) score += 0.2;
    if (digitRatio > 0.3) score += 0.35;
    if (uniqueRatio > 0.7) score += 0.25;
    if (letterRatio < 0.6) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  // Permission matrix boost targeting exfiltration vectors
  double _permissionMatrixBoost(List<String> perms) {
    final hasSms = perms.any((p) => p.contains('SMS'));
    final hasContacts = perms.contains('android.permission.READ_CONTACTS');
    final hasLocation = perms.any(
      (p) =>
          p.contains('ACCESS_FINE_LOCATION') ||
          p.contains('ACCESS_COARSE_LOCATION') ||
          p.contains('ACCESS_BACKGROUND_LOCATION'),
    );
    final hasMic = perms.contains('android.permission.RECORD_AUDIO');
    final hasCamera = perms.contains('android.permission.CAMERA');
    final hasCallLogs = perms.any((p) => p.contains('CALL_LOG'));

    double boost = 0.0;
    // Weigh combinations more than single permissions
    if (hasSms && hasContacts) boost += 0.25;
    if (hasLocation && (hasSms || hasContacts)) boost += 0.2;
    if (hasMic && hasCamera) boost += 0.25;
    if (hasCallLogs && (hasSms || hasContacts)) boost += 0.2;
    if (hasLocation && (hasMic || hasCamera)) boost += 0.1;
    return boost.clamp(0.0, 1.0);
  }

  // Detect disguised apps: hidden launcher, bland/system-like name, background components present
  double _detectDisguisedApp(
    bool hasLauncher,
    String appLabel,
    int services,
    int receivers,
  ) {
    final lower = appLabel.toLowerCase();
    final looksSystem =
        lower == 'system' ||
        lower == 'service' ||
        lower == 'android' ||
        lower.startsWith('com.android') ||
        lower.startsWith('google');
    final components = services + receivers;
    if (!hasLauncher && looksSystem && components >= 3) return 0.85;
    if (!hasLauncher && components >= 5) return 0.7;
    if (!hasLauncher && lower.length <= 3) return 0.6;
    return 0.0;
  }

  Future<double> _networkAnomalyScore(String pkg, double currentRate) async {
    final baseline = await _store.getBaseline(pkg);
    if (baseline == null) return 0.0;
    final avg = baseline.avgRate;
    if (avg <= 0) return 0.0;
    // Anomaly if current is significantly above baseline (3x -> 0.6, 8x -> 0.95)
    final ratio = currentRate / avg;
    if (ratio < 2.0) return 0.0;
    if (ratio >= 8.0) return 0.95;
    return 0.6 + (ratio - 3.0).clamp(0.0, 5.0) * (0.35 / 5.0);
  }

  // Primitive C&C signal heuristic without packet inspection: sustained background rate while hidden
  double _cncSignalHeuristics(double rate, bool hasLauncher, int services) {
    // Hidden apps with services and sustained rate may indicate C2
    const kb = 1024.0;
    if (!hasLauncher && services >= 2 && rate > 20 * kb) {
      if (rate > 200 * kb) return 0.85;
      return 0.6;
    }
    return 0.0;
  }

  // Beacon pattern: low variance, non-zero rates across recent samples
  Future<double> _beaconPatternScore(String pkg) async {
    final samples = await _store.getSamples(pkg);
    if (samples.length < 5) return 0.0;
    final rates = samples.map((s) => s.rate).toList();
    final mean = rates.reduce((a, b) => a + b) / rates.length;
    if (mean < 1024) return 0.0; // <1KB/s avg not interesting
    double variance = 0.0;
    for (final r in rates) {
      variance += (r - mean) * (r - mean);
    }
    variance /= rates.length;
    final std = sqrt(variance);
    // Low std relative to mean indicates stable periodic traffic
    final rel = std / mean;
    if (rel < 0.25) return 0.75;
    if (rel < 0.15) return 0.9;
    return 0.0;
  }

  double _analyzeAppName(String appName) {
    final nameLower = appName.toLowerCase();

    // Check for spyware keywords
    int keywordMatches = 0;
    for (final keyword in _spywareKeywords) {
      if (nameLower.contains(keyword)) {
        keywordMatches++;
      }
    }

    // Empty or very short names are suspicious
    if (appName.length <= 2) return 0.8;

    // Multiple keyword matches = very suspicious
    if (keywordMatches >= 2) return 0.95;
    if (keywordMatches == 1) return 0.75;

    // Generic suspicious patterns
    if (nameLower.contains('admin') ||
        nameLower.contains('system') ||
        nameLower.contains('service')) {
      return 0.4;
    }

    return 0.0;
  }

  double _analyzePermissions(List<String> dangerousPermissions) {
    if (dangerousPermissions.isEmpty) return 0.0;

    double totalRisk = 0.0;
    int count = 0;

    for (final perm in dangerousPermissions) {
      final weight = _permissionRiskWeights[perm] ?? 1.0;
      totalRisk += weight;
      count++;
    }

    // Normalize: many dangerous permissions = high risk
    if (count == 0) return 0.0;

    final avgRisk = totalRisk / count;
    final countFactor = min(1.0, count / 5.0); // 5+ dangerous perms = max

    return (avgRisk / 3.0 * 0.7 + countFactor * 0.3).clamp(0.0, 1.0);
  }

  double _analyzeInstallSource(String? source) {
    if (source == null || source == 'unknown') return 1.0;
    if (_trustedInstallers.contains(source)) return 0.1;
    return 0.6; // Third-party store
  }

  double _analyzeComponents(int services, int receivers) {
    // Many background services/receivers can indicate spyware
    final total = services + receivers;
    if (total == 0) return 0.0;
    if (total >= 10) return 0.9;
    if (total >= 5) return 0.6;
    return 0.3;
  }

  double _analyzeNetworkDelta(String pkg, double rxBytes, double txBytes) {
    final now = DateTime.now();
    final prev = _lastNet[pkg];
    _lastNet[pkg] = _NetSample(now, rxBytes, txBytes);
    if (prev == null) return 0.0; // need at least two samples
    final seconds = now.difference(prev.t).inSeconds.clamp(1, 3600);
    final drx = (rxBytes - prev.rx).clamp(0, double.maxFinite);
    final dtx = (txBytes - prev.tx).clamp(0, double.maxFinite);
    final rate = (drx + dtx) / seconds; // bytes/sec
    // Heuristic: <1KB/s -> 0, 1-50KB/s -> up to 0.5, 50KB/s-500KB/s -> up to 0.8, >500KB/s -> 0.95
    const kb = 1024.0;
    if (rate < 1 * kb) return 0.0;
    if (rate < 50 * kb) return 0.5 * ((rate - 1 * kb) / (49 * kb));
    if (rate < 500 * kb) return 0.5 + 0.3 * ((rate - 50 * kb) / (450 * kb));
    return 0.95;
  }

  Threat _createThreat(AppInfo app, RiskScore riskScore) {
    final severity = _severityFromScore(riskScore.score);
    final topFactors = riskScore.factors.entries
        .where((e) => e.value > 0.5)
        .map((e) => e.key)
        .take(3)
        .toList();

    final description = StringBuffer();
    description.write(
      'Risk score: ${(riskScore.score * 100).toStringAsFixed(0)}%. ',
    );

    if (topFactors.isNotEmpty) {
      description.write('Key factors: ${topFactors.join(", ")}. ');
    }

    description.write(
      'This app exhibits patterns commonly associated with spyware.',
    );

    final tags = <String>[];
    if ((riskScore.factors['accessibility_service'] ?? 0) > 0.5) {
      tags.add('Accessibility enabled');
    }
    if ((riskScore.factors['network_activity'] ?? 0) > 0.5) {
      tags.add('High background traffic');
    }
    if ((riskScore.factors['install_source'] ?? 0) > 0.5) {
      tags.add('Unknown installer');
    }
    if ((riskScore.factors['permission_risk'] ?? 0) > 0.7) {
      tags.add('Dangerous permissions');
    }
    if ((riskScore.factors['disguised_app'] ?? 0) > 0.6) {
      tags.add('Hidden app');
    }
    if ((riskScore.factors['package_obfuscation'] ?? 0) > 0.6) {
      tags.add('Obfuscated package');
    }
    if ((riskScore.factors['network_anomaly'] ?? 0) > 0.6) {
      tags.add('Anomalous network');
    }
    if ((riskScore.factors['cnc_signals'] ?? 0) > 0.6) {
      tags.add('C2 suspected');
    }
    if ((riskScore.factors['beacon_pattern'] ?? 0) > 0.6) {
      tags.add('Beaconing');
    }

    return Threat(
      id: 'pkg:${app.packageName}',
      detectedAt: DateTime.now(),
      severity: severity,
      type: _determineType(riskScore),
      title: 'Threat: ${app.appName}',
      description: description.toString(),
      confidence: min(0.98, riskScore.score),
      tags: tags,
    );
  }

  ThreatSeverity _severityFromScore(double score) {
    if (score >= 0.85) return ThreatSeverity.critical;
    if (score >= 0.70) return ThreatSeverity.high;
    if (score >= 0.55) return ThreatSeverity.medium;
    return ThreatSeverity.low;
  }

  ThreatType _determineType(RiskScore riskScore) {
    final factors = riskScore.factors;

    if ((factors['permission_risk'] ?? 0) > 0.7) {
      return ThreatType.permissionAbuse;
    }
    if ((factors['cnc_signals'] ?? 0) > 0.6 ||
        (factors['network_anomaly'] ?? 0) > 0.7) {
      return ThreatType.networkAnomaly;
    }
    if ((factors['hidden_launcher'] ?? 0) > 0.5) {
      return ThreatType.spyware;
    }
    if ((factors['package_obfuscation'] ?? 0) > 0.6 ||
        (factors['disguised_app'] ?? 0) > 0.6) {
      return ThreatType.spyware;
    }
    if ((factors['components'] ?? 0) > 0.6) {
      return ThreatType.spyware;
    }

    return ThreatType.unknown;
  }
}

class RiskScore {
  final double score;
  final Map<String, double> factors;
  final String packageName;

  RiskScore({
    required this.score,
    required this.factors,
    required this.packageName,
  });
}
