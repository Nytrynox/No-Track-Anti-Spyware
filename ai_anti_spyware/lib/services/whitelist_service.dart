import 'package:shared_preferences/shared_preferences.dart';

import '../models/threat.dart';

class WhitelistService {
  static const _keyWhitelist = 'whitelist';
  static const _keyBlacklist = 'blacklist';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<Set<String>> getWhitelist() async {
    await init();
    return (_prefs!.getStringList(_keyWhitelist) ?? const <String>[]).toSet();
  }

  Future<Set<String>> getBlacklist() async {
    await init();
    return (_prefs!.getStringList(_keyBlacklist) ?? const <String>[]).toSet();
  }

  Future<void> addToWhitelist(String pkg) async {
    await init();
    final set = await getWhitelist();
    set.add(pkg);
    await _prefs!.setStringList(_keyWhitelist, set.toList());
  }

  Future<void> removeFromWhitelist(String pkg) async {
    await init();
    final set = await getWhitelist();
    set.remove(pkg);
    await _prefs!.setStringList(_keyWhitelist, set.toList());
  }

  Future<void> addToBlacklist(String pkg) async {
    await init();
    final set = await getBlacklist();
    set.add(pkg);
    await _prefs!.setStringList(_keyBlacklist, set.toList());
  }

  Future<void> removeFromBlacklist(String pkg) async {
    await init();
    final set = await getBlacklist();
    set.remove(pkg);
    await _prefs!.setStringList(_keyBlacklist, set.toList());
  }

  Future<List<Threat>> filterThreats(List<Threat> threats) async {
    final whitelist = await getWhitelist();
    final blacklist = await getBlacklist();
    return threats.where((t) {
      final pkgId = _extractPkg(t.id);
      if (whitelist.contains(pkgId)) return false; // ignore whitelisted
      if (blacklist.contains(pkgId)) return true; // always include blacklisted
      return true;
    }).toList();
  }

  String _extractPkg(String id) {
    // id format examples: pkg:com.example.app or apk:/path/file.apk
    if (id.startsWith('pkg:')) {
      return id.substring(4);
    }
    return id;
  }
}
