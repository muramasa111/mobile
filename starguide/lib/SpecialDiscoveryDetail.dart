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
          _DetailRow(label: '織姫と彦星', value: 'ベガは織姫星、アルタイルは彦星として知られています。'),
          _DetailRow(
            label: '七夕の物語',
            value: '織姫と彦星は天の川に隔てられ、年に一度、7月7日の夜に会えると伝えられています。',
          ),
          _DetailRow(
            label: 'デネブ',
            value: '白鳥座のデネブは、織姫星と彦星を結ぶ夏の大三角のもうひとつの頂点です。',
          ),
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
