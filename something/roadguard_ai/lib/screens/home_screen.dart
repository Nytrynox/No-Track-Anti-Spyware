import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/trip_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/detection_provider.dart';

/// Home Dashboard - Clean, Simple Design
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final tripProvider = context.read<TripProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.loadSettings();
    await tripProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildMainAction(),
              const SizedBox(height: 28),
              _buildQuickActions(),
              const SizedBox(height: 28),
              _buildRecentTrips(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('Vantage AI', style: AppTextStyles.headlineLarge),
            ],
          ),
          Row(
            children: [
              _IconBtn(
                icon: Icons.history_rounded,
                onTap: () => Navigator.pushNamed(context, AppRoutes.tripHistory),
              ),
              const SizedBox(width: 10),
              _IconBtn(
                icon: Icons.settings_rounded,
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildMainAction() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer2<TripProvider, DetectionProvider>(
        builder: (context, tripProvider, detectionProvider, _) {
          final isRiding = tripProvider.isRiding;
          
          return GestureDetector(
            onTap: () async {
              if (isRiding) {
                detectionProvider.stop();
                await tripProvider.endRide();
                setState(() {});
              } else {
                await tripProvider.startRide();
                if (mounted) {
                  Navigator.pushNamed(context, AppRoutes.camera);
                }
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isRiding ? AppColors.danger : AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.glow(
                  isRiding ? AppColors.danger : AppColors.primary,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isRiding ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isRiding ? 'End Ride' : 'Start Riding',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isRiding 
                        ? 'Tap to finish and save'
                        : 'AI detection will protect you',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Quick Actions', style: AppTextStyles.headlineMedium),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.insights_rounded,
                  iconBg: AppColors.infoLight,
                  iconColor: AppColors.info,
                  title: 'Analytics',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.analytics),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.history_rounded,
                  iconBg: AppColors.warningLight,
                  iconColor: AppColors.warning,
                  title: 'History',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.tripHistory),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.tune_rounded,
                  iconBg: AppColors.primarySoft,
                  iconColor: AppColors.primary,
                  title: 'Settings',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildRecentTrips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Rides', style: AppTextStyles.headlineMedium),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.tripHistory),
                child: Text(
                  'See all',
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        Consumer<TripProvider>(
          builder: (context, tripProvider, _) {
            final trips = tripProvider.tripHistory.take(3).toList();
            
            if (trips.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundAlt,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.route_rounded,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('No rides yet', style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        'Start your first ride and your\ntrip history will appear here',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: trips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final trip = trips[index];
                return _TripItem(trip: trip);
              },
            );
          },
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.titleSmall),
          ],
        ),
      ),
    );
  }
}

class _TripItem extends StatelessWidget {
  final dynamic trip;

  const _TripItem({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.route_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip.duration?.inMinutes ?? 0} min ride',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${trip.safetyScore ?? 0}% safety',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getScoreColor(trip.safetyScore ?? 0).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${trip.safetyScore ?? 0}%',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _getScoreColor(trip.safetyScore ?? 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.danger;
  }
}
