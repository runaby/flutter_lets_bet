import 'package:flutter/material.dart';
import 'package:flutter_lets_bet/arrow_game.dart';
import 'package:flutter_lets_bet/dice_game.dart';
import 'package:flutter_lets_bet/number_box_games.dart';
import 'package:flutter_lets_bet/number_slot_game.dart';
import 'package:flutter_lets_bet/flip_card_game.dart';
import 'stick_game.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Game Collection',
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
      body: Stack(
        children: [
          // 배경 이미지
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_main.png'), // 배경 이미지 경로
                fit: BoxFit.cover, // 배경을 화면에 맞추어 조정
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 2, // 2개의 아이콘씩 5줄로 배치
            childAspectRatio: 1.2, // 아이템의 가로세로 비율 설정 (가로/세로)
            padding: EdgeInsets.all(30),
            children: List.generate(10, (index) {
              String gameName;
              switch (index) {
                case 0:
                  gameName = '꽝뽑기';
                  break;
                case 1:
                  gameName = '주사위';
                  break;
                case 2:
                  gameName = '화살표';
                  break;
                case 3:
                  gameName = '순서정하기';
                  break;
                case 4:
                  gameName = '6/45로또';
                  break;
                case 5:
                  gameName = '홀/짝';
                  break;
                default:
                  gameName = 'Game ${index + 1}'; // 나머지 임의 이름
              }

              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StickGame(), // 뽑기 게임
                      ),
                    );
                  } else if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiceGame(), // 주사위 게임
                      ),
                    );
                  } else if (index == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArrowGame(), // 주사위 게임
                      ),
                    );
                  } else if (index == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NumberBoxGame(), // 주사위 게임
                      ),
                    );
                  }else if (index == 4) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NumberSlotMachineGame(), // 주사위 게임
                      ),
                    );
                  }else if (index == 5) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlipCardGame(), // 주사위 게임
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
                      gameName,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
