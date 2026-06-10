import 'package:flutter/material.dart';
import 'data/constellation_data.dart';
import 'models/constellation.dart';
import 'models/constellation_edge.dart';
import 'models/star.dart';
//import '../sample/SecondPage.dart';

class StarView extends StatefulWidget {
  @override
  State<StarView> createState() => _StarViewState();
}

class _StarViewState extends State<StarView> {
  Star? _selectedStar;
  final List<ConstellationEdge> _connectedEdges = [];
  bool _isConstellationCompleted = false;

  Star? _findTappedStar(Offset position, Constellation constellation) {
    const tapRadius = 16.0;

    for (final star in constellation.stars) {
      final starPosition = Offset(star.x, star.y);

      if ((starPosition - position).distance <= tapRadius) {
        return star;
      }
    }

    return null;
  }

  bool _isCorrectPair(
    Star firstStar,
    Star secondStar,
    Constellation constellation,
  ) {
    for (final edge in constellation.edges) {
      final isForward =
          edge.fromStarId == firstStar.id && edge.toStarId == secondStar.id;
      final isBackward =
          edge.fromStarId == secondStar.id && edge.toStarId == firstStar.id;

      if (isForward || isBackward) {
        return true;
      }
    }

    return false;
  }

  ConstellationEdge? _findMatchingEdge(
    Star firstStar,
    Star secondStar,
    Constellation constellation,
  ) {
    for (final edge in constellation.edges) {
      final isForward =
          edge.fromStarId == firstStar.id && edge.toStarId == secondStar.id;
      final isBackward =
          edge.fromStarId == secondStar.id && edge.toStarId == firstStar.id;

      if (isForward || isBackward) {
        return edge;
      }
    }

    return null;
  }

  bool _isAlreadyConnected(ConstellationEdge targetEdge) {
    for (final edge in _connectedEdges) {
      final isSameDirection =
          edge.fromStarId == targetEdge.fromStarId &&
          edge.toStarId == targetEdge.toStarId;
      final isOppositeDirection =
          edge.fromStarId == targetEdge.toStarId &&
          edge.toStarId == targetEdge.fromStarId;

      if (isSameDirection || isOppositeDirection) {
        return true;
      }
    }

    return false;
  }

  bool _isCompleted(Constellation constellation) {
    return _connectedEdges.length == constellation.edges.length;
  }

  void _handleTappedStar(
    Star tappedStar,
    Constellation constellation,
    BuildContext context,
  ) {
    final previousStar = _selectedStar;
    var completedNow = false;

    if (previousStar != null && previousStar.id != tappedStar.id) {
      final isCorrect = _isCorrectPair(
        previousStar,
        tappedStar,
        constellation,
      );

      if (isCorrect) {
        debugPrint('Correct pair: ${previousStar.name} -> ${tappedStar.name}');

        final matchingEdge = _findMatchingEdge(
          previousStar,
          tappedStar,
          constellation,
        );

        if (matchingEdge != null && !_isAlreadyConnected(matchingEdge)) {
          _connectedEdges.add(matchingEdge);

          if (!_isConstellationCompleted && _isCompleted(constellation)) {
            _isConstellationCompleted = true;
            completedNow = true;
          }
        }
      } else {
        debugPrint('Wrong pair: ${previousStar.name} -> ${tappedStar.name}');
      }
    }

    setState(() {
      _selectedStar = tappedStar;
    });

    if (completedNow) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${constellation.name} 完成！'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final constellation = constellations[0];

    return Scaffold(
      appBar: AppBar(title: Text("天体観測")),

      body: SizedBox.expand(
        child: GestureDetector(
          onTapDown: (details) {
            final position = details.localPosition;
            final tappedStar = _findTappedStar(position, constellation);

            if (tappedStar != null) {
              _handleTappedStar(tappedStar, constellation, context);
            }
          },
          child: CustomPaint(
            painter: StarPainter(
              constellation: constellation,
              selectedStar: _selectedStar,
              connectedEdges: List.unmodifiable(_connectedEdges),
            ),
          ),
        ),
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  final Constellation constellation;
  final Star? selectedStar;
  final List<ConstellationEdge> connectedEdges;

  StarPainter({
    required this.constellation,
    required this.selectedStar,
    required this.connectedEdges,
  });

  Star? _findStarById(String starId) {
    for (final star in constellation.stars) {
      if (star.id == starId) {
        return star;
      }
    }

    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;

    for (final edge in connectedEdges) {
      final fromStar = _findStarById(edge.fromStarId);
      final toStar = _findStarById(edge.toStarId);

      if (fromStar != null && toStar != null) {
        canvas.drawLine(
          Offset(fromStar.x, fromStar.y),
          Offset(toStar.x, toStar.y),
          linePaint,
        );
      }
    }

    for (final star in constellation.stars) {
      final isSelected = selectedStar?.id == star.id;
      final paint = Paint()
        ..color = isSelected ? Colors.yellow : Colors.red;

      canvas.drawCircle(
        Offset(star.x, star.y),
        isSelected ? 7 : 4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) {
    return oldDelegate.selectedStar?.id != selectedStar?.id ||
        oldDelegate.connectedEdges.length != connectedEdges.length;
  }
}
