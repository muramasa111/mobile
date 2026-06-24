import 'package:shared_preferences/shared_preferences.dart';

final Set<String> completedConstellationIds = {};
const _completedConstellationsKey = 'completed_constellations';

Future<void> loadProgress() async {
  final prefs = await SharedPreferences.getInstance();
  final savedIds = prefs.getStringList(_completedConstellationsKey) ?? [];

  completedConstellationIds
    ..clear()
    ..addAll(savedIds);
}

bool isConstellationCompleted(String constellationId) {
  return completedConstellationIds.contains(constellationId);
}

Future<void> markConstellationCompleted(String constellationId) async {
  completedConstellationIds.add(constellationId);

  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    _completedConstellationsKey,
    completedConstellationIds.toList(),
  );
}
