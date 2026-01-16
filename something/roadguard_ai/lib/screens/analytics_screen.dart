import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/theme.dart';
import '../providers/trip_provider.dart';

/// Premium Analytics Dashboard
/// Real data visualization with beautiful charts
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
          'Analytics',
          style: AppTextStyles.headlineSmall,
        ),
      ),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, _) {
          final stats = tripProvider.getTripStats();
          final trips = tripProvider.tripHistory;
          
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                _buildOverviewSection(stats),
                
                const SizedBox(height: 28),
                
                // Safety Score Chart
                _buildSafetyChart(trips),
                
                const SizedBox(height: 28),
                
                // Trip Stats
                _buildTripStats(stats),
                
                const SizedBox(height: 28),
                
                // Insights
                _buildInsights(stats, trips),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewSection(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                icon: Icons.route_rounded,
                iconColor: AppColors.primary,
                value: stats['totalTrips'].toString(),
                label: 'Total Trips',
                delay: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OverviewCard(
                icon: Icons.shield_rounded,
                iconColor: AppColors.success,
                value: '${stats['avgSafetyScore']}%',
                label: 'Avg Safety',
                delay: 50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                icon: Icons.timer_rounded,
                iconColor: AppColors.warning,
                value: _formatDuration(stats['totalDuration'] as Duration? ?? Duration.zero),
                label: 'Total Time',
                delay: 100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OverviewCard(
                icon: Icons.straighten_rounded,
                iconColor: AppColors.info,
                value: _formatDistance(stats['totalDistance']?.toDouble() ?? 0),
                label: 'Distance',
                delay: 150,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSafetyChart(List<dynamic> trips) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Safety Score Trend',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Your safety performance over time',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: trips.isEmpty
                ? _buildEmptyChart()
                : _buildLineChart(trips),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'No trip data yet',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Complete rides to see trends',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<dynamic> trips) {
    // Get last 7 trips for the chart
    final recentTrips = trips.take(7).toList().reversed.toList();
    
    if (recentTrips.isEmpty) {
      return _buildEmptyChart();
    }

    final spots = recentTrips.asMap().entries.map((e) {
      final score = (e.value.safetyScore ?? 80).toDouble();
      return FlSpot(e.key.toDouble(), score);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 20,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: AppTextStyles.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripStats(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detection Summary',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 16),
          _StatRow(
            icon: Icons.directions_car_rounded,
            iconColor: AppColors.info,
            label: 'Vehicles Detected',
            value: stats['vehicleDetections']?.toString() ?? '0',
          ),
          const Divider(height: 24),
          _StatRow(
            icon: Icons.person_rounded,
            iconColor: AppColors.warning,
            label: 'Pedestrians',
            value: stats['pedestrianDetections']?.toString() ?? '0',
          ),
          const Divider(height: 24),
          _StatRow(
            icon: Icons.warning_rounded,
            iconColor: AppColors.danger,
            label: 'Alerts Triggered',
            value: stats['alertCount']?.toString() ?? '0',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildInsights(Map<String, dynamic> stats, List<dynamic> trips) {
    final avgScore = stats['avgSafetyScore'] ?? 0;
    String insight;
    IconData icon;
    Color color;

    if (trips.isEmpty) {
      insight = 'Start your first ride to get personalized insights!';
      icon = Icons.tips_and_updates_rounded;
      color = AppColors.primary;
    } else if (avgScore >= 90) {
      insight = 'Excellent! Your riding habits are very safe. Keep it up!';
      icon = Icons.emoji_events_rounded;
      color = AppColors.success;
    } else if (avgScore >= 70) {
      insight = 'Good performance! Stay alert to potential hazards.';
      icon = Icons.thumb_up_rounded;
      color = AppColors.info;
    } else {
      insight = 'Consider reducing speed and staying more alert.';
      icon = Icons.lightbulb_rounded;
      color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insight',
                  style: AppTextStyles.titleSmall.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toInt()}m';
    }
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final int delay;

  const _OverviewCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay));
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
        Text(
          value,
          style: AppTextStyles.titleLarge,
        ),
      ],
    );
  }
}
