import 'package:flutter/material.dart';

import 'ConstellationList.dart';
import 'StarView.dart';
import 'widgets/star_background.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ホーム')),
      backgroundColor: const Color(0xFF050816),
      body: StarBackground(
        child: Center(
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
        ),
    );
  }
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
