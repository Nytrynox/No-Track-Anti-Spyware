import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/threat_provider.dart';
import '../models/threat.dart';
import '../theme/app_theme.dart';
import 'scan_screen.dart';
import 'threat_log_screen.dart';
import 'package:intl/intl.dart';
import '../services/security_score_calculator.dart';
import '../widgets/security_score_widget.dart';
import '../widgets/animated_charts.dart';

class ModernDashboardScreen extends StatefulWidget {
  const ModernDashboardScreen({super.key});

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThreatProvider>();

    return Scaffold(
      body: _selectedIndex == 0
          ? _buildDashboard(context, provider)
          : _selectedIndex == 1
          ? const ScanScreen()
          : const ThreatLogScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.radar_outlined),
              selectedIcon: Icon(Icons.radar),
              label: 'Scan',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Threats',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, ThreatProvider provider) {
    final counts = provider.severityCounts();
    final totalThreats = provider.threats.length;
    final activeThreats = provider.threats.where((t) => !t.mitigated).length;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('AI Anti-Spyware'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showAboutDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {},
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Security Score Card
              _buildSecurityScoreCard(activeThreats, totalThreats),
              const SizedBox(height: 16),

              // Quick Actions
              _buildQuickActions(provider),
              const SizedBox(height: 16),

              // Threat Statistics
              _buildThreatStats(counts, totalThreats),
              const SizedBox(height: 16),

              // Threat Chart
              if (totalThreats > 0) ...[
                _buildThreatChart(counts),
                const SizedBox(height: 16),
              ],

              // Recent Threats
              _buildRecentThreats(provider.threats.take(5).toList()),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityScoreCard(int activeThreats, int totalThreats) {
    final provider = context.read<ThreatProvider>();
    final score = SecurityScoreCalculator.calculate(provider.threats);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              score >= 80
                  ? Icons.shield_outlined
                  : Icons.warning_amber_outlined,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Security Score',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SecurityScoreWidget(score: score),
        const SizedBox(height: 8),
        Text(
          activeThreats == 0
              ? 'Your device is secure'
              : '$activeThreats active threat${activeThreats > 1 ? 's' : ''} detected',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ThreatProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.radar,
            label: 'Quick Scan',
            gradient: AppTheme.primaryGradient,
            onTap: () async {
              await provider.scanNow();
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Scan complete')));
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: provider.monitoring ? Icons.pause : Icons.play_arrow,
            label: provider.monitoring ? 'Stop Monitor' : 'Monitor',
            gradient: AppTheme.successGradient,
            onTap: () {
              if (provider.monitoring) {
                provider.stopMonitoring();
              } else {
                provider.startMonitoring();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreatStats(Map<ThreatSeverity, int> counts, int total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Threat Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Critical',
              counts[ThreatSeverity.critical] ?? 0,
              Colors.red,
              total,
            ),
            _buildStatRow(
              'High',
              counts[ThreatSeverity.high] ?? 0,
              Colors.orange,
              total,
            ),
            _buildStatRow(
              'Medium',
              counts[ThreatSeverity.medium] ?? 0,
              Colors.yellow[700]!,
              total,
            ),
            _buildStatRow(
              'Low',
              counts[ThreatSeverity.low] ?? 0,
              Colors.green,
              total,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color, int total) {
    final percentage = total > 0 ? (count / total * 100).toInt() : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildThreatChart(Map<ThreatSeverity, int> counts) {
    final sections = ThreatSeverity.values
        .map((s) {
          final count = counts[s] ?? 0;
          if (count == 0) return null;

          final color = AppTheme.severityColor(s.name);
          return PieChartSectionData(
            color: color,
            value: count.toDouble(),
            title: '$count',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        })
        .whereType<PieChartSectionData>()
        .toList();

    if (sections.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Threat Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: AnimatedDonutChart(sections: sections),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentThreats(List<Threat> threats) {
    if (threats.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.shield_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No threats detected',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Recent Threats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...threats.map((threat) => _buildThreatTile(threat)),
        ],
      ),
    );
  }

  Widget _buildThreatTile(Threat threat) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.severityColor(
            threat.severity.name,
          ).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          AppTheme.severityIcon(threat.severity.name),
          color: AppTheme.severityColor(threat.severity.name),
        ),
      ),
      title: Text(threat.title),
      subtitle: Text(
        DateFormat('MMM d, y • h:mm a').format(threat.detectedAt),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: threat.mitigated
          ? const Icon(Icons.check_circle, color: Colors.green)
          : Chip(
              label: Text(
                '${(threat.confidence * 100).toInt()}%',
                style: const TextStyle(fontSize: 11),
              ),
              backgroundColor: AppTheme.severityColor(
                threat.severity.name,
              ).withValues(alpha: 0.1),
            ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI-Powered Anti-Spyware'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A Novel Approach to Enhanced Security',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'In the era of ubiquitous mobile computing, the threat of spyware to personal data and device security has escalated exponentially. This app leverages machine learning algorithms to detect and mitigate sophisticated spyware attacks.',
              ),
              SizedBox(height: 12),
              Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• AI-powered threat detection'),
              Text('• Permission risk analysis'),
              Text('• Install source verification'),
              Text('• Real-time monitoring'),
              Text('• Behavioral anomaly detection'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

int max(int a, int b) => a > b ? a : b;
