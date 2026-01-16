import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnimatedDonutChart extends StatefulWidget {
  final List<PieChartSectionData> sections;
  const AnimatedDonutChart({super.key, required this.sections});

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (_, t, __) => PieChart(
        PieChartData(
          sections: List.generate(widget.sections.length, (i) {
            final s = widget.sections[i];
            final isTouched = _touchedIndex == i;
            return PieChartSectionData(
              color: s.color,
              value: s.value * t,
              title: s.title,
              radius: s.radius * (isTouched ? 1.1 : (0.8 + 0.2 * t)),
              titleStyle: s.titleStyle,
            );
          }),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          pieTouchData: PieTouchData(
            touchCallback: (evt, resp) {
              setState(() {
                _touchedIndex = resp?.touchedSection?.touchedSectionIndex;
              });
            },
          ),
        ),
      ),
    );
  }
}
