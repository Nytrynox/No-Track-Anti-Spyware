import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/threat_provider.dart';
import 'services/notification_service.dart';
import 'screens/modern_dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThreatProvider(NotificationService())..initialize(),
        ),
      ],
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          final ThemeData lightTheme;
          final ThemeData darkTheme;
          if (lightDynamic != null && darkDynamic != null) {
            lightTheme = ThemeData(
              useMaterial3: true,
              colorScheme: lightDynamic.harmonized(),
            );
            darkTheme = ThemeData(
              useMaterial3: true,
              colorScheme: darkDynamic.harmonized(),
            );
          } else {
            lightTheme = AppTheme.lightTheme;
            darkTheme = AppTheme.darkTheme;
          }

          return FutureBuilder<bool>(
            future: _shouldShowOnboarding(),
            builder: (context, snap) {
              final showOnboarding = snap.data ?? false;
              return MaterialApp(
                title: 'AI-Powered Anti-Spyware',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: ThemeMode.system,
                debugShowCheckedModeBanner: false,
                home: showOnboarding
                    ? const OnboardingScreen()
                    : const ModernDashboardScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

Future<bool> _shouldShowOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool('onboarding_complete') ?? false);
}
