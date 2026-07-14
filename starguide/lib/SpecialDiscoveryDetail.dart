import 'package:flutter/material.dart';

class SpecialDiscoveryDetail extends StatelessWidget {
  const SpecialDiscoveryDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('夏の大三角')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            '夏の大三角',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text('こと座のベガ、わし座のアルタイル、白鳥座のデネブを結ぶ夏の夜空の目印です。'),
          SizedBox(height: 24),
          _DetailRow(label: '代表星', value: 'ベガ・アルタイル・デネブ'),
          _DetailRow(label: '季節', value: '夏'),
          _DetailRow(label: '豆知識', value: '3つの星はそれぞれ別の星座に属しています。'),
        ],
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
          SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
