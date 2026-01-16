import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/threat.dart';
import '../services/advanced_ai_engine.dart';
import '../services/notification_service.dart';
import '../services/platform/security_bridge.dart';
import '../services/persistence_service.dart';
import '../services/whitelist_service.dart';
import '../services/report_service.dart';

class ThreatProvider extends ChangeNotifier {
  final AdvancedAIEngine _engine = AdvancedAIEngine();
  final NotificationService _notifier;
  final PersistenceService _persistence = PersistenceService();
  final WhitelistService _whitelist = WhitelistService();

  ThreatProvider(this._notifier);

  final List<Threat> _threats = [];
  bool _monitoring = false;
  Timer? _timer;

  List<Threat> get threats => List.unmodifiable(_threats);
  bool get monitoring => _monitoring;

  Future<void> initialize() async {
    await _notifier.init();
    await _engine.initialize();
    await _persistence.init();
    await _whitelist.init();
    // Preload persisted threats
    final stored = await _persistence.getAllThreats();
    if (stored.isNotEmpty) {
      _threats.clear();
      _threats.addAll(stored);
    }
    // Start scheduled scans if configured (format: "every:Xh")
    final cron = await _persistence.getScanSchedule();
    if (cron != null && cron.startsWith('every:')) {
      final hours =
          int.tryParse(cron.substring('every:'.length).replaceAll('h', '')) ??
          0;
      if (hours > 0) _startScheduled(Duration(hours: hours));
    }
  }

  Future<void> scanNow() async {
    // Use only on-device, real data from platform bridge
    final found = await _engine.performDeepScan();
    final filtered = await _whitelist.filterThreats(found);
    if (filtered.isNotEmpty) {
      _threats.insertAll(0, filtered);
      await _persistence.addThreats(filtered);
      for (final t in filtered) {
        await _notifier.showThreat(
          'Threat: ${t.severity.name.toUpperCase()}',
          '${t.title} — ${(t.confidence * 100).toStringAsFixed(0)}% confidence',
        );
      }
      notifyListeners();
    }
  }

  void startMonitoring() {
    if (_monitoring) return;
    _monitoring = true;
    // Start native foreground monitoring service for persistence
    PlatformSecurityBridge.startMonitoringService();
    // Light-weight periodic quick scan using real data
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final found = await _engine.performQuickScan();
      final filtered = await _whitelist.filterThreats(found);
      if (filtered.isNotEmpty) {
        _threats.insertAll(0, filtered);
        await _persistence.addThreats(filtered);
        for (final t in filtered) {
          await _notifier.showThreat(
            'Threat: ${t.severity.name.toUpperCase()}',
            '${t.title} — ${(t.confidence * 100).toStringAsFixed(0)}% confidence',
          );
        }
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    _monitoring = false;
    PlatformSecurityBridge.stopMonitoringService();
    notifyListeners();
  }

  void _startScheduled(Duration interval) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      final found = await _engine.performDeepScan();
      final filtered = await _whitelist.filterThreats(found);
      if (filtered.isNotEmpty) {
        _threats.insertAll(0, filtered);
        await _persistence.addThreats(filtered);
        for (final t in filtered) {
          await _notifier.showThreat(
            'Threat: ${t.severity.name.toUpperCase()}',
            '${t.title} — ${(t.confidence * 100).toStringAsFixed(0)}% confidence',
          );
        }
        notifyListeners();
      }
    });
  }

  // Permissions audit: run deep scan and filter permission abuse threats
  Future<List<Threat>> runPermissionsAudit() async {
    final found = await _engine.performDeepScan();
    final audit = found
        .where((t) => t.type == ThreatType.permissionAbuse)
        .toList(growable: false);
    if (audit.isNotEmpty) {
      _threats.insertAll(0, audit);
      notifyListeners();
    }
    return audit;
  }

  // Deep scan extension: look for external APKs (side-loaded artifacts)
  Future<List<Threat>> scanExternalApks() async {
    final apks = await PlatformSecurityBridge.scanExternalApks();
    final List<Threat> newThreats = [];
    for (final apk in apks) {
      final pkg = apk['packageName'] as String? ?? 'unknown';
      final path = apk['path'] as String? ?? '';
      final t = Threat(
        id: 'apk:$path',
        detectedAt: DateTime.now(),
        severity: ThreatSeverity.medium,
        type: ThreatType.malware,
        title: 'Untrusted APK detected',
        description: pkg == 'unknown'
            ? 'APK at $path may be hidden or unsigned'
            : 'APK at $path claims package $pkg',
        confidence: 0.6,
        tags: const ['Side-loaded artifact'],
      );
      newThreats.add(t);
    }
    if (newThreats.isNotEmpty) {
      _threats.insertAll(0, newThreats);
      notifyListeners();
    }
    return newThreats;
  }

  void markMitigated(String id) {
    final idx = _threats.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _threats[idx] = _threats[idx].copyWith(mitigated: true);
      _persistence.markMitigated(id);
      notifyListeners();
    }
  }

  // Export utilities
  Future<String> exportJsonReport() async {
    return ReportService.toJsonReport(_threats);
  }

  Future<String> exportCsvReport() async {
    return ReportService.toCsvReport(_threats);
  }

  // Whitelist/Blacklist management passthroughs
  Future<void> addToWhitelist(String pkg) => _whitelist.addToWhitelist(pkg);
  Future<void> removeFromWhitelist(String pkg) =>
      _whitelist.removeFromWhitelist(pkg);
  Future<void> addToBlacklist(String pkg) => _whitelist.addToBlacklist(pkg);
  Future<void> removeFromBlacklist(String pkg) =>
      _whitelist.removeFromBlacklist(pkg);

  // Scheduled scans: store a cron-like string (e.g., "0 */6 * * *")
  Future<void> setScanSchedule(String cron) =>
      _persistence.setScanSchedule(cron);
  Future<String?> getScanSchedule() => _persistence.getScanSchedule();

  Map<ThreatSeverity, int> severityCounts() {
    final counts = {for (var s in ThreatSeverity.values) s: 0};
    for (final t in _threats) {
      counts[t.severity] = (counts[t.severity] ?? 0) + 1;
    }
    return counts;
  }
}
