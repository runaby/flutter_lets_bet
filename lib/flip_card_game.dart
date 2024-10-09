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
  bool isChk = true; // 현재 보이는 면이 앞면인지 여부

  @override
  void initState() {
    super.initState();
    // AnimationController 생성 (애니메이션 지속 시간: 2초)
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // 애니메이션 반복

    // 애니메이션 리스너를 추가하여 회전 각도에 따라 면을 변경
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        // 180도(애니메이션 값이 정확히 0.5일 때)에서만 텍스트 변경
               
        if (_animation.value >= 0.5 && isChk) {
          print("11111111111111111111111111111111111111111111111111111111111111");
          print(_animation.value);
          print(isFront);
          setState(() {
            isChk = false;
            isFront = !isFront; // 뒷면으로 전환
          });
        } 

        if(_animation.value < 0.5){
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
            // 3D 회전 변환을 적용하기 위해 Matrix4 사용
            double angle = pi * _animation.value; // 0 ~ pi 값으로 회전
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // 3D 효과를 위한 원근감 설정
                ..rotateY(angle), // Y축 기준으로 좌우 회전 (0 ~ pi 사이 값으로 회전)
              child: isFront
                  ? _buildCard('ODD', Colors.blue) // 앞면 (홀)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi), // 뒷면을 뒤집어서 보이도록 설정
                      child: _buildCard('EVEN', Colors.red), // 뒷면 (짝)
                    ),
            );
          },
        ),
      ),
    );
  }

  // 카드를 만드는 함수, text와 배경색을 받아서 카드 생성
  Widget _buildCard(String text, Color color) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 200,
        height: 300,
        decoration: BoxDecoration(
          color: color, // 배경 색상
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

