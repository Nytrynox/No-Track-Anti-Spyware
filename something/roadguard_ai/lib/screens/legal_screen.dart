import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

/// Legal Screen - Privacy Policy & Terms
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Legal & Privacy', style: AppTextStyles.headlineSmall),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Privacy Policy',
              'Last Updated: January 15, 2026\n\n'
              '1. Data Collection\n'
              'RoadGuard AI collects visual data solely for the purpose of real-time object detection. No image or video data is stored on our servers. All processing happens locally on your device.\n\n'
              '2. Camera Usage\n'
              'We require camera access to detect vehicles, pedestrians, and road signs. This feed is analyzed in real-time and discarded immediately after processing.\n\n'
              '3. Location Data\n'
              'Location data is used to track your trip distance and speed. This data stays on your device unless you choose to export it.\n\n'
              '4. Developer Info\n'
              'Developed by Karthik. Contact us for support relative to app features.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Terms and Conditions',
              '1. Acceptance\n'
              'By using RoadGuard AI, you agree to these terms. This app is a driver assistance tool, not a replacement for attentive driving.\n\n'
              '2. Safety Disclaimer\n'
              'RoadGuard AI is an aid. The driver is always fully responsible for operating the vehicle safely. Do not rely solely on the app for decision making.\n\n'
              '3. Limitation of Liability\n'
              'The developer (Karthik) is not liable for any accidents, damages, or legal issues arising from the use of this application.',
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                '© 2026 RoadGuard AI',
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
