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
const _summerTriangleId = 'summer_triangle';
const _summerTriangleRequiredConstellationIds = ['lyra', 'aquila', 'cygnus'];
const _summerTriangleEdges = [
  ConstellationEdge(fromStarId: 'vega', toStarId: 'altair'),
  ConstellationEdge(fromStarId: 'altair', toStarId: 'deneb'),
  ConstellationEdge(fromStarId: 'deneb', toStarId: 'vega'),
];

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

class _ConstellationStar {
  final Constellation constellation;
  final Star star;

  const _ConstellationStar({
    required this.constellation,
    required this.star,
  });
}

class StarView extends StatefulWidget {
  const StarView({super.key});

  @override
  State<StarView> createState() => _StarViewState();
}

class _StarViewState extends State<StarView> {
  int _selectedConstellationIndex = 0;
  _ConstellationStar? _selectedStar;
  _ConstellationStar? _wrongStar;
  final Map<String, List<ConstellationEdge>> _connectedEdgesByConstellation = {
    for (final constellation in constellations)
      constellation.id: <ConstellationEdge>[],
  };
  final List<ConstellationEdge> _connectedSummerTriangleEdges = [];
  bool _showConstellationLines = true;
  bool _showSpecialLines = true;
  Offset _viewOffset = Offset.zero;

  Constellation get _currentConstellation {
    return constellations[_selectedConstellationIndex];
  }

  @override
  void initState() {
    super.initState();
    _viewOffset = _initialViewOffset(_currentConstellation);
    _restoreConnectedEdges();
  }

