import 'dart:io' show Platform;

import 'app_inspector.dart';
import 'security_bridge.dart';

class DefaultAppInspector implements AppInspector {
  @override
  Future<List<AppInfo>> getInstalledApps() async {
    if (Platform.isAndroid) {
      try {
        final infos = await PlatformSecurityBridge.getAllAppsSecurityInfo();
        return infos
            .map(
              (m) => AppInfo(
                packageName: (m['packageName'] as String? ?? ''),
                appName:
                    (m['appLabel'] as String? ??
                    (m['packageName'] as String? ?? '')),
                systemApp: (m['isSystemApp'] as bool? ?? false),
                hasLauncher: (m['hasLauncher'] as bool? ?? false),
              ),
            )
            .where((a) => a.packageName.isNotEmpty)
            .toList();
      } catch (_) {
        return const [];
      }
    }
    // iOS and others: plugin unavailable; return empty (cannot list apps)
    return const [];
  }
}

AppInspector createAppInspector() => DefaultAppInspector();
