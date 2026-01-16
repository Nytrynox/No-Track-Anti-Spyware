import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../config/routes.dart';

/// Onboarding Screen - Solid Colors, Human Design
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.visibility_rounded,
      iconColor: AppColors.primary,
      iconBg: AppColors.primarySoft,
      title: 'See Everything',
      description: 'Our AI spots vehicles, people, and obstacles on the road ahead—so you don\'t have to guess.',
    ),
    _OnboardingData(
      icon: Icons.notifications_active_rounded,
      iconColor: AppColors.warning,
      iconBg: AppColors.warningLight,
      title: 'Stay Alert',
      description: 'Get voice and vibration alerts when something needs your attention. No distractions, just safety.',
    ),
    _OnboardingData(
      icon: Icons.insights_rounded,
      iconColor: AppColors.success,
      iconBg: AppColors.successLight,
      title: 'Know Your Stats',
      description: 'Track your trips, see your safety score, and learn how to ride smarter over time.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) => _buildPage(_pages[i]),
              ),
            ),
            
            // Dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => _buildDot(i),
                ),
              ),
            ),
            
            // Button - SOLID color
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // SOLID
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Let\'s Go!' : 'Next',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: page.iconBg,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              page.icon,
              size: 52,
              color: page.iconColor,
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(duration: 300.ms),
          
          const SizedBox(height: 52),
          
          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          )
              .animate(delay: 100.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 14),
          
          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;

  _OnboardingData({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
  });
}
