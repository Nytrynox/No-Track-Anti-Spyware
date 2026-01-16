import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/threat_provider.dart';
import '../models/threat.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_threat_card.dart';

class ThreatLogScreen extends StatefulWidget {
  const ThreatLogScreen({super.key});

  @override
  State<ThreatLogScreen> createState() => _ThreatLogScreenState();
}

class _ThreatLogScreenState extends State<ThreatLogScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThreatProvider>();
    final threats = _getFilteredThreats(provider.threats);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Critical', 'critical'),
                _buildFilterChip('High', 'high'),
                _buildFilterChip('Medium', 'medium'),
                _buildFilterChip('Low', 'low'),
                _buildFilterChip('Active', 'active'),
                _buildFilterChip('Mitigated', 'mitigated'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Threat List
          Expanded(
            child: threats.isEmpty
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
                          'No threats in this category',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: threats.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => AnimatedThreatCard(
                      threat: threats[i],
                      onTap: () => _showThreatDetails(threats[i], provider),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _filter = selected ? value : 'all');
        },
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  List<Threat> _getFilteredThreats(List<Threat> threats) {
    switch (_filter) {
      case 'critical':
        return threats
            .where((t) => t.severity == ThreatSeverity.critical)
            .toList();
      case 'high':
        return threats.where((t) => t.severity == ThreatSeverity.high).toList();
      case 'medium':
        return threats
            .where((t) => t.severity == ThreatSeverity.medium)
            .toList();
      case 'low':
        return threats.where((t) => t.severity == ThreatSeverity.low).toList();
      case 'active':
        return threats.where((t) => !t.mitigated).toList();
      case 'mitigated':
        return threats.where((t) => t.mitigated).toList();
      default:
        return threats;
    }
  }

  // Replaced by AnimatedThreatCard; kept detail bottom sheet below

  void _showThreatDetails(Threat threat, ThreatProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.severityColor(
                      threat.severity.name,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppTheme.severityIcon(threat.severity.name),
                    color: AppTheme.severityColor(threat.severity.name),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    threat.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Type', threat.type.name),
            _buildDetailRow('Severity', threat.severity.name.toUpperCase()),
            _buildDetailRow(
              'Confidence',
              '${(threat.confidence * 100).toInt()}%',
            ),
            _buildDetailRow(
              'Detected',
              DateFormat('MMM d, y at h:mm a').format(threat.detectedAt),
            ),
            _buildDetailRow(
              'Status',
              threat.mitigated ? 'Mitigated' : 'Active',
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(threat.description, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 24),
            if (!threat.mitigated)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    provider.markMitigated(threat.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Mark as Mitigated'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
