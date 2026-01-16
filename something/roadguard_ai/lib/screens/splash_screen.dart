import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/routes.dart';

/// Premium Splash Screen - Advanced Animations
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    _startLoading();
  }

  Future<void> _startLoading() async {
    // Animate progress
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (mounted) {
        setState(() => _progress = i / 100);
      }
    }
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Animated Logo
              _buildLogo(),
              
              const SizedBox(height: 32),
              
              // App Name with Tagline
              _buildBranding(),
              
              const Spacer(flex: 2),
              
              // Progress Section
              _buildProgress(),
              
              const SizedBox(height: 48),
              
              // Feature Pills
              _buildFeatures(),
              
              const SizedBox(height: 40),
              
              // Footer
              _buildFooter(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.05);
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(80),
              blurRadius: 40,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withAlpha(40),
                  width: 2,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildBranding() {
    return Column(
      children: [
        Text(
          'Vantage AI',
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 8),
        
        Text(
          'AI-Powered Road Safety',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        )
            .animate(delay: 400.ms)
            .fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildProgress() {
    return Column(
      children: [
        // Progress bar
        Container(
          height: 4,
          width: 200,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 200 * _progress,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Status text
        Text(
          _getStatusText(),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    ).animate(delay: 600.ms).fadeIn(duration: 400.ms);
  }

  String _getStatusText() {
    if (_progress < 0.3) return 'Initializing AI engine...';
    if (_progress < 0.6) return 'Loading detection models...';
    if (_progress < 0.9) return 'Preparing camera...';
    return 'Almost ready!';
  }

  Widget _buildFeatures() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _FeaturePill(icon: Icons.visibility_rounded, label: 'Real-time Detection', delay: 700),
        _FeaturePill(icon: Icons.notifications_active_rounded, label: 'Smart Alerts', delay: 800),
        _FeaturePill(icon: Icons.insights_rounded, label: 'Trip Analytics', delay: 900),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Powered by TensorFlow Lite',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    ).animate(delay: 1000.ms).fadeIn(duration: 400.ms);
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final int delay;

  const _FeaturePill({
    required this.icon,
    required this.label,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 300.ms).scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1.0, 1.0),
    );
  }
}
