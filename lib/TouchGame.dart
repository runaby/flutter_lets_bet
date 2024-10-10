import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class TouchGame extends StatefulWidget {
  @override
  _ColorTouchGameState createState() => _ColorTouchGameState();
}

class _ColorTouchGameState extends State<TouchGame> with SingleTickerProviderStateMixin {
  Map<int, Offset> touchPoints = {}; // 터치된 위치를 저장하는 맵 (멀티 터치 지원)
  Map<int, Color> touchColors = {};  // 터치마다 랜덤 색상 리스트
  Set<Color> usedColors = {}; // 이미 사용된 색상을 저장하는 집합
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
      ),
      body: Stack(
        children: [
          // 터치 감지 및 색상 퍼짐 애니메이션 적용
          Listener(
            onPointerDown: (PointerDownEvent event) {
              // 카운트다운이 시작되지 않았을 때만 시작
              if (!isCountingDown && !gameEnded && touchPoints.isEmpty) {
                _startCountdown(); // 카운팅이 시작되지 않았을 때만 카운팅 시작
              }
              if (!gameEnded) { // 게임 종료 후에는 추가 터치를 막음
                setState(() {
                  touchPoints[event.pointer] = event.localPosition;
                  touchColors[event.pointer] = _getUniqueRandomColor(); // 중복되지 않는 색상 추가
                });
              }
            },
            onPointerMove: (PointerMoveEvent event) {
              if (!gameEnded) {
                setState(() {
                  touchPoints[event.pointer] = event.localPosition;
                });
              }
            },
            onPointerUp: (PointerUpEvent event) {
              if (!gameEnded) { // 게임이 종료되지 않았을 때만 터치된 손가락 제거
                setState(() {
                  touchPoints.remove(event.pointer);
                  usedColors.remove(touchColors[event.pointer]); // 사용된 색상 해제
                  touchColors.remove(event.pointer);
                });
              }
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: MultiTouchPainter(
                  touchPoints, touchColors, selectedColor, selectedPosition, _colorSpreadAnimation.value, gameEnded),
            ),
          ),
          
          // 중앙에 카운트다운 숫자 표시
          if (isCountingDown && !gameEnded && countdownValue > -1)
            Center(
              child: Text(
                '$countdownValue',
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),

          // 게임 종료 후 다시 시작 버튼 표시
          if (gameEnded)
            Center(
              child: ElevatedButton(
                onPressed: _restartGame,
                child: Text('다시 시작', style: TextStyle(fontSize: 24)),
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

      if (countdownValue == -1) {
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
        //touchColors.clear(); //색상 번짐이 시작되면 다른 색상 제거

        // 선택된 색상을 제외한 나머지 색상과 위치 제거
        touchColors.removeWhere((key, value) => value != selectedColor);
        touchPoints.removeWhere((key, value) => value != selectedPosition);
      });

      // 선택된 색상이 부드럽게 퍼지도록 애니메이션 시작
      _animationController.forward(from: 0);
    }

    setState(() {
      //isCountingDown = false;
    });

    // 애니메이션이 완료되면 gameEnded = true로 설정
  _animationController.addStatusListener((status) {
    
    if (status == AnimationStatus.completed) {
      setState(() {
        isCountingDown = false;
        
        gameEnded = true; // 애니메이션이 완료되면 게임 종료
        });
      }
    });
  }
  
  // 게임을 다시 시작하는 함수
  void _restartGame() {
    setState(() {
      touchPoints.clear();
      touchColors.clear();
      usedColors.clear(); // 사용된 색상도 초기화
      selectedColor = null;
      selectedPosition = null;
      isCountingDown = false;
      countdownValue = 5;
      gameEnded = false;
      _animationController.reset(); // 애니메이션 초기화
    });
  }

  // 중복되지 않는 랜덤 색상 생성 함수
  Color _getUniqueRandomColor() {
    Random random = Random();
    Color color;
    do {
      color = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    } while (usedColors.contains(color)); // 이미 사용된 색상인지 확인

    usedColors.add(color); // 사용된 색상 목록에 추가
    return color;
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
  final bool gameEnded;

  MultiTouchPainter(this.points, this.colors, this.selectedColor, this.selectedPosition, this.spreadValue, this.gameEnded);

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedColor != null && selectedPosition != null) {
      // 선택된 손가락의 위치에서 색상이 부드럽게 퍼짐
      Paint paint = Paint()
        ..color = selectedColor!
        ..style = PaintingStyle.fill;

      double spreadRadius = spreadValue * max(size.width, size.height) * 2;
      canvas.drawCircle(selectedPosition!, spreadRadius, paint);
    }

    if (!gameEnded) { // 게임이 종료되면 추가 터치가 없게끔
      // 각 손가락 위치에 원을 그리며, 터치마다 다른 색상 적용
      points.forEach((key, point) {
        Paint paint = Paint()
          ..color = colors[key]!.withOpacity(0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 80, paint); // 원의 크기를 100으로 키움 -> 80으로 조정
      });
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
