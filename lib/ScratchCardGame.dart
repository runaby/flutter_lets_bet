import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class ColorTouchGame extends StatefulWidget {
  @override
  _ColorTouchGameState createState() => _ColorTouchGameState();
}

class _ColorTouchGameState extends State<ColorTouchGame> with SingleTickerProviderStateMixin {
  Map<int, Offset> touchPoints = {}; // 터치된 위치를 저장하는 맵 (멀티 터치 지원)
  Map<int, Color> touchColors = {};  // 터치마다 랜덤 색상 리스트
  bool isCountingDown = false; // 카운트다운 상태
  bool gameEnded = false; // 게임 종료 여부
  Timer? countdownTimer; // 5초 카운트다운 타이머
  int countdownValue = 5; // 카운트다운 값
  Color? selectedColor; // 선택된 색상 (화면을 덮을 색상)
  Offset? selectedPosition; // 선택된 손가락의 위치
  late AnimationController _animationController;
  late Animation<double> _colorSpreadAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _colorSpreadAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        setState(() {}); // 애니메이션 진행 시 화면 갱신
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-Touch the Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _restartGame, // 다시 시작 버튼
          ),
        ],
      ),
      body: Stack(
        children: [
          // 터치 감지 및 색상 퍼짐 애니메이션 적용
          if (!gameEnded) // 게임이 종료되지 않았을 때만 터치 감지
            Listener(
              onPointerDown: (PointerDownEvent event) {
                if (touchPoints.isEmpty) {
                  _startCountdown();
                }
                if (!isCountingDown || isCountingDown) {
                  setState(() {
                    touchPoints[event.pointer] = event.localPosition;
                    touchColors[event.pointer] = _getRandomColor();
                  });
                }
              },
              onPointerMove: (PointerMoveEvent event) {
                setState(() {
                  touchPoints[event.pointer] = event.localPosition;
                });
              },
              onPointerUp: (PointerUpEvent event) {
                setState(() {
                  touchPoints.remove(event.pointer);
                  touchColors.remove(event.pointer);
                });
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: MultiTouchPainter(
                    touchPoints, touchColors, selectedColor, selectedPosition, _colorSpreadAnimation.value),
              ),
            ),
          // 중앙에 카운트다운 숫자 표시
          if (isCountingDown && !gameEnded)
            Center(
              child: Text(
                '$countdownValue',
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  // 5초 카운트다운 시작 함수
  void _startCountdown() {
    setState(() {
      isCountingDown = true;
      countdownValue = 5;
    });

    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        countdownValue--;
      });

      if (countdownValue == 0) {
        timer.cancel();
        _selectRandomFinger();
      }
    });
  }

  // 5초 후 무작위 손가락 선택 함수
  void _selectRandomFinger() {
    if (touchColors.isNotEmpty) {
      setState(() {
        int randomIndex = Random().nextInt(touchColors.length);
        selectedColor = touchColors.values.elementAt(randomIndex); // 랜덤 색상 선택
        selectedPosition = touchPoints.values.elementAt(randomIndex); // 선택된 손가락의 위치
        touchPoints.clear(); // 다른 손가락 위치 제거
        touchColors.clear(); // 다른 색상 제거
        gameEnded = true; // 게임 종료
      });

      // 선택된 색상이 부드럽게 퍼지도록 애니메이션 시작
      _animationController.forward(from: 0);
    }

    setState(() {
      isCountingDown = false;
    });
  }

  // 게임을 다시 시작하는 함수
  void _restartGame() {
    setState(() {
      touchPoints.clear();
      touchColors.clear();
      selectedColor = null;
      selectedPosition = null;
      isCountingDown = false;
      countdownValue = 5;
      gameEnded = false;
      _animationController.reset(); // 애니메이션 초기화
    });
  }

  // 랜덤 색상 생성 함수
  Color _getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel(); // 타이머 해제
    _animationController.dispose(); // 애니메이션 컨트롤러 해제
    super.dispose();
  }
}

// 터치된 위치 및 선택된 색상에 대한 커스텀 페인터
class MultiTouchPainter extends CustomPainter {
  final Map<int, Offset> points;
  final Map<int, Color> colors;
  final Color? selectedColor;
  final Offset? selectedPosition;
  final double spreadValue;

  MultiTouchPainter(this.points, this.colors, this.selectedColor, this.selectedPosition, this.spreadValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedColor != null && selectedPosition != null) {
      // 선택된 손가락의 위치에서 색상이 부드럽게 퍼짐
      Paint paint = Paint()
        ..color = selectedColor!.withOpacity(1 - spreadValue)
        ..style = PaintingStyle.fill;

      double spreadRadius = spreadValue * max(size.width, size.height) * 2;
      canvas.drawCircle(selectedPosition!, spreadRadius, paint);
    } else {
      // 각 손가락 위치에 원을 그리며, 터치마다 다른 색상 적용
      points.forEach((key, point) {
        Paint paint = Paint()
          ..color = colors[key]!.withOpacity(0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 50, paint);
      });
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
