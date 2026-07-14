import 'package:flutter/material.dart';

import 'ConstellationDetail.dart';
import 'SpecialDiscoveryDetail.dart';
import 'data/constellation_data.dart';
import 'data/progress_data.dart';

class ConstellationList extends StatelessWidget {
  const ConstellationList({super.key});

  @override
  Widget build(BuildContext context) {
    final summerTriangleDiscovered = isSpecialDiscovered('summer_triangle');

    return Scaffold(
      appBar: AppBar(title: const Text('星座図鑑')),
      body: ListView(
        children: [
          for (final constellation in constellations)
            _ConstellationTile(constellationId: constellation.id),
          const Divider(),
          ListTile(
            title: Text(summerTriangleDiscovered ? '夏の大三角' : '???'),
            subtitle: Text(summerTriangleDiscovered ? '特別発見' : '未発見'),
            trailing: summerTriangleDiscovered
                ? const Icon(Icons.auto_awesome, color: Colors.amber)
                : null,
            onTap: summerTriangleDiscovered
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SpecialDiscoveryDetail(),
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _ConstellationTile extends StatelessWidget {
  final String constellationId;

  const _ConstellationTile({required this.constellationId});

  @override
  Widget build(BuildContext context) {
    final constellation = constellations.firstWhere(
      (item) => item.id == constellationId,
    );
    final discovered = isConstellationDiscovered(constellation.id);
    final completed = isConstellationCompleted(constellation.id);

    return ListTile(
      title: Text(discovered ? constellation.name : '???'),
      subtitle: Text(
        completed
            ? '完成済み'
            : discovered
            ? '名前解禁済み'
            : '未発見',
      ),
      trailing: completed
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: completed
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ConstellationDetail(constellation: constellation),
                ),
              );
            }
          : null,
    );
  }
}
