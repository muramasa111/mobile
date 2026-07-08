import 'package:flutter/material.dart';

import 'ConstellationDetail.dart';
import 'ConstellationList.dart';
import 'Settings.dart';
import 'StarView.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ホーム')),
      backgroundColor: const Color(0xFF1a237e),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StarView()),
                );
              },
              child: const Text('星空ガイドビュー'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConstellationList(),
                  ),
                );
              },
              child: const Text('星座図鑑'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConstellationDetail(),
                  ),
                );
              },
              child: const Text('星座詳細'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Settings()),
                );
              },
              child: const Text('設定'),
            ),
          ],
        ),
      ),
    );
  }
}
