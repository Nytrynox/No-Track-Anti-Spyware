import 'dart:convert';

import '../models/threat.dart';

class ReportService {
  static String toJsonReport(List<Threat> threats) {
    final arr = threats.map((t) => t.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(arr);
  }

  static String toCsvReport(List<Threat> threats) {
    final header = [
      'id',
      'detectedAt',
      'severity',
      'type',
      'title',
      'description',
      'confidence',
      'mitigated',
      'tags',
    ];
    final rows = threats.map(
      (t) => [
        t.id,
        t.detectedAt.toIso8601String(),
        t.severity.name,
        t.type.name,
        t.title.replaceAll('\n', ' ').replaceAll(',', ';'),
        t.description.replaceAll('\n', ' ').replaceAll(',', ';'),
        t.confidence.toStringAsFixed(2),
        t.mitigated.toString(),
        t.tags.join('|'),
      ],
    );
    final buffer = StringBuffer();
    buffer.writeln(header.join(','));
    for (final r in rows) {
      buffer.writeln(r.map(_escapeCsv).join(','));
    }
    return buffer.toString();
  }

  static String _escapeCsv(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }
}
