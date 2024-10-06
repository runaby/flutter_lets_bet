import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ArrowGame extends StatefulWidget {
  @override
  _ArrowGameState createState() => _ArrowGameState();
}

class _ArrowGameState extends State<ArrowGame> with SingleTickerProviderStateMixin {
  double _angle = 0.0; // 화살표의 현재 각도
  bool _isSpinning = true; // 처음에는 회전 중인 상태
  bool _isSlowingDown = false; // 속도가 줄어드는지 여부
  Timer? _timer;
  double _spinSpeed = 0.05; // 기본 회전 속도

  @override
  void initState() {
    super.initState();
    _startSpinning(); // 게임 시작 시 화살표 회전 시작
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 해제
    super.dispose();
  }

  // 화살표 회전을 시작하는 함수
  void _startSpinning() {
    _timer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (_isSpinning || _isSlowingDown) {
        setState(() {
          _angle += _spinSpeed; // 화살표가 현재 속도로 회전
        });
      }
    });
  }

  // 터치 시 빠르게 돌다가 천천히 멈추는 함수
  void _stopSpinning() {
    _isSpinning = false;
    _isSlowingDown = true;
    double slowDownFactor = 0.98; // 속도를 천천히 줄이는 정도
    double minSpeed = 0.001; // 멈출 때 최소 속도

    _timer?.cancel(); // 기존 타이머 중지
    _timer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        _angle += _spinSpeed; // 계속 회전
        _spinSpeed *= slowDownFactor; // 회전 속도를 점점 줄임

        if (_spinSpeed < minSpeed) {
          _spinSpeed = 0.0; // 멈추기
          _isSlowingDown = false; // 회전 종료
          timer.cancel(); // 타이머 중지
        }
      });
    });
  }

  // 터치 시 빠르게 돌기 시작하는 함수
  void _onTap() {
    if (!_isSpinning && !_isSlowingDown) {
      _spinSpeed = 0.5; // 빠르게 돌기 시작
      _isSpinning = true; // 다시 회전 상태로 설정
      _startSpinning(); // 회전 시작
      Future.delayed(Duration(milliseconds: 500), () {
        _stopSpinning(); // 빠르게 돌다가 천천히 멈추기
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arrow Game'),
      ),
      body: GestureDetector(
        onTap: _onTap, // 터치 시 동작
        child: Center(
          child: Transform.rotate(
            angle: _angle, // 화살표의 현재 각도에 따라 회전
            child: Container(
              width: 200, // 화살표 크기를 200으로 확대
              height: 200, // 화살표 크기를 200으로 확대
              child: CustomPaint(
                painter: ArrowPainter(), // 화살표 그리기
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 화살표를 그리는 CustomPainter 클래스
class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(size.width * 0.5, 0); // 화살표의 머리
    path.lineTo(size.width * 0.3, size.height * 0.7); // 화살표의 왼쪽
    path.lineTo(size.width * 0.5, size.height * 0.5); // 화살표의 중앙
    path.lineTo(size.width * 0.7, size.height * 0.7); // 화살표의 오른쪽
    path.close();

    canvas.drawPath(path, paint); // 화살표 그리기
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 매번 새로 그리기
  }
}
