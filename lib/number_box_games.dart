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
  Random random = Random();

  // 게임 시작 시 설정된 숫자를 상자에 할당
  void _startGame() {
    if (numberOfBoxes != null && numberOfBoxes! > 0) {
      setState(() {
        // 상자 숫자 리스트 생성 및 섞기
        boxNumbers = List.generate(numberOfBoxes!, (index) => index + 1);
        boxNumbers.shuffle(); // 상자에 들어갈 숫자를 랜덤하게 섞음
        isBoxOpened = List.generate(numberOfBoxes!, (index) => false); // 상자 닫힌 상태로 초기화
      });
    }
  }

  // 상자 클릭 시 숫자 보이기
  void _openBox(int index) {
    if (index < isBoxOpened.length) {
      setState(() {
        isBoxOpened[index] = true; // 상자 열림 상태로 변경
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Box Game'),
      ),
      body: numberOfBoxes == null || numberOfBoxes == 0
          ? _buildSettingsScreen() // 상자 수 설정 화면
          : _buildGameScreen(), // 게임 화면
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
              });
            },
          ),
          ElevatedButton(
            onPressed: numberOfBoxes == null ? null : _startGame, // 상자 수가 선택된 후에만 게임 시작 가능
            child: Text('게임 시작'),
          ),
        ],
      ),
    );
  }

  // 게임 화면 (상자들이 나열된 화면)
  Widget _buildGameScreen() {
    return GridView.count(
      crossAxisCount: 3, // 한 줄에 3개의 상자 표시
      padding: EdgeInsets.all(20),
      children: List.generate(numberOfBoxes!, (index) {
        return GestureDetector(
          onTap: () => _openBox(index), // 상자 클릭 시 열기
          child: Container(
            margin: EdgeInsets.all(10),
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
