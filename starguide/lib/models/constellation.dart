import 'star.dart';
import 'constellation_edge.dart';

class Constellation {
  final String id;
  final String name;
  final String description;
  final String representativeStars;
  final String season;
  final String direction;
  final String myth;
  final String trivia;
  final List<Star> stars;
  final List<ConstellationEdge> edges;

  const Constellation({
    required this.id,
    required this.name,
    required this.description,
    required this.representativeStars,
    required this.season,
    required this.direction,
    required this.myth,
    required this.trivia,
    required this.stars,
    required this.edges,
  });
}
