import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/detection_provider.dart';
import '../providers/trip_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/detection_overlay.dart';

/// Camera Screen - Advanced Detection View
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  bool _isInitializing = true;
  String? _error;
  bool _isMuted = false;
  DateTime? _tripStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tripStartTime = DateTime.now();
    _initCamera();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final detectionProvider = context.read<DetectionProvider>();
    final settings = context.read<SettingsProvider>().settings;
    
    if (state == AppLifecycleState.inactive) {
      detectionProvider.stop();
    } else if (state == AppLifecycleState.resumed && 
               detectionProvider.isInitialized && 
               settings.objectDetectionEnabled) {
      detectionProvider.start();
    }
  }

  Future<void> _initCamera() async {
    try {
      final detectionProvider = context.read<DetectionProvider>();
      final settings = context.read<SettingsProvider>().settings;
      
      final success = await detectionProvider.initialize();
      
      if (!success) {
        setState(() {
          _error = 'Couldn\'t start the camera or AI. Please try again.';
          _isInitializing = false;
        });
        return;
      }
      
      // Only start detection if enabled in settings
      if (settings.objectDetectionEnabled) {
        await detectionProvider.start();
      }
      
      setState(() => _isInitializing = false);
    } catch (e) {
      setState(() {
        _error = 'Something went wrong: $e';
        _isInitializing = false;
      });
    }
  }

  void _endTrip() async {
    final tripProvider = context.read<TripProvider>();
    final detectionProvider = context.read<DetectionProvider>();
    
    detectionProvider.stop();
    await tripProvider.endRide();
    
    if (mounted) Navigator.pop(context);
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    final alertService = context.read<DetectionProvider>().alertService;
    alertService.updateSettings(voiceEnabled: !_isMuted);
  }

  String _formatTime(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) return _buildLoading();
    if (_error != null) return _buildError();
    return _buildCamera();
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Starting camera...',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Getting the AI ready for you',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.danger.withAlpha(25),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 40),
              ),
              const SizedBox(height: 32),
              Text(
                'Oops! Something went wrong',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Go Back'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() { _isInitializing = true; _error = null; });
                      _initCamera();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCamera() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer3<DetectionProvider, TripProvider, SettingsProvider>(
        builder: (context, detection, trip, settingsProvider, _) {
          final controller = detection.cameraController;
          final settings = settingsProvider.settings;
          
          if (controller == null || !controller.value.isInitialized) {
            return _buildLoading();
          }
          
          final elapsed = DateTime.now().difference(_tripStartTime ?? DateTime.now());
          final detectionCount = settings.objectDetectionEnabled ? detection.detections.length : 0;
          
          return Stack(
            fit: StackFit.expand,
            children: [
              // Camera preview
              ClipRect(
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
              
              // Detection overlay - only show if enabled
              if (settings.objectDetectionEnabled && settings.showBoundingBoxes)
                DetectionOverlay(
                  detections: detection.detections,
                  laneDetection: detection.laneDetection,
                  showConfidence: settings.showConfidence,
                  showDistance: settings.showDistance,
                  showLaneLines: settings.showLaneLines,
                ),
              
              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  color: const Color(0xCC000000),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Recording badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            )
                                .animate(onPlay: (c) => c.repeat())
                                .fadeOut(duration: 600.ms)
                                .then()
                                .fadeIn(duration: 600.ms),
                            const SizedBox(width: 10),
                            Text(
                              _formatTime(elapsed),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Detection count / Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0x66000000),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              settings.objectDetectionEnabled 
                                  ? Icons.visibility_rounded 
                                  : Icons.visibility_off_rounded,
                              size: 16,
                              color: settings.objectDetectionEnabled
                                  ? (detectionCount > 0 ? AppColors.success : Colors.white70)
                                  : Colors.white38,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              settings.objectDetectionEnabled
                                  ? '$detectionCount detected'
                                  : 'Detection off',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: 28,
                    left: 24,
                    right: 24,
                    bottom: MediaQuery.of(context).padding.bottom + 28,
                  ),
                  color: const Color(0xDD000000),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ControlBtn(
                        icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        label: _isMuted ? 'Unmute' : 'Mute',
                        onTap: _toggleMute,
                      ),
                      
                      // End ride button
                      GestureDetector(
                        onTap: _endTrip,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.glow(AppColors.danger),
                          ),
                          child: const Icon(Icons.stop_rounded, color: Colors.white, size: 40),
                        ),
                      ),
                      
                      _ControlBtn(
                        icon: Icons.tune_rounded,
                        label: 'Settings',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0x40FFFFFF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
