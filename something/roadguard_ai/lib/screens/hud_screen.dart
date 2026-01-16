import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/detection_provider.dart';
import '../providers/trip_provider.dart';

/// HUD (Heads-Up Display) mode for minimal, glanceable interface
class HUDScreen extends StatefulWidget {
  const HUDScreen({super.key});

  @override
  State<HUDScreen> createState() => _HUDScreenState();
}

class _HUDScreenState extends State<HUDScreen> {
  @override
  void initState() {
    super.initState();
    // Keep screen on and in landscape
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore system UI and orientation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer2<DetectionProvider, TripProvider>(
        builder: (context, detectionProvider, tripProvider, child) {
          final controller = detectionProvider.cameraController;
          
          return GestureDetector(
            onDoubleTap: () => Navigator.pushReplacementNamed(context, AppRoutes.camera),
            onLongPress: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Camera preview (dimmed)
                if (controller != null && controller.value.isInitialized)
                  Opacity(
                    opacity: 0.3,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: controller.value.previewSize?.height ?? 1,
                            height: controller.value.previewSize?.width ?? 1,
                            child: CameraPreview(controller),
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // HUD overlay
                Container(
                  color: Colors.black.withOpacity(0.5),
                ),
                
                // Speed display (large, center)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tripProvider.currentSpeed.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 160,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          height: 1,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms),
                      const Text(
                        'km/h',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: AppColors.textMuted,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Top left - Detection count
                Positioned(
                  top: 40,
                  left: 40,
                  child: _HUDIndicator(
                    icon: Icons.visibility_rounded,
                    value: '${detectionProvider.detections.length}',
                    label: 'OBJECTS',
                    color: detectionProvider.detections.any((d) => d.isInDangerZone)
                        ? AppColors.danger
                        : AppColors.primary,
                  ),
                ),
                
                // Top right - Trip time
                Positioned(
                  top: 40,
                  right: 40,
                  child: _HUDIndicator(
                    icon: Icons.timer_rounded,
                    value: tripProvider.currentTrip?.formattedDuration ?? '0:00',
                    label: 'DURATION',
                    color: AppColors.primary,
                  ),
                ),
                
                // Bottom left - Distance
                Positioned(
                  bottom: 40,
                  left: 40,
                  child: _HUDIndicator(
                    icon: Icons.route_rounded,
                    value: tripProvider.currentTrip?.formattedDistance ?? '0 m',
                    label: 'DISTANCE',
                    color: AppColors.primary,
                  ),
                ),
                
                // Bottom right - Safety score
                Positioned(
                  bottom: 40,
                  right: 40,
                  child: _HUDIndicator(
                    icon: Icons.shield_rounded,
                    value: '${tripProvider.currentTrip?.safetyScore ?? 100}',
                    label: 'SAFETY',
                    color: (tripProvider.currentTrip?.safetyScore ?? 100) >= 80
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
                
                // Alert indicator (center top)
                if (detectionProvider.detections.any((d) => d.isInDangerZone))
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: AppShadows.glow(AppColors.danger),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'DANGER AHEAD',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .fadeIn(duration: 300.ms)
                          .then()
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.05, 1.05),
                            duration: 500.ms,
                          ),
                    ),
                  ),
                
                // Exit hint
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Double-tap to exit HUD • Long-press for home',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HUDIndicator extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _HUDIndicator({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: color.withOpacity(0.7),
            letterSpacing: 2,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms);
  }
}
