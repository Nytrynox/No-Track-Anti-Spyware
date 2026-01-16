import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/threat.dart';
import '../providers/threat_provider.dart';
import 'scan_screen.dart';
import 'threat_log_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThreatProvider>();
    final counts = provider.severityCounts();

    final sections = ThreatSeverity.values.map((s) {
      final c = counts[s] ?? 0;
      final color = switch (s) {
        ThreatSeverity.low => Colors.green,
        ThreatSeverity.medium => Colors.orange,
        ThreatSeverity.high => Colors.red,
        ThreatSeverity.critical => Colors.purple,
      };
      return PieChartSectionData(
        color: color,
        value: c.toDouble(),
        title: c.toString(),
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Anti-Spyware'),
        actions: [
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'AI-Powered Anti-Spyware for Mobile Devices: A Novel Approach to Enhanced Security',
                  ),
                  content: const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Abstract:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'In the era of ubiquitous mobile computing, the threat of spyware to personal data and device security has escalated exponentially. This paper proposes an innovative AI-driven anti-spyware solution for mobile devices, leveraging machine learning algorithms to detect and mitigate sophisticated spyware attacks. Our AI assistant analyzes device behavior, identifies anomalies, and predicts potential threats, providing real-time protection against evolving spyware threats. By integrating AI-powered threat detection with advanced behavioral analysis, our solution offers robust security for mobile users, safeguarding sensitive information and ensuring device integrity.',
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Keywords:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'AI-powered security, anti-spyware, mobile security, machine learning, threat detection.',
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Threat Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: PieChart(PieChartData(sections: sections)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monitoring: ${provider.monitoring ? 'ON' : 'OFF'}',
                        ),
                        Text('Total threats: ${provider.threats.length}'),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.search),
                          label: const Text('Scan Now'),
                          onPressed: provider.scanNow,
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: Icon(
                            provider.monitoring
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          label: Text(provider.monitoring ? 'Stop' : 'Monitor'),
                          onPressed: provider.monitoring
                              ? provider.stopMonitoring
                              : provider.startMonitoring,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _QuickList(
                      title: 'Recent Threats',
                      items: provider.threats.take(5).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Threat Log'),
        ],
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ScanScreen()));
          } else if (i == 2) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ThreatLogScreen()));
          }
        },
      ),
    );
  }
}

class _QuickList extends StatelessWidget {
  final String title;
  final List<Threat> items;
  const _QuickList({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('No items')
            else
              ...items.map(
                (t) => ListTile(
                  title: Text(t.title),
                  subtitle: Text(
                    '${t.type.name} • ${t.severity.name} • ${(t.confidence * 100).toStringAsFixed(0)}%',
                  ),
                  trailing: t.mitigated
                      ? const Icon(Icons.verified, color: Colors.green)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
