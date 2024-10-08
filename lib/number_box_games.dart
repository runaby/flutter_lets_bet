import 'dart:math';
import 'package:flutter/material.dart';

class NumberBoxGame extends StatefulWidget {
  @override
  _NumberBoxGameState createState() => _NumberBoxGameState();
}

class _NumberBoxGameState extends State<NumberBoxGame> {
  int? numberOfBoxes; // 상자 수 설정
  List<int> boxNumbers = []; // 상자에 들어갈 숫자
  List<bool> isBoxOpened = []; // 상자 열림 상태
  bool gameStarted = false; // 게임 시작 여부
  Random random = Random();

  // 게임 시작 시 설정된 숫자를 상자에 할당
  void _startGame() {
    print('게임 시작');
    if (numberOfBoxes != null && numberOfBoxes! > 0) {
      setState(() {
        // 상자 숫자 리스트 생성 및 섞기
        boxNumbers = List.generate(numberOfBoxes!, (index) => index + 1);
        boxNumbers.shuffle(); // 상자에 들어갈 숫자를 랜덤하게 섞음
        isBoxOpened = List.generate(numberOfBoxes!, (index) => false); // 상자 닫힌 상태로 초기화
        gameStarted = true; // 게임 시작 상태로 변경
        print("boxNumbers length: ${boxNumbers.length}");
        print("isBoxOpened length: ${isBoxOpened.length}");
      });
    }
  }

  // 상자 클릭 시 숫자 보이기
  void _openBox(int index) {
    print("오픈박스");
    print(index);
    print(isBoxOpened.length);
    // 배열 범위 확인 후 안전하게 접근
    if (index < isBoxOpened.length) {
      print("열려라");
      setState(() {
        isBoxOpened[index] = true; // 상자 열림 상태로 변경
      });
    } else {
      print("잘못된 인덱스 접근");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Box Game'),
      ),
      body: gameStarted
          ? _buildGameScreen() // 게임 화면으로 전환
          : _buildSettingsScreen(), // 상자 수 설정 화면
    );
  }

  // 상자 수를 설정하는 화면
  Widget _buildSettingsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('몇 개의 상자를 놓을까요?'),
          DropdownButton<int>(
            value: numberOfBoxes,
            hint: Text('상자 수 선택'),
            items: List.generate(10, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text('${index + 1}개'),
              );
            }),
            onChanged: (value) {
              setState(() {
                numberOfBoxes = value; // 선택된 값으로 설정
                print("선택된 상자 수: $numberOfBoxes");
                _startGame(); // 선택 후 바로 게임 시작
              });
            },
          ),
        ],
      ),
    );
  }

  // 게임 화면 (상자들이 나열된 화면)
  Widget _buildGameScreen() {
    // 화면 높이 계산 (앱바 및 마진 고려)
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final verticalMargin = 20.0; // 상자 간 여백 (상하 마진)
    final availableHeight = screenHeight - appBarHeight - (verticalMargin * numberOfBoxes!);

    final boxHeight = availableHeight / numberOfBoxes!; // 각 상자의 높이를 계산

    return Column(
      children: List.generate(numberOfBoxes!, (index) {
        return GestureDetector(
          onTap: () => _openBox(index), // 상자 클릭 시 열기
          child: Container(
            height: boxHeight, // 각 상자의 높이를 화면 비율에 맞춤
            margin: EdgeInsets.symmetric(vertical: verticalMargin / 2, horizontal: 10),
            decoration: BoxDecoration(
              color: (isBoxOpened.isNotEmpty && index < isBoxOpened.length && isBoxOpened[index])
                  ? Colors.green
                  : Colors.blue, // 배열 범위를 확인하여 색상 설정
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: (isBoxOpened.isNotEmpty && index < isBoxOpened.length && isBoxOpened[index])
                  ? Text(
                      '${boxNumbers[index]}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      '상자 ${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }
}
