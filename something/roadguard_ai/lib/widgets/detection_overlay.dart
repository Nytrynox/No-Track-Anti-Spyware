import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/detection_result.dart';

/// Premium Detection Overlay
/// Clean, professional visualization of AI detections
class DetectionOverlay extends StatefulWidget {
  final List<DetectionResult> detections;
  final LaneDetection? laneDetection;
  final bool showConfidence;
  final bool showDistance;
  final bool showLaneLines;

  const DetectionOverlay({
    super.key,
    required this.detections,
    this.laneDetection,
    this.showConfidence = true,
    this.showDistance = true,
    this.showLaneLines = true,
  });

  @override
  State<DetectionOverlay> createState() => _DetectionOverlayState();
}

class _DetectionOverlayState extends State<DetectionOverlay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        return CustomPaint(
          painter: _DetectionPainter(
            detections: widget.detections,
            laneDetection: widget.laneDetection,
            scanProgress: _scanController.value,
            showConfidence: widget.showConfidence,
            showDistance: widget.showDistance,
            showLaneLines: widget.showLaneLines,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _DetectionPainter extends CustomPainter {
  final List<DetectionResult> detections;
  final LaneDetection? laneDetection;
  final double scanProgress;
  final bool showConfidence;
  final bool showDistance;
  final bool showLaneLines;

  _DetectionPainter({
    required this.detections,
    required this.scanProgress,
    this.laneDetection,
    this.showConfidence = true,
    this.showDistance = true,
    this.showLaneLines = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Draw lane lines first (background)
    if (showLaneLines && laneDetection != null && laneDetection!.isValid) {
      _drawLaneLines(canvas, size, laneDetection!);
    }

    // Draw each detection
    for (final detection in detections) {
      _drawDetection(canvas, size, detection);
    }

    // Draw subtle scan line
    _drawScanLine(canvas, size);
  }

  void _drawDetection(Canvas canvas, Size size, DetectionResult detection) {
    final rect = Rect.fromLTRB(
      detection.boundingBox.left * size.width,
      detection.boundingBox.top * size.height,
      detection.boundingBox.right * size.width,
      detection.boundingBox.bottom * size.height,
    );

    // Get color based on distance
    final color = _getDistanceColor(detection.distance);
    
    // Draw futuristic target box
    _drawSciFiBox(canvas, rect, color);
    
    // Draw label tag
    _drawTechLabel(canvas, rect, detection, color, size);
  }

  Color _getDistanceColor(double? distance) {
    if (distance == null) return const Color(0xFF00E5FF); // Cyan
    if (distance < 5) return const Color(0xFFFF2D55); // Red
    if (distance < 15) return const Color(0xFFFF9F0A); // Orange
    return const Color(0xFF32D74B); // Green
  }

  void _drawSciFiBox(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
      
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    const cornerSize = 20.0;
    const bracketSize = 5.0;

    // Build corners path
    final path = Path();
    
    // Top Left
    path.moveTo(rect.left, rect.top + cornerSize);
    path.lineTo(rect.left, rect.top);
    path.lineTo(rect.left + cornerSize, rect.top);
    
    // Top Right
    path.moveTo(rect.right - cornerSize, rect.top);
    path.lineTo(rect.right, rect.top);
    path.lineTo(rect.right, rect.top + cornerSize);
    
    // Bottom Right
    path.moveTo(rect.right, rect.bottom - cornerSize);
    path.lineTo(rect.right, rect.bottom);
    path.lineTo(rect.right - cornerSize, rect.bottom);
    
    // Bottom Left
    path.moveTo(rect.left + cornerSize, rect.bottom);
    path.lineTo(rect.left, rect.bottom);
    path.lineTo(rect.left, rect.bottom - cornerSize);
    
    // Draw glow then stroke
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
    
    // Draw decorative "bracket" accents
    final accentPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
      
    canvas.drawLine(
      Offset(rect.left - 4, rect.top + cornerSize), 
      Offset(rect.left - 4, rect.bottom - cornerSize), 
      accentPaint
    );
    canvas.drawLine(
      Offset(rect.right + 4, rect.top + cornerSize), 
      Offset(rect.right + 4, rect.bottom - cornerSize), 
      accentPaint
    );
  }

  void _drawTechLabel(Canvas canvas, Rect rect, DetectionResult detection, Color color, Size size) {
    // Label text
    String label = detection.displayLabel.toUpperCase();
    String info = '';
    
    if (showConfidence) info += '${(detection.confidence * 100).toInt()}% ';
    if (showDistance && detection.distance != null) info += '${detection.distance!.toInt()}m';

    // 1. Draw connecting line to label placement (top right of box)
    final anchor = Offset(rect.right, rect.top);
    final labelOrigin = Offset(rect.right + 20, rect.top - 20);
    
    final linePaint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 1.0;
      
    canvas.drawLine(anchor, Offset(rect.right + 10, rect.top), linePaint);
    canvas.drawLine(Offset(rect.right + 10, rect.top), labelOrigin, linePaint);
    
    // 2. Text layout
    final labelSpan = TextSpan(
      children: [
        TextSpan(
          text: '$label\n',
          style: GoogleFonts.shareTechMono(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: [Shadow(color: color, blurRadius: 8)],
          ),
        ),
        TextSpan(
          text: info,
          style: GoogleFonts.shareTechMono(
            fontSize: 10,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );

    final textPainter = TextPainter(
      text: labelSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout();

    // 3. Background for text (tech tag style)
    // Avoid drawing off-screen
    double dx = labelOrigin.dx;
    if (dx + textPainter.width > size.width) {
      dx = rect.left - textPainter.width - 20; // Flip to left side if too far right
    }

    final textBgRect = Rect.fromLTWH(
      dx, 
      labelOrigin.dy, 
      textPainter.width + 12, 
      textPainter.height + 8
    );
    
    // Draw hexagon/tech shape background
    final bgPath = Path()
      ..moveTo(textBgRect.left, textBgRect.top)
      ..lineTo(textBgRect.right - 5, textBgRect.top)
      ..lineTo(textBgRect.right, textBgRect.top + 5)
      ..lineTo(textBgRect.right, textBgRect.bottom)
      ..lineTo(textBgRect.left, textBgRect.bottom)
      ..close();
      
    canvas.drawPath(
      bgPath, 
      Paint()..color = Colors.black.withOpacity(0.7)
    );
    
    canvas.drawPath(
      bgPath, 
      Paint()..color = color.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1
    );

    // Draw text
    textPainter.paint(canvas, Offset(dx + 6, labelOrigin.dy + 4));
  }
  
  void _drawScanLine(Canvas canvas, Size size) {
    if (detections.isEmpty) return; // Only scan when detecting? Or always? Let's leave it always for effect.
    
    final scanY = scanProgress * size.height;
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, scanY),
        Offset(size.width, scanY),
        [Colors.transparent, const Color(0xFF00E5FF).withOpacity(0.5), Colors.transparent],
        [0.0, 0.5, 1.0],
      )
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), paint);
  }

  void _drawLaneLines(Canvas canvas, Size size, LaneDetection lane) {
    final paint = Paint()
      ..color = lane.deviationColor.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Left lane
    if (lane.leftLane.length >= 2) {
      final path = Path();
      path.moveTo(
        lane.leftLane.first.dx * size.width,
        lane.leftLane.first.dy * size.height,
      );
      for (final point in lane.leftLane.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }

    // Right lane
    if (lane.rightLane.length >= 2) {
      final path = Path();
      path.moveTo(
        lane.rightLane.first.dx * size.width,
        lane.rightLane.first.dy * size.height,
      );
      for (final point in lane.rightLane.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DetectionPainter oldDelegate) {
    return true; // Always repaint for scan animation
  }
}
