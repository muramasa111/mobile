import 'package:flutter/material.dart';
import 'models/constellation.dart';

class ConstellationDetail extends StatelessWidget {
  final Constellation? constellation;

  const ConstellationDetail({
    super.key,
    this.constellation,
  });

  @override
  Widget build(BuildContext context) {
    final selectedConstellation = constellation;

    return Scaffold(
      appBar: AppBar(title: Text(selectedConstellation?.name ?? "星座詳細")),
      body: selectedConstellation == null
          ? Center(child: Text("星座一覧から星座を選択してください"))
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedConstellation.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(selectedConstellation.description),
                  SizedBox(height: 24),
                  Text("星の数: ${selectedConstellation.stars.length}"),
                  Text("星座線の数: ${selectedConstellation.edges.length}"),
                ],
              ),
            ),
    );
  }
}
