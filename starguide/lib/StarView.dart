import 'package:flutter/material.dart';

import 'data/constellation_data.dart';
import 'data/progress_data.dart';
import 'models/constellation.dart';
import 'models/constellation_edge.dart';
import 'models/star.dart';

class StarView extends StatefulWidget {
  const StarView({super.key});

  @override
  State<StarView> createState() => _StarViewState();
}

class _StarViewState extends State<StarView> {
  int _selectedConstellationIndex = 0;
  Star? _selectedStar;
  Star? _wrongStar;
  final List<ConstellationEdge> _connectedEdges = [];
  bool _isConstellationCompleted = false;
  Offset _viewOffset = Offset.zero;

  Constellation get _currentConstellation {
    return constellations[_selectedConstellationIndex];
  }

  void _changeConstellation(int index) {
    setState(() {
      _selectedConstellationIndex = index;
      _selectedStar = null;
      _wrongStar = null;
      _connectedEdges.clear();
      _isConstellationCompleted = isConstellationCompleted(
        _currentConstellation.id,
      );
      _viewOffset = Offset.zero;
    });
  }

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

  void _showWrongFeedback(Star tappedStar) {
    setState(() {
      _wrongStar = tappedStar;
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted || _wrongStar?.id != tappedStar.id) {
        return;
      }

      setState(() {
        _wrongStar = null;
      });
    });
  }

  void _handleTappedStar(
    Star tappedStar,
    Constellation constellation,
    BuildContext context,
  ) {
    final previousStar = _selectedStar;
    var completedNow = false;

    if (previousStar != null && previousStar.id != tappedStar.id) {
      final isCorrect = _isCorrectPair(previousStar, tappedStar, constellation);

      if (isCorrect) {
        final matchingEdge = _findMatchingEdge(
          previousStar,
          tappedStar,
          constellation,
        );

        if (matchingEdge != null && !_isAlreadyConnected(matchingEdge)) {
          _connectedEdges.add(matchingEdge);
          markConstellationDiscovered(constellation.id);

          if (!_isConstellationCompleted && _isCompleted(constellation)) {
            _isConstellationCompleted = true;
            markConstellationCompleted(constellation.id);
            completedNow = true;
          }
        }
      } else {
        _showWrongFeedback(tappedStar);
      }
    }

    setState(() {
      _selectedStar = tappedStar;
    });

    if (completedNow) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${constellation.name} 完成！ 図鑑に登録されました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final constellation = _currentConstellation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('星空ガイドビュー'),
        actions: [
          DropdownButton<int>(
            value: _selectedConstellationIndex,
            dropdownColor: Colors.black87,
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox.shrink(),
            items: [
              for (var i = 0; i < constellations.length; i++)
                DropdownMenuItem(value: i, child: Text(constellations[i].name)),
            ],
            onChanged: (value) {
              if (value != null) {
                _changeConstellation(value);
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SizedBox.expand(
        child: GestureDetector(
          onTapDown: (details) {
            final position = details.localPosition - _viewOffset;
            final tappedStar = _findTappedStar(position, constellation);

            if (tappedStar != null) {
              _handleTappedStar(tappedStar, constellation, context);
            }
          },
          onPanUpdate: (details) {
            setState(() {
              _viewOffset += details.delta;
            });
          },
          child: CustomPaint(
            painter: StarPainter(
              constellation: constellation,
              selectedStar: _selectedStar,
              wrongStar: _wrongStar,
              connectedEdges: List.unmodifiable(_connectedEdges),
              viewOffset: _viewOffset,
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
  final Star? wrongStar;
  final List<ConstellationEdge> connectedEdges;
  final Offset viewOffset;

  StarPainter({
    required this.constellation,
    required this.selectedStar,
    required this.wrongStar,
    required this.connectedEdges,
    required this.viewOffset,
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
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF050816),
    );
    canvas.translate(viewOffset.dx, viewOffset.dy);

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
      final isWrong = wrongStar?.id == star.id;
      final paint = Paint()
        ..color = isWrong
            ? Colors.grey.shade700
            : isSelected
            ? Colors.yellow
            : star.color;
      final radius = isSelected ? 7.0 : 4.0 + star.brightness * 2;

      canvas.drawCircle(Offset(star.x, star.y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) {
    return oldDelegate.constellation.id != constellation.id ||
        oldDelegate.selectedStar?.id != selectedStar?.id ||
        oldDelegate.wrongStar?.id != wrongStar?.id ||
        oldDelegate.connectedEdges.length != connectedEdges.length ||
        oldDelegate.viewOffset != viewOffset;
  }
}
