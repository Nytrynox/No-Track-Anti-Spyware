import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/theme.dart';

/// Speed indicator widget with circular gauge
class SpeedIndicator extends StatelessWidget {
  final double speed;
  final double limit;

  const SpeedIndicator({
    super.key,
    required this.speed,
    this.limit = 80,
  });

  @override
  Widget build(BuildContext context) {
    final isOverLimit = speed > limit;
    final percentage = (speed / limit).clamp(0.0, 1.5);
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(
          color: isOverLimit 
              ? AppColors.danger.withOpacity(0.5) 
              : AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isOverLimit
            ? AppShadows.glow(AppColors.danger, blur: 20)
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress arc
          CustomPaint(
            size: const Size(100, 100),
            painter: SpeedGaugePainter(
              percentage: percentage,
              isOverLimit: isOverLimit,
            ),
          ),
          
          // Speed text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                speed.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isOverLimit ? AppColors.danger : AppColors.textPrimary,
                ),
              ),
              Text(
                'km/h',
                style: TextStyle(
                  fontSize: 10,
                  color: isOverLimit ? AppColors.danger : AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SpeedGaugePainter extends CustomPainter {
  final double percentage;
  final bool isOverLimit;

  SpeedGaugePainter({
    required this.percentage,
    required this.isOverLimit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    
    // Background arc
    final bgPaint = Paint()
      ..color = AppColors.surfaceLight
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );
    
    // Progress arc
    final progressPaint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    if (isOverLimit) {
      progressPaint.color = AppColors.danger;
    } else {
      progressPaint.shader = const LinearGradient(
        colors: [AppColors.success, AppColors.primary],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    }
    
    final progressSweep = sweepAngle * percentage.clamp(0.0, 1.0);
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );
    
    // Over limit indicator
    if (percentage > 1.0) {
      final overPaint = Paint()
        ..color = AppColors.danger
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      final overStart = startAngle + sweepAngle;
      final overSweep = sweepAngle * (percentage - 1.0).clamp(0.0, 0.5);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        overStart,
        -overSweep,
        false,
        overPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpeedGaugePainter oldDelegate) {
    return percentage != oldDelegate.percentage ||
           isOverLimit != oldDelegate.isOverLimit;
  }
}
