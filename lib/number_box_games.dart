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
  List<Color> openedBoxColors = []; // 각 열린 상자의 색상 고정
  bool gameStarted = false; // 게임 시작 여부
  Random random = Random();

  // 게임 시작 시 설정된 숫자를 상자에 할당
  void _startGame() {
    if (numberOfBoxes != null && numberOfBoxes! > 0) {
      setState(() {
        boxNumbers = List.generate(numberOfBoxes!, (index) => index + 1);
        boxNumbers.shuffle();
        isBoxOpened = List.generate(numberOfBoxes!, (index) => false);
        openedBoxColors = List.generate(numberOfBoxes!, (index) => Colors.blue);
        gameStarted = true;
      });
    }
  }

  // 상자 클릭 시 숫자 보이기
  void _openBox(int index) {
    if (index < isBoxOpened.length && !isBoxOpened[index]) {
      setState(() {
        isBoxOpened[index] = true;
        openedBoxColors[index] = _getRandomColor();
      });
    }
  }

  // 랜덤 색상 생성기
  Color _getRandomColor() {
    return Color((random.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  // 게임을 새로고침 (새로 시작)
  void _restartGame() {
    setState(() {
      gameStarted = false;
      numberOfBoxes = null;
      boxNumbers.clear();
      isBoxOpened.clear();
      openedBoxColors.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Box Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _restartGame, // 새로고침 버튼으로 게임 새로 시작
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/number_box_background_image.png'), // Use your image path here
                fit: BoxFit.cover,
              ),
            ),
          ),
          gameStarted ? _buildGameScreen() : _buildSettingsScreen(),
        ],
      ),
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
                numberOfBoxes = value;
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
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final verticalMargin = 30.0;
    final availableHeight = screenHeight - appBarHeight - (verticalMargin * numberOfBoxes!);
    final boxHeight = (availableHeight / numberOfBoxes!) * 0.9;

    return Column(
      children: List.generate(numberOfBoxes!, (index) {
        return GestureDetector(
          onTap: () => _openBox(index),
          child: Container(
            height: boxHeight,
            margin: EdgeInsets.symmetric(vertical: verticalMargin / 2, horizontal: 10),
            decoration: BoxDecoration(
              color: (isBoxOpened[index] ? openedBoxColors[index] : Colors.blue),
              borderRadius: BorderRadius.circular(20), // Rounded corners updated to 20
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(4, 4),
                  blurRadius: 6,
                ),
              ],
              border: isBoxOpened[index]
                  ? null
                  : Border.all(color: Colors.grey, width: 4),
            ),
            child: Center(
              child: isBoxOpened[index]
                  ? Text(
                      '${boxNumbers[index]}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '상자 ${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      }),
    );
  }
}
