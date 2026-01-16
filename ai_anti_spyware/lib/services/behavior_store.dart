import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RateSample {
  final DateTime t;
  final double rate; // bytes/sec
  RateSample(this.t, this.rate);

  Map<String, dynamic> toJson() => {'t': t.millisecondsSinceEpoch, 'r': rate};

  static RateSample fromJson(Map<String, dynamic> m) => RateSample(
    DateTime.fromMillisecondsSinceEpoch(m['t'] as int),
    (m['r'] as num).toDouble(),
  );
}

class AppBaseline {
  final String packageName;
  final List<String> permissions; // last seen dangerous permissions
  final int servicesCount;
  final int receiversCount;
  final bool hasLauncher;
  final double avgRate; // smoothed bytes/sec
  final DateTime firstSeen;
  final DateTime lastUpdated;

  AppBaseline({
    required this.packageName,
    required this.permissions,
    required this.servicesCount,
    required this.receiversCount,
    required this.hasLauncher,
    required this.avgRate,
    required this.firstSeen,
    required this.lastUpdated,
  });

  AppBaseline copyWith({
    List<String>? permissions,
    int? servicesCount,
    int? receiversCount,
    bool? hasLauncher,
    double? avgRate,
    DateTime? lastUpdated,
  }) {
    return AppBaseline(
      packageName: packageName,
      permissions: permissions ?? this.permissions,
      servicesCount: servicesCount ?? this.servicesCount,
      receiversCount: receiversCount ?? this.receiversCount,
      hasLauncher: hasLauncher ?? this.hasLauncher,
      avgRate: avgRate ?? this.avgRate,
      firstSeen: firstSeen,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => {
    'packageName': packageName,
    'permissions': permissions,
    'servicesCount': servicesCount,
    'receiversCount': receiversCount,
    'hasLauncher': hasLauncher,
    'avgRate': avgRate,
    'firstSeen': firstSeen.millisecondsSinceEpoch,
    'lastUpdated': lastUpdated.millisecondsSinceEpoch,
  };

  static AppBaseline fromJson(Map<String, dynamic> m) => AppBaseline(
    packageName: m['packageName'] as String,
    permissions: (m['permissions'] as List).cast<String>(),
    servicesCount: m['servicesCount'] as int,
    receiversCount: m['receiversCount'] as int,
    hasLauncher: m['hasLauncher'] as bool,
    avgRate: (m['avgRate'] as num).toDouble(),
    firstSeen: DateTime.fromMillisecondsSinceEpoch(
      (m['firstSeen'] as num).toInt(),
    ),
    lastUpdated: DateTime.fromMillisecondsSinceEpoch(
      (m['lastUpdated'] as num).toInt(),
    ),
  );
}

class BehaviorStore {
  static const _baselinePrefix = 'bs_';
  static const _samplesPrefix = 'ns_';
  static const _samplesLimit = 10;

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<AppBaseline?> getBaseline(String pkg) async {
    await init();
    final s = _prefs!.getString('$_baselinePrefix$pkg');
    if (s == null) return null;
    try {
      final m = json.decode(s) as Map<String, dynamic>;
      return AppBaseline.fromJson(m);
    } catch (_) {
      return null;
    }
  }

  Future<void> setBaseline(AppBaseline baseline) async {
    await init();
    await _prefs!.setString(
      '$_baselinePrefix${baseline.packageName}',
      json.encode(baseline.toJson()),
    );
  }

  Future<void> upsertBaseline({
    required String pkg,
    required List<String> permissions,
    required int services,
    required int receivers,
    required bool hasLauncher,
    double? currentRate,
  }) async {
    final now = DateTime.now();
    final existing = await getBaseline(pkg);
    final avgRate = _smoothAvg(existing?.avgRate ?? 0.0, currentRate ?? 0.0);
    final base = AppBaseline(
      packageName: pkg,
      permissions: permissions,
      servicesCount: services,
      receiversCount: receivers,
      hasLauncher: hasLauncher,
      avgRate: avgRate,
      firstSeen: existing?.firstSeen ?? now,
      lastUpdated: now,
    );
    await setBaseline(base);
  }

  double _smoothAvg(double prev, double current) {
    if (current <= 0) return prev * 0.98; // slight decay
    // EMA with alpha=0.3
    return prev == 0 ? current : prev * 0.7 + current * 0.3;
  }

  Future<void> recordNetworkSample(String pkg, RateSample sample) async {
    await init();
    final key = '$_samplesPrefix$pkg';
    final s = _prefs!.getString(key);
    List<dynamic> arr = [];
    if (s != null) {
      try {
        arr = json.decode(s) as List<dynamic>;
      } catch (_) {
        arr = [];
      }
    }
    arr.add(sample.toJson());
    // keep last N samples
    if (arr.length > _samplesLimit) {
      arr = arr.sublist(arr.length - _samplesLimit);
    }
    await _prefs!.setString(key, json.encode(arr));
  }

  Future<List<RateSample>> getSamples(String pkg) async {
    await init();
    final s = _prefs!.getString('$_samplesPrefix$pkg');
    if (s == null) return [];
    try {
      final arr = (json.decode(s) as List<dynamic>)
          .map((e) => RateSample.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      return arr;
    } catch (_) {
      return [];
    }
  }
}
