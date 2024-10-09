import 'package:flutter/material.dart';
import 'dart:math';

class FlipCardGame extends StatefulWidget {
  @override
  _FlipCardGameState createState() => _FlipCardGameState();
}

class _FlipCardGameState extends State<FlipCardGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFront = true; // 현재 보이는 면이 앞면인지 여부
  bool isChk = true; // 회전 중간 지점에서 상태 전환 여부 확인

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // 애니메이션 반복

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        if (_animation.value >= 0.5 && isChk) {
          setState(() {
            isChk = false;
            isFront = !isFront; // 앞면과 뒷면 전환
          });
        }

        if (_animation.value < 0.5) {
          isChk = true;
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flip Card Game'),
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            double angle = pi * _animation.value; // 0 ~ pi 값으로 회전

            // 카드가 180도 이상 회전했을 때 텍스트 반전시키기
            bool isFlipped = angle > pi / 2 && angle < (3 * pi / 2);

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // 원근감 효과 추가
                ..rotateY(angle), // 카드 회전
              child: _buildCard(isFront ? 'ODD' : 'EVEN', isFront ? Colors.blue : Colors.red, isFlipped),
            );
          },
        ),
      ),
    );
  }

  // 카드를 만드는 함수
  Widget _buildCard(String text, Color color, bool isFlipped) {
    Matrix4 transform = Matrix4.identity();
    if (isFlipped) {
      transform = Matrix4.rotationY(pi); // 글자가 반전되었을 때 반전 적용
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 200,
        height: 300,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Transform(
            alignment: Alignment.center,
            transform: transform, // 텍스트의 Transform 적용
            child: Text(
              text,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
