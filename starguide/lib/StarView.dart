import 'package:flutter/material.dart';
import 'data/constellation_data.dart';
import 'models/constellation.dart';
import 'models/star.dart';
//import '../sample/SecondPage.dart';

class StarView extends StatefulWidget {
  @override
  State<StarView> createState() => _StarViewState();
}

class _StarViewState extends State<StarView> {
  Star? _selectedStar;

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

  void _handleTappedStar(Star tappedStar, Constellation constellation) {
    final previousStar = _selectedStar;

    if (previousStar != null && previousStar.id != tappedStar.id) {
      final isCorrect = _isCorrectPair(
        previousStar,
        tappedStar,
        constellation,
      );

      if (isCorrect) {
        debugPrint('Correct pair: ${previousStar.name} -> ${tappedStar.name}');
      } else {
        debugPrint('Wrong pair: ${previousStar.name} -> ${tappedStar.name}');
      }
    }

    setState(() {
      _selectedStar = tappedStar;
    });
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
              _handleTappedStar(tappedStar, constellation);
            }
          },
          child: CustomPaint(
            painter: StarPainter(
              constellation: constellation,
              selectedStar: _selectedStar,
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

  StarPainter({
    required this.constellation,
    required this.selectedStar,
  });

  @override
  void paint(Canvas canvas, Size size) {
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
    return oldDelegate.selectedStar?.id != selectedStar?.id;
  }
}
