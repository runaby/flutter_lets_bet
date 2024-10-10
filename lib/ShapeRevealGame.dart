import 'package:flutter/material.dart';
import 'dart:async';

class EnergyBarGame extends StatefulWidget {
  @override
  _EnergyBarGameState createState() => _EnergyBarGameState();
}

class _EnergyBarGameState extends State<EnergyBarGame> {
  double energyLevel = 0; // 에너지 레벨 (0에서 1 사이)
  bool isRunning = true; // 에너지가 차오르는 중인지 여부
  Timer? timer; // 에너지가 차오르는 타이머
  String message = ''; // 멈춘 위치를 텍스트로 표시

  @override
  void initState() {
    super.initState();
    _startEnergyFill(); // 게임 시작 시 에너지 채우기 시작
  }

  // 에너지를 채우는 함수
  void _startEnergyFill() {
    timer = Timer.periodic(Duration(milliseconds: 20), (timer) {
      setState(() {
        if (isRunning) {
          energyLevel += 0.01; // 에너지가 조금씩 차오름
          if (energyLevel >= 1.0) {
            energyLevel = 0.0; // 꼭대기에 도달하면 다시 0으로 리셋
          }
        }
      });
    });
  }

  // 화면을 터치하면 에너지가 멈추고 위치를 텍스트로 알려줌
  void _onTap() {
    setState(() {
      if (isRunning) {
        isRunning = false; // 에너지 멈추기
        int percentage = (energyLevel * 100).toInt(); // 에너지가 찬 위치를 퍼센트로 계산
        message = 'You stopped at $percentage%';
      } else {
        // 다시 에너지가 차오르도록 리셋
        isRunning = true;
        message = '';
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // 페이지가 닫힐 때 타이머 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Energy Bar Game'),
      ),
      body: GestureDetector(
        onTap: _onTap, // 터치 시 에너지 멈추기
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 더 긴 기둥을 그림
              Container(
                width: 50,
                height: 500, // 기둥의 높이를 더 길게 설정
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 50,
                      height: energyLevel * 500, // 에너지 레벨에 따라 높이 변화
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // 멈춘 위치를 텍스트로 표시
              Text(
                message,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
