import 'package:shared_preferences/shared_preferences.dart';

final Set<String> completedConstellationIds = {};
final Set<String> discoveredConstellationIds = {};
final Set<String> discoveredSpecialIds = {};
final Set<String> connectedConstellationEdgeKeys = {};
final Set<String> connectedSpecialEdgeKeys = {};
const _completedConstellationsKey = 'completed_constellations';
const _discoveredConstellationsKey = 'discovered_constellations';
const _discoveredSpecialsKey = 'discovered_specials';
const _connectedConstellationEdgesKey = 'connected_constellation_edges';
const _connectedSpecialEdgesKey = 'connected_special_edges';

Future<void> loadProgress() async {
  final prefs = await SharedPreferences.getInstance();
  final savedIds = prefs.getStringList(_completedConstellationsKey) ?? [];
  final discoveredIds = prefs.getStringList(_discoveredConstellationsKey) ?? [];
  final specialIds = prefs.getStringList(_discoveredSpecialsKey) ?? [];
  final constellationEdgeKeys =
      prefs.getStringList(_connectedConstellationEdgesKey) ?? [];
  final specialEdgeKeys = prefs.getStringList(_connectedSpecialEdgesKey) ?? [];

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
  connectedConstellationEdgeKeys
    ..clear()
    ..addAll(constellationEdgeKeys);
  connectedSpecialEdgeKeys
    ..clear()
    ..addAll(specialEdgeKeys);
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

String _edgeKey(String firstStarId, String secondStarId) {
  final starIds = [firstStarId, secondStarId]..sort();
  return '${starIds[0]}|${starIds[1]}';
}

String _constellationEdgeKey(
  String constellationId,
  String firstStarId,
  String secondStarId,
) {
  return '$constellationId|${_edgeKey(firstStarId, secondStarId)}';
}

bool isConstellationEdgeConnected(
  String constellationId,
  String firstStarId,
  String secondStarId,
) {
  return connectedConstellationEdgeKeys.contains(
    _constellationEdgeKey(constellationId, firstStarId, secondStarId),
  );
}

Future<void> markConstellationEdgeConnected(
  String constellationId,
  String firstStarId,
  String secondStarId,
) async {
  final edgeKey = _constellationEdgeKey(
    constellationId,
    firstStarId,
    secondStarId,
  );
  if (!connectedConstellationEdgeKeys.add(edgeKey)) {
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    _connectedConstellationEdgesKey,
    connectedConstellationEdgeKeys.toList(),
  );
}

bool isSpecialEdgeConnected(String firstStarId, String secondStarId) {
  return connectedSpecialEdgeKeys.contains(_edgeKey(firstStarId, secondStarId));
}

Future<void> markSpecialEdgeConnected(
  String firstStarId,
  String secondStarId,
) async {
  final edgeKey = _edgeKey(firstStarId, secondStarId);
  if (!connectedSpecialEdgeKeys.add(edgeKey)) {
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    _connectedSpecialEdgesKey,
    connectedSpecialEdgeKeys.toList(),
  );
}
