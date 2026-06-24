final Set<String> completedConstellationIds = {};

bool isConstellationCompleted(String constellationId) {
  return completedConstellationIds.contains(constellationId);
}

void markConstellationCompleted(String constellationId) {
  completedConstellationIds.add(constellationId);
}
