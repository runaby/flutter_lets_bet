import 'package:flutter/material.dart';
import 'package:flutter_lets_bet/dice_game.dart';
import 'stick_game.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stick Drawing Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: GridView.count(
        crossAxisCount: 2, // 2개의 아이콘씩 5줄로 배치
        padding: EdgeInsets.all(20),
        children: List.generate(10, (index) {
          return GestureDetector(
            onTap: () {
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StickGame(), // initialSticks 전달 없이 생성
                  ),
                );
              }else if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiceGame(), // initialSticks 전달 없이 생성
                  ),
                );
              }
            },
            child: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Game ${index + 1}',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
