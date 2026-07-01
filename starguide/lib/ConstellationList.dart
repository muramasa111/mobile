import 'package:flutter/material.dart';
import 'data/constellation_data.dart';
import 'data/progress_data.dart';
import 'ConstellationDetail.dart';

class ConstellationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('星座一覧')),
      body: ListView.builder(
        itemCount: constellations.length,
        itemBuilder: (context, index) {
          final constellation = constellations[index];
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
                ? Icon(Icons.check_circle, color: Colors.green)
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
        },
      ),
    );
  }
}
