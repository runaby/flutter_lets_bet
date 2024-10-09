import 'package:flutter/material.dart';
import 'dart:math';

class FlipCardGame extends StatefulWidget {
  @override
  _FlipCardGameState createState() => _FlipCardGameState();
}

class _FlipCardGameState extends State<FlipCardGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // AnimationController 생성 (애니메이션 지속 시간: 2초)
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // 반복 애니메이션

    // Tween을 사용하여 0부터 1까지의 애니메이션 값 생성
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
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
            // 3D 회전 변환을 적용하기 위해 Matrix4 사용
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // 3D 효과를 위한 원근감 설정
                ..rotateY(pi * _animation.value), // Y축 기준으로 좌우 회전 (0 ~ pi 사이 값으로 회전)
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: 200,
                  height: 300,
                  child: Center(
                    child: Text(
                      'Card',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
