import 'dart:math' as math;

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

  double get _headingDegree {
    final degree = (-_viewOffset.dx / 3) % 360;
    return degree < 0 ? degree + 360 : degree;
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
        child: Stack(
          children: [
            GestureDetector(
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
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 130,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: DirectionMeterPainter(headingDegree: _headingDegree),
                ),
              ),
            ),
          ],
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

class DirectionMeterPainter extends CustomPainter {
  final double headingDegree;

  DirectionMeterPainter({required this.headingDegree});

  static const _directionLabels = ['N', 'E', 'S', 'W'];

  String get _currentDirection {
    final index = ((headingDegree + 45) ~/ 90) % 4;
    return _directionLabels[index];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 8);
    final radius = math.min(size.width * 0.48, 112.0);
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final basePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawArc(arcRect, math.pi, math.pi, true, basePaint);

    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(arcRect, math.pi, math.pi, false, arcPaint);

    for (var degree = -90; degree <= 90; degree += 15) {
      final isMajor = degree % 45 == 0;
      final angle = math.pi + (degree + 90) * math.pi / 180;
      final outer = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final innerRadius = radius - (isMajor ? 18 : 10);
      final inner = Offset(
        center.dx + math.cos(angle) * innerRadius,
        center.dy + math.sin(angle) * innerRadius,
      );

      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = Colors.white.withValues(alpha: isMajor ? 0.9 : 0.45)
          ..strokeWidth = isMajor ? 2 : 1,
      );
    }

    _drawText(canvas, center + const Offset(0, -42), _currentDirection, 22);
    _drawText(
      canvas,
      center + const Offset(0, -18),
      '${headingDegree.round()}°',
      13,
    );

    final needlePaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, center + const Offset(0, -92), needlePaint);
    canvas.drawCircle(center, 5, Paint()..color = Colors.yellow);

    _drawText(canvas, center + Offset(-radius + 18, -14), 'W', 14);
    _drawText(canvas, center + Offset(radius - 18, -14), 'E', 14);
    _drawText(canvas, center + Offset(0, -radius + 16), 'N', 14);
  }

  void _drawText(Canvas canvas, Offset center, String text, double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant DirectionMeterPainter oldDelegate) {
    return oldDelegate.headingDegree != headingDegree;
  }
}