  void _restoreConnectedEdges() {
    for (final constellation in constellations) {
      final connectedEdges = _connectedEdgesByConstellation[constellation.id]!;
      connectedEdges.addAll(
        constellation.edges.where(
          (edge) => isConstellationEdgeConnected(
            constellation.id,
            edge.fromStarId,
            edge.toStarId,
          ),
        ),
      );
    }

    _connectedSummerTriangleEdges.addAll(
      _summerTriangleEdges.where(
        (edge) => isSpecialEdgeConnected(edge.fromStarId, edge.toStarId),
      ),
    );
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
      _viewOffset = _initialViewOffset(_currentConstellation);
    });
  }

  _ConstellationStar? _findTappedStar(Offset position) {
    const tapRadius = 16.0;
    final skyPosition = Offset(
      _wrapSkyX(position.dx - _viewOffset.dx),
      position.dy - _viewOffset.dy,
    );

    for (final constellation in constellations) {
      for (final star in constellation.stars) {
        final starPosition = _starSkyPosition(constellation, star);

        if ((starPosition - skyPosition).distance <= tapRadius) {
          return _ConstellationStar(constellation: constellation, star: star);
        }
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

  bool _isAlreadyConnected(
    ConstellationEdge targetEdge,
    Constellation constellation,
  ) {
    final connectedEdges = _connectedEdgesByConstellation[constellation.id]!;

    for (final edge in connectedEdges) {
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
    return _connectedEdgesByConstellation[constellation.id]!.length ==
        constellation.edges.length;
  }

  bool get _canDiscoverSummerTriangle {
    return _summerTriangleRequiredConstellationIds.every(
      isConstellationCompleted,
    );
  }

  ConstellationEdge? _findSummerTriangleEdge(
    Star firstStar,
    Star secondStar,
  ) {
    for (final edge in _summerTriangleEdges) {
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

  bool _isSummerTriangleEdgeAlreadyConnected(ConstellationEdge targetEdge) {
    for (final edge in _connectedSummerTriangleEdges) {
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

  void _showWrongFeedback(_ConstellationStar tappedStar) {
    setState(() {
      _wrongStar = tappedStar;
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted || _wrongStar?.star.id != tappedStar.star.id) {
        return;
      }

      setState(() {
        _wrongStar = null;
      });
    });
  }

  void _handleTappedStar(
    _ConstellationStar tappedStar,
    BuildContext context,
  ) {
    final previousStar = _selectedStar;
    final constellation = tappedStar.constellation;
    var completedNow = false;
    var summerTriangleCompletedNow = false;

    if (previousStar != null && previousStar.star.id != tappedStar.star.id) {
      final isSameConstellation =
          previousStar.constellation.id == constellation.id;
      final isConstellationConnection =
          isSameConstellation &&
          _isCorrectPair(previousStar.star, tappedStar.star, constellation);
      final summerTriangleEdge = !isSameConstellation && _canDiscoverSummerTriangle
          ? _findSummerTriangleEdge(previousStar.star, tappedStar.star)
          : null;

      if (isConstellationConnection) {
        final matchingEdge = _findMatchingEdge(
          previousStar.star,
          tappedStar.star,
          constellation,
        );

        if (matchingEdge != null &&
            !_isAlreadyConnected(matchingEdge, constellation)) {
          _connectedEdgesByConstellation[constellation.id]!.add(matchingEdge);
          markConstellationEdgeConnected(
            constellation.id,
            matchingEdge.fromStarId,
            matchingEdge.toStarId,
          );
          markConstellationDiscovered(constellation.id);

          if (!isConstellationCompleted(constellation.id) &&
              _isCompleted(constellation)) {
            markConstellationCompleted(constellation.id);
            completedNow = true;
          }
        }
      } else if (summerTriangleEdge != null) {
        if (!_isSummerTriangleEdgeAlreadyConnected(summerTriangleEdge)) {
          _connectedSummerTriangleEdges.add(summerTriangleEdge);
          markSpecialEdgeConnected(
            summerTriangleEdge.fromStarId,
            summerTriangleEdge.toStarId,
          );

          if (!isSpecialDiscovered(_summerTriangleId) &&
              _connectedSummerTriangleEdges.length ==
                  _summerTriangleEdges.length) {
            markSpecialDiscovered(_summerTriangleId);
            summerTriangleCompletedNow = true;
          }
        }
      } else {
        _showWrongFeedback(tappedStar);
      }
    }

    setState(() {
      _selectedStar = tappedStar;
    });

    if (summerTriangleCompletedNow) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('夏の大三角を発見！ 図鑑に登録されました')),
      );
    } else if (completedNow) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${constellation.name} 完成！ 図鑑に登録されました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(width: 8),
          PopupMenuButton<void>(
            tooltip: 'ライン表示設定',
            icon: const Icon(Icons.visibility),
            color: const Color(0xFF1C2B4A),
            itemBuilder: (context) => [
              PopupMenuItem<void>(
                enabled: false,
                child: StatefulBuilder(
                  builder: (context, setMenuState) {
                    return SizedBox(
                      width: 220,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              '星座線',
                              style: TextStyle(color: Colors.white),
                            ),
                            value: _showConstellationLines,
                            onChanged: (value) {
                              setState(() {
                                _showConstellationLines = value;
                              });
                              setMenuState(() {});
                            },
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              '特別発見の線',
                              style: TextStyle(color: Colors.white),
                            ),
                            value: _showSpecialLines,
                            onChanged: (value) {
                              setState(() {
                                _showSpecialLines = value;
                              });
                              setMenuState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            GestureDetector(
              onTapDown: (details) {
                final tappedStar = _findTappedStar(details.localPosition);

                if (tappedStar != null) {
                  _handleTappedStar(tappedStar, context);
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
                  allConstellations: constellations,
                  selectedStar: _selectedStar?.star,
                  wrongStar: _wrongStar?.star,
                  connectedEdgesByConstellation: Map.unmodifiable(
                    _connectedEdgesByConstellation.map(
                      (id, edges) => MapEntry(
                        id,
                        List<ConstellationEdge>.unmodifiable(edges),
                      ),
                    ),
                  ),
                  summerTriangleEdges: List<ConstellationEdge>.unmodifiable(
                    _connectedSummerTriangleEdges,
                  ),
                  showConstellationLines: _showConstellationLines,
                  showSpecialLines: _showSpecialLines,
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
  final List<Constellation> allConstellations;
  final Star? selectedStar;
  final Star? wrongStar;
  final Map<String, List<ConstellationEdge>> connectedEdgesByConstellation;
  final List<ConstellationEdge> summerTriangleEdges;
  final bool showConstellationLines;
  final bool showSpecialLines;
  final Offset viewOffset;

  StarPainter({
    required this.allConstellations,
    required this.selectedStar,
    required this.wrongStar,
    required this.connectedEdgesByConstellation,
    required this.summerTriangleEdges,
    required this.showConstellationLines,
    required this.showSpecialLines,
    required this.viewOffset,
  });

  Star? _findStarById(Constellation constellation, String starId) {
    for (final star in constellation.stars) {
      if (star.id == starId) {
        return star;
      }
    }

    return null;
  }

  _ConstellationStar? _findConstellationStarById(String starId) {
    for (final constellation in allConstellations) {
      final star = _findStarById(constellation, starId);
      if (star != null) {
        return _ConstellationStar(constellation: constellation, star: star);
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
    final specialLinePaint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 3;

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

      for (final constellation in allConstellations) {
        if (showConstellationLines) {
          for (final edge in connectedEdgesByConstellation[constellation.id]!) {
            final fromStar = _findStarById(constellation, edge.fromStarId);
            final toStar = _findStarById(constellation, edge.toStarId);

            if (fromStar != null && toStar != null) {
              final fromPosition = _starSkyPosition(constellation, fromStar);
              final toPosition = _starSkyPosition(constellation, toStar);
              canvas.drawLine(
                Offset(fromPosition.dx + offsetX, fromPosition.dy),
                Offset(toPosition.dx + offsetX, toPosition.dy),
                linePaint,
              );
            }
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

      if (showSpecialLines) {
        for (final edge in summerTriangleEdges) {
          final fromStar = _findConstellationStarById(edge.fromStarId);
          final toStar = _findConstellationStarById(edge.toStarId);

          if (fromStar != null && toStar != null) {
            final fromPosition = _starSkyPosition(
              fromStar.constellation,
              fromStar.star,
            );
            final toPosition = _starSkyPosition(
              toStar.constellation,
              toStar.star,
            );
            canvas.drawLine(
              Offset(fromPosition.dx + offsetX, fromPosition.dy),
              Offset(toPosition.dx + offsetX, toPosition.dy),
              specialLinePaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) {
    return oldDelegate.selectedStar?.id != selectedStar?.id ||
        oldDelegate.wrongStar?.id != wrongStar?.id ||
        oldDelegate.connectedEdgesByConstellation !=
            connectedEdgesByConstellation ||
        oldDelegate.summerTriangleEdges.length != summerTriangleEdges.length ||
        oldDelegate.showConstellationLines != showConstellationLines ||
        oldDelegate.showSpecialLines != showSpecialLines ||
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

  double _relativeDegree(double bearingDegree) {
    return (bearingDegree - headingDegree + 540) % 360 - 180;
  }

  Offset _positionOnArc(Offset center, double radius, double relativeDegree) {
    final angle = math.pi + (relativeDegree + 90) * math.pi / 180;
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
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

    for (var bearing = 0; bearing < 360; bearing += 15) {
      final relativeDegree = _relativeDegree(bearing.toDouble());
      if (relativeDegree < -90 || relativeDegree > 90) {
        continue;
      }

      final isMajor = bearing % 45 == 0;
      final outer = _positionOnArc(center, radius, relativeDegree);
      final innerRadius = radius - (isMajor ? 18 : 10);
      final inner = _positionOnArc(center, innerRadius, relativeDegree);

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

    const directionLabels = <int, String>{
      0: 'N',
      90: 'E',
      180: 'S',
      270: 'W',
    };

    for (final entry in directionLabels.entries) {
      final relativeDegree = _relativeDegree(entry.key.toDouble());
      if (relativeDegree < -90 || relativeDegree > 90) {
        continue;
      }

      _drawText(
        canvas,
        _positionOnArc(center, radius - 30, relativeDegree),
        entry.value,
        14,
      );
    }
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
