import 'package:flutter/material.dart';
import 'dart:math';

class ColorTouchGame extends StatefulWidget {
  @override
  _ColorTouchGameState createState() => _ColorTouchGameState();
}

class _ColorTouchGameState extends State<ColorTouchGame> {
  Map<int, Offset> touchPoints = {}; // 터치된 위치를 저장하는 맵 (멀티 터치 지원)
  Map<int, Color> touchColors = {};  // 터치마다 랜덤 색상 리스트

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-Touch the Screen'),
      ),
      body: Listener(
        onPointerDown: (PointerDownEvent event) {
          // 손가락이 닿을 때마다 해당 터치 ID와 위치 저장
          setState(() {
            touchPoints[event.pointer] = event.localPosition;
            touchColors[event.pointer] = _getRandomColor();
          });
        },
        onPointerMove: (PointerMoveEvent event) {
          // 손가락 이동 시마다 위치 업데이트
          setState(() {
            touchPoints[event.pointer] = event.localPosition;
          });
        },
        onPointerUp: (PointerUpEvent event) {
          // 손가락을 떼면 해당 터치 ID 제거
          setState(() {
            touchPoints.remove(event.pointer);
            touchColors.remove(event.pointer);
          });
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: MultiTouchPainter(touchPoints, touchColors),
        ),
      ),
    );
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
}

class MultiTouchPainter extends CustomPainter {
  final Map<int, Offset> points;
  final Map<int, Color> colors;

  MultiTouchPainter(this.points, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    points.forEach((key, point) {
      Paint paint = Paint()
        ..color = colors[key]!.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      // 터치 지점 주변에 원을 그림
      canvas.drawCircle(point, 50, paint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

