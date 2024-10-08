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
  bool isGameActive = true; // 게임이 활성화된 상태

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

  // 슬롯머신 멈춤
  void _stopSpinning() {
    if (timer != null) {
      timer!.cancel(); // 타이머 멈추기
    }
  }

  // 터치 시 숫자 고정 (최대 6개까지)
  void _selectNumber() {
    setState(() {
      if (isGameActive) {
        // 게임이 활성화된 상태에서만 숫자 선택
        if (selectedNumbers.length < 6) {
          selectedNumbers.add(displayedNumber); // 숫자 배열에 추가
        }

        // 숫자가 6개가 되었을 때
        if (selectedNumbers.length == 6) {
          _stopSpinning(); // 랜덤 숫자 멈춤
          List<int> sortedNumbers = List.from(selectedNumbers)..sort();
          sortedNumbersText = '${sortedNumbers.join(', ')}';
          isGameActive = false; // 게임 비활성화
        }
      } else {
        // 게임이 비활성화된 상태에서 터치하면 게임을 초기화
        _resetGame();
      }
    });
  }

  // 게임 초기화
  void _resetGame() {
    setState(() {
      selectedNumbers.clear(); // 선택된 숫자 배열 초기화
      sortedNumbersText = ''; // 정렬된 숫자 텍스트 초기화
      isGameActive = true; // 게임 활성화
      _startSpinning(); // 다시 숫자 돌아가게 시작
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
      body: Stack(
        children: [
          // 배경 이미지 추가
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/lottery_jackpot_background.png'), // 배경 이미지 경로
                fit: BoxFit.cover,
              ),
            ),
          ),
          GestureDetector(
            onTap: _selectNumber, // 화면 터치 시 숫자를 고정
            child: Column(
              children: [
                // 상단 고정된 숫자 공간 (최대 6개) - 반투명
                SizedBox(height: 60),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  height: 100, // 상단 고정 높이
                  color: Colors.white.withOpacity(0.7), // 반투명 효과
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
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                              )
                            : Text(
                                '', // 빈 칸
                                style: TextStyle(fontSize: 24),
                              ),
                      );
                    }),
                  ),
                ),

                // 정렬된 숫자 텍스트 표시 (숫자가 6개일 때만) - 검정색 배경
                if (sortedNumbersText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7), // 검정색 배경
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        sortedNumbersText,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),

                // 고정된 공 위치 (Spacer 대신 SizedBox 사용) - 반투명
                SizedBox(height: 80), // 공과 정렬 텍스트 사이의 고정된 공간
                Container(
                  width: 200,
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _getBallColor(displayedNumber).withOpacity(0.7), // 반투명 효과 추가
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
                      color: Colors.black, // 검정색 숫자
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 50), // 공과 하단 사이 고정된 공간

                // 하단에 터치 안내
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    isGameActive ? '공을 터치하세요!' : '다시 터치하여 재시작하세요!',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

