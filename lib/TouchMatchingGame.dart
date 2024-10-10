import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class TouchMatchingGame extends StatefulWidget {
  @override
  _TouchMatchingGameState createState() => _TouchMatchingGameState();
}

class _TouchMatchingGameState extends State<TouchMatchingGame> {
  Map<int, Offset> touchPoints = {}; // 터치된 위치를 저장하는 맵 (멀티 터치 지원)
  Map<int, Color> touchColors = {};  // 터치마다 랜덤 색상 리스트
  List<List<Offset>> pairs = []; // 짝을 저장할 리스트
  Set<Color> usedColors = {}; // 이미 사용된 색상을 저장하는 집합
  bool isCountingDown = false; // 카운트다운 상태
  bool gameEnded = false; // 게임 종료 여부
  Timer? countdownTimer; // 5초 카운트다운 타이머
  int countdownValue = 5; // 카운트다운 값
  final double circleRadius = 40; // 원의 반지름
  Random random = Random(); // 랜덤 매칭을 위한 Random 객체

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Touch Pairing Game'),
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
                touchPoints, touchColors, pairs, gameEnded, circleRadius),
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
        _pairTouchPoints(); // 카운트다운이 끝나면 짝을 맺어줌
      }
    });
  }

  // 터치 포인트를 짝으로 맺어주는 함수 (랜덤 매칭)
  void _pairTouchPoints() {
    List<Offset> pointsList = touchPoints.values.toList();

    // 포인트 리스트를 무작위로 섞음
    pointsList.shuffle(random);

    setState(() {
      pairs.clear(); // 기존 짝을 초기화
      for (int i = 0; i < pointsList.length - 1; i += 2) {
        pairs.add([pointsList[i], pointsList[i + 1]]); // 두 개씩 짝을 맺어 추가
      }
      
      gameEnded = true; // 게임 종료
    });
  }

  // 게임을 다시 시작하는 함수
  void _restartGame() {
    setState(() {
      touchPoints.clear();
      touchColors.clear();
      usedColors.clear(); // 사용된 색상도 초기화
      pairs.clear(); // 짝 목록 초기화
      isCountingDown = false;
      countdownValue = 5;
      gameEnded = false;
    });
  }

  // 중복되지 않는 랜덤 색상 생성 함수
  Color _getUniqueRandomColor() {
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
    super.dispose();
  }
}

// 터치된 위치 및 짝을 그려줄 커스텀 페인터
class MultiTouchPainter extends CustomPainter {
  final Map<int, Offset> points;
  final Map<int, Color> colors;
  final List<List<Offset>> pairs;
  final bool gameEnded;
  final double circleRadius;

  MultiTouchPainter(this.points, this.colors, this.pairs, this.gameEnded, this.circleRadius);

  @override
  void paint(Canvas canvas, Size size) {
    // 게임이 끝나기 전에도 터치된 손가락마다 원을 그리며, 터치마다 다른 색상 적용
    points.forEach((key, point) {
      Paint paint = Paint()
        ..color = colors[key]!.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, circleRadius, paint); // 원의 크기를 작게 조정
    });

    // 게임이 종료되면 짝을 맺어주는 선을 그리기 (그라데이션 처리)
    for (var pair in pairs) {
      if (pair.length == 2) {
        Color color1 = colors.values.elementAt(points.values.toList().indexOf(pair[0]));
        Color color2 = colors.values.elementAt(points.values.toList().indexOf(pair[1]));

        // 각 원의 중심에서 방향을 계산하고 원의 반지름만큼 이동하여 선을 그림
        Offset direction1 = (pair[1] - pair[0]).normalize();
        Offset direction2 = (pair[0] - pair[1]).normalize();

        Offset start = pair[0] + direction1 * circleRadius;
        Offset end = pair[1] + direction2 * circleRadius;

        // 선을 그릴 때 일관된 방식으로 그라데이션을 적용
        Paint gradientPaint = Paint()
          ..shader = LinearGradient(
            colors: [color1, color2], // 시작점과 끝점을 고정
          ).createShader(Rect.fromPoints(start, end))
          ..strokeWidth = 6.0; // 선의 굵기 설정

        canvas.drawLine(start, end, gradientPaint); // 짝을 맺은 포인트들 사이에 그라데이션 선 그리기
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Offset 방향을 구하는 확장 메서드
extension Normalize on Offset {
  Offset normalize() {
    double length = this.distance;
    return length == 0 ? this : this / length;
  }
}
