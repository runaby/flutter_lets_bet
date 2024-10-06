import 'package:flutter/material.dart';

class GameResult extends StatelessWidget {
  final VoidCallback restartCallback;

  // 배경 이미지 경로
  final String loseBackgroundImage = 'assets/stick_game_lose_background.png'; 

  GameResult({required this.restartCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게임 종료'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(loseBackgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '꽝! 다시 시도하세요!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                child: Text('메인으로'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  restartCallback();
                },
                child: Text('다시 시작'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
