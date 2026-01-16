import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/trip_provider.dart';
import '../models/trip.dart';

/// Premium Trip History Screen
/// Clean list view with expandable trip details
class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

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
        title: Text(
          'Trip History',
          style: AppTextStyles.headlineSmall,
        ),
        actions: [
          Consumer<TripProvider>(
            builder: (context, provider, _) {
              if (provider.tripHistory.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _showClearDialog(context, provider),
              );
            },
          ),
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, _) {
          final trips = tripProvider.tripHistory;
          
          if (trips.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: trips.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _TripCard(
                trip: trips[index],
                index: index,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Trips Yet',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your completed rides will appear here.\nStart your first trip to see history.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  void _showClearDialog(BuildContext context, TripProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear History', style: AppTextStyles.headlineSmall),
        content: Text(
          'Are you sure you want to delete all trip history? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  final int index;

  const _TripCard({required this.trip, required this.index});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_bike_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.startTime != null 
                          ? dateFormat.format(trip.startTime!)
                          : 'Unknown Date',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.startTime != null 
                          ? timeFormat.format(trip.startTime!)
                          : '',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              _SafetyBadge(score: trip.safetyScore ?? 0),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.timer_outlined,
                  value: _formatDuration(trip.duration),
                  label: 'Duration',
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: AppColors.border,
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.straighten_rounded,
                  value: _formatDistance(trip.totalDistance),
                  label: 'Distance',
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: AppColors.border,
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.warning_rounded,
                  value: trip.alerts.length.toString(),
                  label: 'Alerts',
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 400.ms,
      delay: Duration(milliseconds: index * 50),
    ).slideY(begin: 0.1, end: 0);
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--';
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.toInt()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }
}

class _SafetyBadge extends StatelessWidget {
  final int score;

  const _SafetyBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (score >= 80) {
      color = AppColors.success;
    } else if (score >= 60) {
      color = AppColors.warning;
    } else {
      color = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$score%',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleMedium),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
