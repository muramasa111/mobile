import 'package:flutter/material.dart';

import 'ConstellationList.dart';
import 'StarView.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ホーム')),
      backgroundColor: const Color(0xFF050816),
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _HomeStarPainter())),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HomeMenuButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StarView()),
                    );
                  },
                  label: '星空ガイドビュー',
                ),
                const SizedBox(height: 20),
                _HomeMenuButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConstellationList(),
                      ),
                    );
                  },
                  label: '星座図鑑',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeStarPainter extends CustomPainter {
  const _HomeStarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < 100; index++) {
      final x = (index * 233.0) % size.width;
      final y = (index * 149.0) % size.height;
      final radius = 0.7 + (index % 3) * 0.4;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = Colors.white.withValues(alpha: 0.38),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HomeStarPainter oldDelegate) => false;
}

class _HomeMenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _HomeMenuButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 96,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C2B4A),
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
