import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'data/constellation_data.dart';
import 'data/progress_data.dart';
import 'models/constellation.dart';
import 'models/constellation_edge.dart';
import 'models/star.dart';

const _skyWidth = 3600.0;
const _skyHeight = 1800.0;
const _minimumSkyOffsetY = -1500.0;
const _maximumSkyOffsetY = 0.0;

const _constellationOrigins = <String, Offset>{
  'capricornus': Offset(3000, 1000),
  'lyra': Offset(1500, 260),
  'aquila': Offset(1850, 650),
  'cygnus': Offset(2150, 220),
};

double _wrapSkyX(double value) {
  final wrapped = value % _skyWidth;
  return wrapped < 0 ? wrapped + _skyWidth : wrapped;
}

Offset _starSkyPosition(Constellation constellation, Star star) {
  final origin = _constellationOrigins[constellation.id] ?? Offset.zero;
  return origin + Offset(star.x, star.y);
}

Offset _initialViewOffset(Constellation constellation) {
  final origin = _constellationOrigins[constellation.id] ?? Offset.zero;
  return Offset(
    _wrapSkyX(-origin.dx + 80),
    (-origin.dy + 120).clamp(_minimumSkyOffsetY, _maximumSkyOffsetY).toDouble(),
  );
}

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

  @override
  void initState() {
    super.initState();
    _viewOffset = _initialViewOffset(_currentConstellation);
  }

  double get _headingDegree {
    final degree = (-_viewOffset.dx / 10) % 360;
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
      _viewOffset = _initialViewOffset(_currentConstellation);
    });
  }

  Star? _findTappedStar(Offset position, Constellation constellation) {
    const tapRadius = 16.0;
    final skyPosition = Offset(
      _wrapSkyX(position.dx - _viewOffset.dx),
      position.dy - _viewOffset.dy,
    );

    for (final star in constellation.stars) {
      final starPosition = _starSkyPosition(constellation, star);

      if ((starPosition - skyPosition).distance <= tapRadius) {
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
                final tappedStar = _findTappedStar(
                  details.localPosition,
                  constellation,
                );

                if (tappedStar != null) {
                  _handleTappedStar(tappedStar, constellation, context);
                }
              },
              onPanUpdate: (details) {
                setState(() {
                  _viewOffset = Offset(
                    _wrapSkyX(_viewOffset.dx + details.delta.dx),
                    (_viewOffset.dy + details.delta.dy)
                        .clamp(_minimumSkyOffsetY, _maximumSkyOffsetY)
                        .toDouble(),
                  );
                });
              },
              child: CustomPaint(
                painter: StarPainter(
                  constellation: constellation,
                  allConstellations: constellations,
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
  final List<Constellation> allConstellations;
  final Star? selectedStar;
  final Star? wrongStar;
  final List<ConstellationEdge> connectedEdges;
  final Offset viewOffset;

  StarPainter({
    required this.constellation,
    required this.allConstellations,
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
    canvas.translate(0, viewOffset.dy);

    final linePaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;

    final startX = _wrapSkyX(viewOffset.dx) - _skyWidth;
    final endX = size.width + _skyWidth;

    for (var offsetX = startX; offsetX <= endX; offsetX += _skyWidth) {
      for (var index = 0; index < 160; index++) {
        final x = (index * 233.0) % _skyWidth;
        final y = 50 + (index * 149.0) % (_skyHeight - 100);
        final radius = 1.0 + (index % 3) * 0.5;

        canvas.drawCircle(
          Offset(x + offsetX, y),
          radius,
          Paint()..color = Colors.white.withValues(alpha: 0.4),
        );
      }

      for (final backgroundConstellation in allConstellations) {
        if (backgroundConstellation.id == constellation.id) {
          continue;
        }

        for (final star in backgroundConstellation.stars) {
          final starPosition = _starSkyPosition(backgroundConstellation, star);
          canvas.drawCircle(
            Offset(starPosition.dx + offsetX, starPosition.dy),
            2.5 + star.brightness,
            Paint()..color = Colors.white.withValues(alpha: 0.55),
          );
        }
      }

      for (final edge in connectedEdges) {
        final fromStar = _findStarById(edge.fromStarId);
        final toStar = _findStarById(edge.toStarId);

        if (fromStar != null && toStar != null) {
          canvas.drawLine(
            Offset(
              _starSkyPosition(constellation, fromStar).dx + offsetX,
              _starSkyPosition(constellation, fromStar).dy,
            ),
            Offset(
              _starSkyPosition(constellation, toStar).dx + offsetX,
              _starSkyPosition(constellation, toStar).dy,
            ),
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

        final starPosition = _starSkyPosition(constellation, star);
        canvas.drawCircle(
          Offset(starPosition.dx + offsetX, starPosition.dy),
          radius,
          paint,
        );
      }
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
