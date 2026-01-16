import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/threat_provider.dart';
import '../theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    setState(() => _isScanning = true);
    _animController.repeat();

    final provider = context.read<ThreatProvider>();
    await provider.scanNow();

    _animController.stop();
    setState(() => _isScanning = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Scan complete • ${provider.threats.length} threats found'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThreatProvider>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Scan Card
          Container(
            decoration: BoxDecoration(
              gradient: _isScanning
                  ? AppTheme.primaryGradient
                  : LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                RotationTransition(
                  turns: _animController,
                  child: Icon(
                    Icons.radar,
                    size: 80,
                    color: _isScanning
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isScanning ? 'Scanning...' : 'Deep Security Scan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _isScanning
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isScanning
                      ? 'Analyzing apps, permissions, and behaviors'
                      : 'Comprehensive analysis of installed applications',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isScanning
                        ? Colors.white70
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                if (_isScanning)
                  const LinearProgressIndicator(
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _startScan,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Deep Scan'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Detections
          Expanded(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Recent Detections',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (provider.threats.isNotEmpty)
                          Chip(
                            label: Text('${provider.threats.length}'),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 0),
                  Expanded(
                    child: provider.threats.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No threats detected',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: provider.threats.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 0),
                            itemBuilder: (_, i) {
                              final t = provider.threats[i];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.severityColor(
                                      t.severity.name,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    AppTheme.severityIcon(t.severity.name),
                                    color: AppTheme.severityColor(
                                      t.severity.name,
                                    ),
                                    size: 20,
                                  ),
                                ),
                                title: Text(t.title),
                                subtitle: Text(
                                  '${t.type.name} • ${t.severity.name}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: t.mitigated
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : Chip(
                                        label: Text(
                                          '${(t.confidence * 100).toInt()}%',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        backgroundColor: AppTheme.severityColor(
                                          t.severity.name,
                                        ).withValues(alpha: 0.1),
                                      ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
