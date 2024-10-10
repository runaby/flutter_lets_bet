import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class BrickBreakerGame extends StatefulWidget {
  @override
  _BrickBreakerGameState createState() => _BrickBreakerGameState();
}

class _BrickBreakerGameState extends State<BrickBreakerGame> with SingleTickerProviderStateMixin {
  double ballX = 0.0; // 공의 x 위치
  double ballY = 0.0; // 공의 y 위치
  double ballSpeedX = 0.01; // 공의 x 축 속도
  double ballSpeedY = 0.02; // 공의 y 축 속도
  double paddleX = 0.0; // 패들의 위치
  final double paddleWidth = 0.3; // 패들 너비
  List<Rect> bricks = []; // 블록들

  Timer? gameTimer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeBricks();
  }

  // 블록 초기화
  void _initializeBricks() {
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        bricks.add(Rect.fromLTWH(col * 0.2 - 0.5, row * 0.1 - 0.5, 0.18, 0.08));
      }
    }
  }

  // 게임 시작
  void _startGame() {
    isPlaying = true;
    gameTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      _updateGame();
    });
  }

  // 게임 중단
  void _stopGame() {
    gameTimer?.cancel();
    isPlaying = false;
  }

  // 게임 업데이트 (공과 패들, 벽의 충돌 처리)
  void _updateGame() {
    setState(() {
      // 공 위치 업데이트
      ballX += ballSpeedX;
      ballY += ballSpeedY;

      // 벽에 부딪히면 반사
      if (ballX < -1.0 || ballX > 1.0) {
        ballSpeedX = -ballSpeedX;
      }
      if (ballY < -1.0) {
        ballSpeedY = -ballSpeedY;
      }

      // 패들과 충돌 처리
      if (ballY > 0.9 && ballX > paddleX - paddleWidth / 2 && ballX < paddleX + paddleWidth / 2) {
        ballSpeedY = -ballSpeedY;
      }

      // 블록과 충돌 처리
      bricks.removeWhere((brick) {
        if (ballX > brick.left && ballX < brick.right && ballY > brick.top && ballY < brick.bottom) {
          ballSpeedY = -ballSpeedY;
          return true;
        }
        return false;
      });

      // 게임 오버 처리 (공이 화면 아래로 사라지면)
      if (ballY > 1.0) {
        _stopGame();
      }
    });
  }

  // 패들을 드래그로 움직임
  void _movePaddle(DragUpdateDetails details) {
    setState(() {
      paddleX += details.delta.dx / MediaQuery.of(context).size.width * 2;
      if (paddleX < -1.0) {
        paddleX = -1.0;
      }
      if (paddleX > 1.0) {
        paddleX = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GestureDetector(
          onHorizontalDragUpdate: _movePaddle,
          onTap: () {
            if (!isPlaying) {
              _startGame();
            }
          },
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: Colors.black,
                    child: CustomPaint(
                      painter: BrickBreakerPainter(ballX, ballY, paddleX, paddleWidth, bricks),
                    ),
                  ),
                ),
              ),
              if (!isPlaying)
                Center(
                  child: Text(
                    'Tap to Start',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }
}

class BrickBreakerPainter extends CustomPainter {
  final double ballX;
  final double ballY;
  final double paddleX;
  final double paddleWidth;
  final List<Rect> bricks;

  BrickBreakerPainter(this.ballX, this.ballY, this.paddleX, this.paddleWidth, this.bricks);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white;

    // 공 그리기
    canvas.drawCircle(Offset(ballX * size.width / 2 + size.width / 2, ballY * size.height / 2 + size.height / 2), 10, paint);

    // 패들 그리기
    canvas.drawRect(
      Rect.fromLTWH(
        (paddleX - paddleWidth / 2) * size.width / 2 + size.width / 2,
        size.height - 40,
        paddleWidth * size.width / 2,
        20,
      ),
      paint,
    );

    // 블록 그리기
    for (Rect brick in bricks) {
      canvas.drawRect(
        Rect.fromLTWH(
          brick.left * size.width / 2 + size.width / 2,
          brick.top * size.height / 2 + size.height / 2,
          brick.width * size.width / 2,
          brick.height * size.height / 2,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
