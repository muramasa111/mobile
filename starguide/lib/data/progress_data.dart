import 'package:shared_preferences/shared_preferences.dart';

final Set<String> completedConstellationIds = {};
final Set<String> discoveredConstellationIds = {};
final Set<String> discoveredSpecialIds = {};
const _completedConstellationsKey = 'completed_constellations';
const _discoveredConstellationsKey = 'discovered_constellations';
const _discoveredSpecialsKey = 'discovered_specials';

Future<void> loadProgress() async {
  final prefs = await SharedPreferences.getInstance();
  final savedIds = prefs.getStringList(_completedConstellationsKey) ?? [];
  final discoveredIds = prefs.getStringList(_discoveredConstellationsKey) ?? [];
  final specialIds = prefs.getStringList(_discoveredSpecialsKey) ?? [];

  completedConstellationIds
    ..clear()
    ..addAll(savedIds);
  discoveredConstellationIds
    ..clear()
    ..addAll(discoveredIds)
    ..addAll(savedIds);
  discoveredSpecialIds
    ..clear()
    ..addAll(specialIds);
}

bool isConstellationDiscovered(String constellationId) {
  return discoveredConstellationIds.contains(constellationId);
}

bool isConstellationCompleted(String constellationId) {
  return completedConstellationIds.contains(constellationId);
}

Future<void> markConstellationDiscovered(String constellationId) async {
  if (!discoveredConstellationIds.add(constellationId)) {
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    _discoveredConstellationsKey,
    discoveredConstellationIds.toList(),
  );
}

Future<void> markConstellationCompleted(String constellationId) async {
  await markConstellationDiscovered(constellationId);
  completedConstellationIds.add(constellationId);

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    _completedConstellationsKey,
    completedConstellationIds.toList(),
  );
}

bool isSpecialDiscovered(String specialId) {
  return discoveredSpecialIds.contains(specialId);
}

Future<void> markSpecialDiscovered(String specialId) async {
  if (!discoveredSpecialIds.add(specialId)) {
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    _discoveredSpecialsKey,
    discoveredSpecialIds.toList(),
  );
}
