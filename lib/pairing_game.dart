import 'dart:math';
import 'package:flutter/material.dart';

class PairingGame extends StatefulWidget {
  @override
  _PairingGameState createState() => _PairingGameState();
}

class _PairingGameState extends State<PairingGame> {
  List<Offset> touchPoints = []; // 터치된 위치 저장
  List<Color> pointColors = []; // 손가락 터치 색상 저장

  // 랜덤한 색상 생성
  Color _getRandomColor() {
    return Color.fromARGB(
      255,
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
    );
  }

  // 터치 감지
  void _handleTouch(TapDownDetails details) {
    print("터치");
    setState(() {
      
      touchPoints.add(details.localPosition); // 터치 위치 저장
      pointColors.add(_getRandomColor()); // 랜덤 색상 추가
    });
  }

  // 손가락 떼기 시 터치 지점 제거
  void _clearTouchPoints() {
    setState(() {
      touchPoints.clear();
      pointColors.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gradient Touch Game'),
      ),
      body: GestureDetector(
        onTapDown: _handleTouch, // 터치 이벤트 감지
        onDoubleTap: _clearTouchPoints, // 더블탭 시 터치 초기화
        child: Stack(
          children: [
            for (int i = 0; i < touchPoints.length; i++)
              Positioned(
                left: touchPoints[i].dx - 50,
                top: touchPoints[i].dy - 50,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        pointColors[i],
                        pointColors[i].withOpacity(0.3), // 그라데이션 효과
                      ],
                      radius: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
