import 'app_inspector.dart';

class DefaultAppInspector implements AppInspector {
  @override
  Future<List<AppInfo>> getInstalledApps() async => const [];
}

AppInspector createAppInspector() => DefaultAppInspector();
