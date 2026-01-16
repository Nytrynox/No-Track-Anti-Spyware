import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/threat.dart';

class PersistenceService {
  static const _boxThreats = 'threats_box';
  static const _keyWhitelist = 'whitelist';
  static const _keyBlacklist = 'blacklist';
  static const _keySchedule = 'scan_schedule_cron';

  Box<String>? _threats;
  SharedPreferences? _prefs;

  Future<void> init() async {
    await Hive.initFlutter();
    _threats = await Hive.openBox<String>(_boxThreats);
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> addThreats(List<Threat> list) async {
    await init();
    for (final t in list) {
      await _threats!.put(t.id, json.encode(t.toJson()));
    }
  }

  Future<List<Threat>> getAllThreats() async {
    await init();
    return _threats!.values
        .map((s) => Threat.fromJson(json.decode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
  }

  Future<void> markMitigated(String id) async {
    await init();
    final s = _threats!.get(id);
    if (s == null) return;
    final t = Threat.fromJson(json.decode(s) as Map<String, dynamic>);
    final updated = t.copyWith(mitigated: true);
    await _threats!.put(id, json.encode(updated.toJson()));
  }

  // Whitelist/Blacklist management
  Future<Set<String>> getWhitelist() async => _getStringSet(_keyWhitelist);
  Future<Set<String>> getBlacklist() async => _getStringSet(_keyBlacklist);

  Future<void> addToWhitelist(String pkg) async =>
      _addToSet(_keyWhitelist, pkg);
  Future<void> removeFromWhitelist(String pkg) async =>
      _removeFromSet(_keyWhitelist, pkg);
  Future<void> addToBlacklist(String pkg) async =>
      _addToSet(_keyBlacklist, pkg);
  Future<void> removeFromBlacklist(String pkg) async =>
      _removeFromSet(_keyBlacklist, pkg);

  Future<void> setScanSchedule(String cron) async {
    await _ensurePrefs();
    await _prefs!.setString(_keySchedule, cron);
  }

  Future<String?> getScanSchedule() async {
    await _ensurePrefs();
    return _prefs!.getString(_keySchedule);
  }

  Future<Set<String>> _getStringSet(String key) async {
    await _ensurePrefs();
    final list = _prefs!.getStringList(key) ?? <String>[];
    return list.toSet();
  }

  Future<void> _addToSet(String key, String value) async {
    await _ensurePrefs();
    final set = (_prefs!.getStringList(key) ?? <String>[]).toSet();
    set.add(value);
    await _prefs!.setStringList(key, set.toList());
  }

  Future<void> _removeFromSet(String key, String value) async {
    await _ensurePrefs();
    final set = (_prefs!.getStringList(key) ?? <String>[]).toSet();
    set.remove(value);
    await _prefs!.setStringList(key, set.toList());
  }

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}
