import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/alert_service.dart';

/// Alert banner widget for displaying warnings
class AlertBanner extends StatelessWidget {
  final AlertData alert;

  const AlertBanner({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.glow(color),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getTitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (alert.priority) {
      case AlertPriority.critical:
        return AppColors.danger;
      case AlertPriority.high:
        return const Color(0xFFFF6B00);
      case AlertPriority.medium:
        return AppColors.warning;
      case AlertPriority.low:
        return AppColors.primary;
    }
  }

  IconData _getIcon() {
    switch (alert.category) {
      case AlertCategory.collision:
        return Icons.warning_rounded;
      case AlertCategory.laneDeparture:
        return Icons.swap_horiz_rounded;
      case AlertCategory.speed:
        return Icons.speed_rounded;
      case AlertCategory.traffic:
        return Icons.traffic_rounded;
      case AlertCategory.hazard:
        return Icons.report_problem_rounded;
      case AlertCategory.navigation:
        return Icons.navigation_rounded;
      case AlertCategory.emergency:
        return Icons.emergency_rounded;
      case AlertCategory.info:
        return Icons.info_rounded;
    }
  }

  String _getTitle() {
    switch (alert.category) {
      case AlertCategory.collision:
        return 'COLLISION WARNING';
      case AlertCategory.laneDeparture:
        return 'LANE DEPARTURE';
      case AlertCategory.speed:
        return 'SPEED WARNING';
      case AlertCategory.traffic:
        return 'TRAFFIC ALERT';
      case AlertCategory.hazard:
        return 'HAZARD DETECTED';
      case AlertCategory.navigation:
        return 'NAVIGATION';
      case AlertCategory.emergency:
        return 'EMERGENCY';
      case AlertCategory.info:
        return 'INFO';
    }
  }
}
