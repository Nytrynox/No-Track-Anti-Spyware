import 'app_inspector_stub.dart'
    if (dart.library.io) 'app_inspector_io.dart'
    as impl;

class AppInfo {
  final String packageName;
  final String appName;
  final bool systemApp;
  final bool hasLauncher;
  const AppInfo({
    required this.packageName,
    required this.appName,
    required this.systemApp,
    required this.hasLauncher,
  });
}

abstract class AppInspector {
  Future<List<AppInfo>> getInstalledApps();
}

AppInspector createAppInspector() => impl.createAppInspector();
