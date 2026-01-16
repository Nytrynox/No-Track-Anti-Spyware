import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/settings_provider.dart';

/// Settings Screen - Advanced Design
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        title: Text('Settings', style: AppTextStyles.headlineSmall),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          final s = provider.settings;
          
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Master Detection Toggle
                _Section(
                  title: 'AI Detection',
                  children: [
                    _Toggle(
                      icon: Icons.visibility_rounded,
                      iconColor: AppColors.primary,
                      iconBg: AppColors.primarySoft,
                      title: 'Enable Detection',
                      subtitle: 'Turn AI object detection on/off',
                      value: s.objectDetectionEnabled,
                      onChanged: (v) => provider.updateSettings(s.copyWith(objectDetectionEnabled: v)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Display Settings
                _Section(
                  title: 'What You See',
                  children: [
                    _Toggle(
                      icon: Icons.crop_square_rounded,
                      iconColor: AppColors.info,
                      iconBg: AppColors.infoLight,
                      title: 'Detection Boxes',
                      subtitle: 'Show boxes around detected objects',
                      value: s.showBoundingBoxes,
                      onChanged: (v) => provider.updateSettings(s.copyWith(showBoundingBoxes: v)),
                    ),
                    _Toggle(
                      icon: Icons.percent_rounded,
                      iconColor: AppColors.warning,
                      iconBg: AppColors.warningLight,
                      title: 'Confidence Level',
                      subtitle: 'Display how sure the AI is',
                      value: s.showConfidence,
                      onChanged: (v) => provider.updateSettings(s.copyWith(showConfidence: v)),
                    ),
                    _Toggle(
                      icon: Icons.straighten_rounded,
                      iconColor: AppColors.success,
                      iconBg: AppColors.successLight,
                      title: 'Distance Estimate',
                      subtitle: 'Show estimated distance to objects',
                      value: s.showDistance,
                      onChanged: (v) => provider.updateSettings(s.copyWith(showDistance: v)),
                    ),
                    _Toggle(
                      icon: Icons.add_road_rounded,
                      iconColor: AppColors.primary,
                      iconBg: AppColors.primarySoft,
                      title: 'Lane Guides',
                      subtitle: 'Overlay lane guidance lines',
                      value: s.showLaneLines,
                      onChanged: (v) => provider.updateSettings(s.copyWith(showLaneLines: v)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Alert Settings
                _Section(
                  title: 'How You\'re Alerted',
                  children: [
                    _Toggle(
                      icon: Icons.volume_up_rounded,
                      iconColor: AppColors.primary,
                      iconBg: AppColors.primarySoft,
                      title: 'Voice Alerts',
                      subtitle: 'Hear spoken warnings when needed',
                      value: s.voiceAlertsEnabled,
                      onChanged: (v) => provider.updateSettings(s.copyWith(voiceAlertsEnabled: v)),
                    ),
                    _Toggle(
                      icon: Icons.vibration_rounded,
                      iconColor: AppColors.warning,
                      iconBg: AppColors.warningLight,
                      title: 'Vibration',
                      subtitle: 'Feel a buzz when something\'s close',
                      value: s.vibrationAlertsEnabled,
                      onChanged: (v) => provider.updateSettings(s.copyWith(vibrationAlertsEnabled: v)),
                    ),
                    _Toggle(
                      icon: Icons.music_note_rounded,
                      iconColor: AppColors.info,
                      iconBg: AppColors.infoLight,
                      title: 'Sound Effects',
                      subtitle: 'Play warning sounds for alerts',
                      value: s.soundAlertsEnabled,
                      onChanged: (v) => provider.updateSettings(s.copyWith(soundAlertsEnabled: v)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // About Section
                _Section(
                  title: 'About This App',
                  children: [
                    const _InfoRow(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppColors.textSecondary,
                      iconBg: AppColors.backgroundAlt,
                      title: 'Version',
                      value: '1.0.0',
                    ),
                    _TapRow(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: AppColors.textSecondary,
                      iconBg: AppColors.backgroundAlt,
                      title: 'Privacy Policy',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.legal),
                    ),
                    _TapRow(
                      icon: Icons.description_outlined,
                      iconColor: AppColors.textSecondary,
                      iconBg: AppColors.backgroundAlt,
                      title: 'Terms of Service',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.legal),
                    ),
                    _TapRow(
                      icon: Icons.star_rounded,
                      iconColor: AppColors.warning,
                      iconBg: AppColors.warningLight,
                      title: 'Rate This App',
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 36),
                
                // Footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Made with ❤️ for safer rides',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Powered by TensorFlow Lite',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: children.asMap().entries.map((e) {
              final i = e.key;
              final child = e.value;
              return Column(
                children: [
                  child,
                  if (i < children.length - 1)
                    const Divider(height: 1, indent: 64),
                ],
              );
            }).toList(),
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.03, end: 0),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: AppTextStyles.titleMedium)),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _TapRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final VoidCallback onTap;

  const _TapRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: AppTextStyles.titleMedium)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
