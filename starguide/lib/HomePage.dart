import 'package:flutter/material.dart';
import 'StarView.dart';
import 'ConstellationList.dart';
import 'ConstellationDetail.dart';
import 'Settings.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ホーム")),
      backgroundColor: Color(0xFF1a237e),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StarView()),
                );
              },
              child: Text("天体観測"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConstellationList()),
                );
              },
              child: Text("星座一覧"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConstellationDetail(),
                  ),
                );
              },
              child: Text("星座詳細"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Settings()),
                );
              },
              child: Text("　設定　"),
            ),
          ],
        ),
      ),
    );
  }
}
