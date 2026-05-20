import 'package:flutter/material.dart';
import 'data/constellation_data.dart';
import 'models/constellation.dart';
//import '../sample/SecondPage.dart';

class StarView extends StatefulWidget {
  @override
  State<StarView> createState() => _StarViewState();
}

class _StarViewState extends State<StarView> {
  @override
  Widget build(BuildContext context) {
    final constellation = constellations[0];

    return Scaffold(
      appBar: AppBar(title: Text("天体観測")),

      body: SizedBox.expand(
        child: GestureDetector(
          onTapDown: (details) {
            final position = details.localPosition;
            print(position); // Handle tap down event
          },
          child: CustomPaint(
            painter: StarPainter(constellation: constellation),
          ),
        ),
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  final Constellation constellation;

  StarPainter({required this.constellation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red;

    for (final star in constellation.stars) {
      canvas.drawCircle(Offset(star.x, star.y), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
