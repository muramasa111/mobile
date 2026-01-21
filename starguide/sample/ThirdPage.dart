import 'package:flutter/material.dart';
import '../lib/HomePage.dart';

class Thirdpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ページ(3)")),
      body: Center(
        child: TextButton(
          child: Text("ホームに戻る"),
          // （2） 前の画面に戻る
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // （2） 実際に表示するページ(ウィジェット)を指定する
                builder: (context) => HomePage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
