import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DiceGame extends StatefulWidget {
  @override
  _DiceGameState createState() => _DiceGameState();
}

class _DiceGameState extends State<DiceGame> {
  List<int> diceValues = [1, 1]; // 주사위 2개의 초기값
  bool diceRolling = true;
  int totalSum = 0;
  Timer? diceTimer;

  final Map<int, Color> diceColors = {
    1: Colors.red,
    2: Colors.blue,
    3: Colors.green,
    4: Colors.orange,
    5: Colors.purple,
    6: Colors.yellow,
  };

  @override
  void initState() {
    super.initState();
    startRolling(); // 초기 롤링 시작
  }

  // 주사위 롤링 시작
  void startRolling() {
    diceRolling = true;
    diceTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        diceValues[0] = Random().nextInt(6) + 1; // 1부터 6까지 랜덤 값 설정
        diceValues[1] = Random().nextInt(6) + 1;
      });
    });
  }

  // 주사위 멈추기
  void stopRolling() {
    diceRolling = false;
    diceTimer?.cancel();
    setState(() {
      totalSum = diceValues[0] + diceValues[1]; // 두 주사위의 합산 값 계산
    });
  }

  // 화면을 터치하면 주사위 롤링 또는 멈춤 반복
  void toggleRolling() {
    if (diceRolling) {
      stopRolling();
    } else {
      startRolling();
    }
  }

  @override
  void dispose() {
    diceTimer?.cancel();
    super.dispose();
  }

  // 주사위를 실제 주사위처럼 점(dot)으로 표시하는 함수
  Widget buildDice(int value, Color color) {
    List<Widget> dots = [];

    // 주사위 숫자에 따라 점 배치
    switch (value) {
      case 1:
        dots.add(buildDot(Alignment.center)); // 1번 주사위 중앙에 점 하나
        break;
      case 2:
        dots.add(buildDot(Alignment(-0.5, -0.5)));
        dots.add(buildDot(Alignment(0.5, 0.5)));
        break;
      case 3:
        dots.add(buildDot(Alignment(-0.5, -0.5)));
        dots.add(buildDot(Alignment.center));
        dots.add(buildDot(Alignment(0.5, 0.5)));
        break;
      case 4:
        dots.add(buildDot(Alignment(-0.5, -0.5)));
        dots.add(buildDot(Alignment(-0.5, 0.5)));
        dots.add(buildDot(Alignment(0.5, -0.5)));
        dots.add(buildDot(Alignment(0.5, 0.5)));
        break;
      case 5:
        dots.add(buildDot(Alignment(-0.5, -0.5)));
        dots.add(buildDot(Alignment(-0.5, 0.5)));
        dots.add(buildDot(Alignment.center));
        dots.add(buildDot(Alignment(0.5, -0.5)));
        dots.add(buildDot(Alignment(0.5, 0.5)));
        break;
      case 6:
        dots.add(buildDot(Alignment(-0.5, -0.5)));
        dots.add(buildDot(Alignment(-0.5, 0)));
        dots.add(buildDot(Alignment(-0.5, 0.5)));
        dots.add(buildDot(Alignment(0.5, -0.5)));
        dots.add(buildDot(Alignment(0.5, 0)));
        dots.add(buildDot(Alignment(0.5, 0.5)));
        break;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color, // 주사위 색상
        borderRadius: BorderRadius.circular(12), // 둥근 모서리
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(4, 4),
            blurRadius: 10, // 그림자 설정으로 입체감 추가
          ),
          BoxShadow(
            color: Colors.white24,
            offset: Offset(-4, -4),
            blurRadius: 10, // 입체감 효과를 더 강조
          ),
        ],
      ),
      child: Stack(children: dots),
    );
  }

  // 주사위 점(dot) 구성 함수
  Widget buildDot(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 15, // 점 크기를 줄임
        height: 15,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dice Game'),
      ),
      body: GestureDetector(
        onTap: toggleRolling, // 화면 전체 터치 시 주사위 롤링 또는 멈춤
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background_image.png'), // 배경 이미지 적용
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            alignment: Alignment.center, // 스택 중앙 정렬
            children: [
              if (!diceRolling)
                Positioned(
                  top: 100, // 상단에 합계를 고정된 위치에 배치
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20), // 라운드 처리
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(4, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      ' $totalSum ',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 250, // 주사위 영역을 위로 올림
                child: Wrap(
                  spacing: 40, // 주사위 간 간격
                  children: List.generate(2, (index) {
                    int diceValue = diceValues[index];
                    Color diceColor = diceColors.containsKey(diceValue)
                        ? diceColors[diceValue]!
                        : Colors.grey; // 잘못된 값이 들어오면 기본 색상 적용

                    return buildDice(diceValue, diceColor); // 주사위를 점(dot)으로 표시
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
