import 'package:flutter/material.dart';

import 'models/constellation.dart';
import 'widgets/star_background.dart';

class ConstellationDetail extends StatelessWidget {
  final Constellation? constellation;

  const ConstellationDetail({super.key, this.constellation});

  @override
  Widget build(BuildContext context) {
    final selectedConstellation = constellation;

    return Scaffold(
      appBar: AppBar(title: Text(selectedConstellation?.name ?? '星座詳細')),
      backgroundColor: const Color(0xFF050816),
      body: StarBackground(
        child: selectedConstellation == null
            ? const Center(
                child: Text(
                  '星座図鑑から星座を選択してください',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : DefaultTextStyle(
                style: const TextStyle(color: Colors.white),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      selectedConstellation.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(selectedConstellation.description),
                    const SizedBox(height: 24),
                    _DetailRow(
                      label: '代表的な星',
                      value: selectedConstellation.representativeStars,
                    ),
                    _DetailRow(label: '季節', value: selectedConstellation.season),
                    _DetailRow(label: '方角', value: selectedConstellation.direction),
                    _DetailRow(label: '神話', value: selectedConstellation.myth),
                    _DetailRow(label: '豆知識', value: selectedConstellation.trivia),
                    const SizedBox(height: 24),
                    Text('星の数: ${selectedConstellation.stars.length}'),
                    Text('星座線の数: ${selectedConstellation.edges.length}'),
                    const SizedBox(height: 24),
                    const Text(
                      '含まれる星',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    for (final star in selectedConstellation.stars) Text('・${star.name}'),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
