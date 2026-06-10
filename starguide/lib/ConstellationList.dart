import 'package:flutter/material.dart';
import 'data/constellation_data.dart';

class ConstellationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("星座一覧")),
      body: ListView.builder(
        itemCount: constellations.length,
        itemBuilder: (context, index) {
          final constellation = constellations[index];

          return ListTile(
            title: Text(constellation.name),
            subtitle: Text(constellation.description),
          );
        },
      ),
    );
  }
}
