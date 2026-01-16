import 'package:flutter/material.dart';

class SecurityScoreWidget extends StatelessWidget {
  final int score;
  const SecurityScoreWidget({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final Color base = score >= 80
        ? Colors.green
        : score >= 50
        ? Colors.orange
        : Colors.red;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score.toDouble()),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [base.withValues(alpha: 0.8), base],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: base.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              v.toInt().toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8, left: 4),
              child: Text(
                '/100',
                style: TextStyle(color: Colors.white70, fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
