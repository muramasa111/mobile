import 'package:flutter/material.dart';
import 'ThirdPage.dart';

class Secondpage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title : Text("ページ(2)")
      ),
      body : Center(
        child: TextButton(
          child: Text("3ページ目に遷移する"),
          // （1） 3ページ目に進む
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                // （2） 実際に表示するページ(ウィジェット)を指定する
                builder: (context) => Thirdpage(),
              ),
            );
          },
        ),
      )
    );
  }
}