import 'star.dart';
import 'constellation_edge.dart';

class Constellation {
  final String id;
  final String name;
  final String description;
  final List<Star> stars;
  final List<ConstellationEdge> edges;

  const Constellation({
    required this.id,
    required this.name,
    required this.description,
    required this.stars,
    required this.edges,
  });
}