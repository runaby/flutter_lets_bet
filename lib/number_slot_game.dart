import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class NumberSlotMachineGame extends StatefulWidget {
  @override
  _NumberSlotMachineGameState createState() => _NumberSlotMachineGameState();
}

class _NumberSlotMachineGameState extends State<NumberSlotMachineGame> {
  int displayedNumber = 1; // 현재 화면에 표시되는 숫자
  List<int> selectedNumbers = []; // 터치로 고정된 숫자 배열 (최대 6개)
  Timer? timer; // 숫자가 돌아가는 타이머
  Random random = Random();
  String sortedNumbersText = ''; // 정렬된 숫자 텍스트

  @override
  void initState() {
    super.initState();
    _startSpinning(); // 게임 시작 시 바로 숫자가 랜덤으로 돌아감
  }

  // 슬롯머신 시작 (숫자가 돌아가기 시작)
  void _startSpinning() {
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        displayedNumber = random.nextInt(45) + 1; // 1부터 45 사이의 숫자를 표시
      });
    });
  }

  // 터치 시 숫자 고정 (최대 6개까지)
  void _selectNumber() {
    setState(() {
      if (selectedNumbers.length < 6) {
        selectedNumbers.add(displayedNumber); // 숫자 배열에 추가
      } else {
        selectedNumbers.clear(); // 숫자가 6개가 넘으면 배열 초기화
        selectedNumbers.add(displayedNumber); // 새 숫자 추가
        sortedNumbersText = ''; // 텍스트 초기화
      }

      // 숫자가 6개가 되었을 때 정렬된 상태로 텍스트에 표시
      if (selectedNumbers.length == 6) {
        List<int> sortedNumbers = List.from(selectedNumbers)..sort();
        sortedNumbersText = '${sortedNumbers.join(', ')}';
      }
    });
  }

  // 숫자에 맞는 색상을 반환하는 함수
  Color _getBallColor(int number) {
    if (number >= 1 && number <= 10) {
      return Colors.yellow; // 1번부터 10번까지는 노란색
    } else if (number >= 11 && number <= 20) {
      return Colors.blue; // 11번부터 20번까지는 파란색
    } else if (number >= 21 && number <= 30) {
      return Colors.red; // 21번부터 30번까지는 빨간색
    } else if (number >= 31 && number <= 40) {
      return Colors.grey; // 31번부터 40번까지는 회색
    } else {
      return Colors.green; // 41번부터 45번까지는 초록색
    }
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel(); // 페이지가 닫힐 때 타이머 종료
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // 화면 가로 크기
    final numberWidth = screenWidth / 6 - 10; // 숫자 하나의 가로 크기

    return Scaffold(
      appBar: AppBar(
        title: Text('Number Slot Machine'),
      ),
      body: GestureDetector(
        onTap: _selectNumber, // 화면 터치 시 숫자를 고정
        child: Column(
          children: [
            // 상단 고정된 숫자 공간 (최대 6개) - 아래로 배치
            SizedBox(height: 60),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              height: 100, // 상단 고정 높이
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 숫자가 화면 가로에 맞게 배치
                children: List.generate(6, (index) {
                  return Container(
                    width: numberWidth, // 숫자 하나의 가로 크기
                    height: 60, // 숫자 하나의 세로 크기
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: index < selectedNumbers.length ? _getBallColor(selectedNumbers[index]) : Colors.grey[300],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(4, 4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: index < selectedNumbers.length
                        ? Text(
                            '${selectedNumbers[index]}',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          )
                        : Text(
                            '', // 빈 칸
                            style: TextStyle(fontSize: 24),
                          ),
                  );
                }),
              ),
            ),

            // 정렬된 숫자 텍스트 표시 (숫자가 6개일 때만)
            if (sortedNumbersText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  sortedNumbersText,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),

            Spacer(), // 빈 공간을 추가해 아래로 내림

            // 숫자 슬롯머신 (동그라미 모양) - 입체감 추가
            Container(
              width: 200,
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _getBallColor(displayedNumber), // 번호에 맞는 색상 적용
                shape: BoxShape.circle, // 동그라미 모양
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(6, 6),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    offset: Offset(-6, -6),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                '$displayedNumber',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Spacer(), // 빈 공간을 추가해 아래로 내림

            // 하단에 터치 안내
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                '공을 터치하세요!',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}