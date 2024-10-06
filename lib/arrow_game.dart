import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ArrowGame extends StatefulWidget {
  @override
  _ArrowGameState createState() => _ArrowGameState();
}

class _ArrowGameState extends State<ArrowGame> with SingleTickerProviderStateMixin {
  double _angle = 0.0; // 화살표의 현재 각도
  bool _isSpinning = false; // 현재 회전 중인지 여부
  Timer? _timer;
  double _spinSpeed = 1.0; // 회전 속도 (원래 속도로 되돌림)
  double _remainingAngle = 0.0; // 남은 회전 각도
  final Random _random = Random();
  int _spinCount = 0; // 현재까지 회전한 횟수
  final int _maxSpins = 10; // 최대 회전 횟수
  int _colorIndex = 0; // 무지개 색상 인덱스
  final List<Color> _rainbowColors = [ // 무지개 색상 배열
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 해제
    super.dispose();
  }

  // 무지개 색상 순서대로 반환
  Color _getNextRainbowColor() {
    _colorIndex = (_colorIndex + 1) % _rainbowColors.length; // 무지개 색상 순환
    return _rainbowColors[_colorIndex];
  }

  // 터치 시 빠르게 10~15바퀴 돌다가 천천히 멈추는 함수
  void _onTap() {
    if (_spinCount < _maxSpins) {
      if (!_isSpinning) {
        setState(() {
          _spinSpeed = 1.0; // 빠르게 회전 시작
          _isSpinning = true;
          _spinCount += 1; // 회전 횟수 증가
        });
        int randomRounds = 10 + _random.nextInt(6); // 10 ~ 15바퀴 랜덤
        _remainingAngle = 2 * pi * randomRounds + _random.nextDouble() * 2 * pi; // 회전 각도 계산
        _startSpinning();
      } else {
        // 이미 회전 중일 때, 더 돌게 각도를 추가
        int extraRounds = 5 + _random.nextInt(6); // 추가로 5 ~ 10바퀴 더 돌기
        _remainingAngle += 2 * pi * extraRounds + _random.nextDouble() * 2 * pi;
        _spinCount += 1; // 회전 횟수 증가
      }
    }
  }

  // 빠르게 회전하다가 천천히 멈추기
  void _startSpinning() {
    double slowDownFactor = 0.97 + _random.nextDouble() * 0.02; // 속도를 천천히 줄이는 비율에 변칙성 추가

    _timer = Timer.periodic(Duration(milliseconds: 16), (timer) { // 16ms로 빠르게 회전
      setState(() {
        _angle += _spinSpeed;
        _remainingAngle -= _spinSpeed;
        _arrowColor = _getNextRainbowColor(); // 무지개 색상으로 변경 (느리게)

        if (_remainingAngle <= 0) {
          _spinSpeed *= slowDownFactor; // 천천히 멈추게 하기

          if (_spinSpeed < 0.01) {
            _spinSpeed = 0.0;
            _isSpinning = false;
            _spinCount = 0; // 회전 횟수 초기화
            timer.cancel(); // 회전 멈추기
          }
        }
      });
    });
  }

  Color _arrowColor = Colors.red; // 초기 화살표 색상

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arrow Game'),
      ),
      body: GestureDetector(
        onTap: _onTap, // 터치 시 동작
        child: Container(
          width: double.infinity, // 화면 전체 너비
          height: double.infinity, // 화면 전체 높이
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/arrow_game_background.png'), // 배경 이미지 경로
              fit: BoxFit.cover, // 배경 이미지를 화면에 맞춤
            ),
          ),
          child: Center(
            child: Transform.rotate(
              angle: _angle, // 화살표 각도
              child: Container(
                width: 300, // 화살표 크기 확대
                height: 300, // 화살표 크기 확대
                child: CustomPaint(
                  painter: ArrowPainter(_arrowColor), // 무지개 색상이 적용됨
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 화살표를 그리는 CustomPainter 클래스 (무지개 색상 적용)
class ArrowPainter extends CustomPainter {
  final Color arrowColor;

  ArrowPainter(this.arrowColor); // 화살표 색상을 생성자에서 받음

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = arrowColor // 화살표에 무지개 색상 적용
      ..style = PaintingStyle.fill;

    var shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5) // 그림자 효과
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(size.width * 0.5, 0); // 화살표의 머리
    path.lineTo(size.width * 0.3, size.height * 0.7); // 화살표 왼쪽
    path.lineTo(size.width * 0.5, size.height * 0.5); // 화살표 중앙
    path.lineTo(size.width * 0.7, size.height * 0.7); // 화살표 오른쪽
    path.close();

    // 그림자 추가
    canvas.drawPath(path.shift(Offset(5, 5)), shadowPaint);

    // 화살표 그리기
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 매번 새로 그리기
  }
}
