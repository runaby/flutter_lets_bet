import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // 사운드 라이브러리 추가

class StickGame extends StatefulWidget {
  @override
  _StickGameState createState() => _StickGameState();
}

class _StickGameState extends State<StickGame> with TickerProviderStateMixin {
  int? numberOfSticks;
  List<int> sticks = [];
  List<bool> sticksVisible = [];
  bool gameStarted = false;
  int losingStick = -1;
  bool gameEnded = false;
  bool showLoserText = false;
  List<Color> stickColors = [];
  AudioPlayer audioPlayer = AudioPlayer(); // 사운드 플레이어 인스턴스
  AudioPlayer bangPlayer = AudioPlayer(); // 꽝 사운드 플레이어 추가

  // 배경 이미지 경로
  final String gameBackgroundImage = 'assets/stick_game_background.png';

  @override
  void initState() {
    super.initState();
  }

  // 젖가락 생성 시 사운드 재생
  void playSound() async {
    await audioPlayer.setSource(AssetSource('sounds/stick_sound.mp3')); // 로컬 자산 사운드 설정
    await audioPlayer.resume(); // 사운드 재생
  }

  // 꽝 사운드 재생
  void playBangSound() async {
    await bangPlayer.setSource(AssetSource('sounds/bang_sound.mp3')); // 꽝 사운드 설정
    await bangPlayer.resume(); // 꽝 사운드 재생
  }

  // 게임 시작 시 젖가락 초기화 및 게임 상태 설정
  void startGame() {
    if (numberOfSticks != null && numberOfSticks! > 0) {
      setState(() {
        sticks = List.generate(numberOfSticks!, (index) => index);
        sticksVisible = List.generate(numberOfSticks!, (index) => true); // 젖가락이 바로 보이도록 설정
        losingStick = Random().nextInt(numberOfSticks!); // 꽝 젖가락 설정
        stickColors = List.generate(numberOfSticks!, (index) {
          return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0); // 랜덤 색상
        });

        gameStarted = true; // 게임이 시작된 상태
        gameEnded = false; // 게임 종료 상태 초기화
        showLoserText = false; // 꽝 텍스트 초기화
        
        // 사운드 한 번만 재생
        playSound(); // 젖가락이 한 번에 생성될 때 사운드 재생
      });
    }
  }

  // 게임 재시작 시 젖가락 선택 화면으로 돌아가도록 설정
  void goToSelectionScreen() {
    setState(() {
      gameStarted = false; // 게임을 멈추고 젖가락 선택 화면으로 돌아감
    });
  }

  void pickStick(int index) {
    if (sticksVisible[index]) { // 젖가락이 보이는 상태에서만 선택 가능하도록 조건 추가
      if (index == losingStick) { // 꽝 젖가락을 선택한 경우
        setState(() {
          gameEnded = true;
          showLoserText = true; // 꽝 텍스트 표시
          playBangSound(); // 꽝 사운드 재생
        });
      } else {
        setState(() {
          sticksVisible[index] = false; // 선택된 젖가락의 가시성 제거
          if (sticksVisible.every((visible) => !visible)) {
            gameEnded = true; // 모든 젖가락이 선택되면 게임 종료
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stick Drawing Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings), // 설정 아이콘
            onPressed: goToSelectionScreen, // 젖가락 선택 화면으로 돌아가기
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: startGame, // 게임을 다시 시작하는 버튼
          ),
        ],
      ),
      body: gameStarted
          ? GestureDetector(
              onTap: () {
                if (gameEnded && showLoserText) {
                  startGame(); // 터치하면 게임 재시작
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(gameBackgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    if (gameStarted && !gameEnded) // 게임 진행 중일 때 젖가락 표시
                      Center(
                        child: Wrap(
                          children: List.generate(sticks.length, (index) {
                            return AnimatedOpacity(
                              opacity: sticksVisible[index] ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 500),
                              child: GestureDetector(
                                onTap: () => pickStick(index), // 젖가락이 보일 때만 선택 가능
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  width: 50,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [stickColors[index], stickColors[index].withOpacity(0.7)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(10), // 둥근 모서리
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 4),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Stick ${index + 1}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    if (showLoserText) // 꽝 텍스트를 중앙에 크게 표시
                      Center(
                        child: Text(
                          '당첨!',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : Container( // 젖가락 선택 화면에도 배경 이미지 추가
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(gameBackgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('몇 개의 젓가락을 선택할까요?'),
                    DropdownButton<int>(
                      value: numberOfSticks,
                      hint: Text('젓가락 수 선택'),
                      items: List.generate(5, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}개'),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          numberOfSticks = value;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: startGame, // 게임을 시작하는 버튼
                      child: Text('게임 시작'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
