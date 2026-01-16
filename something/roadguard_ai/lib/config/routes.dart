import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/hud_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/trip_history_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/legal_screen.dart';

/// App routes
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String camera = '/camera';
  static const String hud = '/hud';
  static const String settings = '/settings';
  static const String tripHistory = '/trip-history';
  static const String analytics = '/analytics';
  static const String legal = '/legal';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen());
      case onboarding:
        return _fadeRoute(const OnboardingScreen());
      case home:
        return _fadeRoute(const HomeScreen());
      case camera:
        return _slideRoute(const CameraScreen());
      case hud:
        return _fadeRoute(const HUDScreen());
      case AppRoutes.settings:
        return _slideRoute(const SettingsScreen());
      case tripHistory:
        return _slideRoute(const TripHistoryScreen());
      case analytics:
        return _slideRoute(const AnalyticsScreen());
      case legal:
        return _slideRoute(const LegalScreen());
      default:
        return _fadeRoute(const HomeScreen());
    }
  }
  
  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
  
  static PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
