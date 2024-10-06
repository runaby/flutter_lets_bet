import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // 사운드 라이브러리 추가
import 'game_result.dart';

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
  List<Color> stickColors = [];
  AudioPlayer audioPlayer = AudioPlayer(); // 사운드 플레이어 인스턴스

  // 배경 이미지 경로
  final String gameBackgroundImage = 'assets/stick_game_background.png';
  final String loseBackgroundImage = 'assets/stick_game_lose_background.png';

  @override
  void initState() {
    super.initState();
  }

  // 젖가락 생성 시 사운드 재생
  void playSound() async {
    await audioPlayer.setSource(AssetSource('sounds/stick_sound.mp3')); // 로컬 자산 사운드 설정
    await audioPlayer.resume(); // 사운드 재생
  }

  void startGame() {
    if (numberOfSticks != null && numberOfSticks! > 0) {
      setState(() {
        sticks = List.generate(numberOfSticks!, (index) => index);
        sticksVisible = List.generate(numberOfSticks!, (index) => false); // 젖가락이 처음에 안 보이도록 설정
        losingStick = Random().nextInt(numberOfSticks!); // 꽝 젖가락 설정
        stickColors = List.generate(numberOfSticks!, (index) {
          return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0); // 랜덤 색상
        });

        gameStarted = true;
        gameEnded = false;

        // 젖가락이 하나씩 생성되는 애니메이션과 사운드 재생
        for (int i = 0; i < sticks.length; i++) {
          Future.delayed(Duration(milliseconds: i * 300), () {
            setState(() {
              sticksVisible[i] = true; // 젖가락이 순차적으로 보이도록 설정
            });
            playSound(); // 젖가락이 생성될 때마다 사운드 재생
          });
        }
      });
    }
  }

  void restartGame() {
    if (numberOfSticks != null && numberOfSticks! > 0) {
      setState(() {
        sticks = List.generate(numberOfSticks!, (index) => index);
        sticksVisible = List.generate(numberOfSticks!, (index) => false);
        losingStick = Random().nextInt(numberOfSticks!); // 새로운 꽝 젖가락 설정
        gameStarted = true;
        gameEnded = false;

        stickColors = List.generate(numberOfSticks!, (index) {
          return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0); // 랜덤 색상
        });

        // 젖가락이 하나씩 생성되는 애니메이션과 사운드 재생
        for (int i = 0; i < sticks.length; i++) {
          Future.delayed(Duration(milliseconds: i * 300), () {
            setState(() {
              sticksVisible[i] = true;
            });
            playSound(); // 젖가락이 생성될 때마다 사운드 재생
          });
        }
      });
    }
  }

  void pickStick(int index) {
    if (sticksVisible[index]) { // 젖가락이 보이는 상태에서만 선택 가능하도록 조건 추가
      if (index == losingStick) { // 꽝 젖가락을 선택한 경우
        setState(() {
          gameEnded = true; // 게임 종료
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameResult(
              restartCallback: restartGame, // 다시 시작 콜백
            ),
          ),
        );
      } else {
        setState(() {
          sticks.removeAt(index); // 선택한 젖가락 제거
          sticksVisible.removeAt(index); // 선택된 젖가락의 가시성 제거
          if (sticks.isEmpty) {
            gameEnded = true; // 젖가락을 모두 뽑으면 게임 종료
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameResult(
                  restartCallback: restartGame,
                ),
              ),
            );
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
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: restartGame,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(gameEnded ? loseBackgroundImage : gameBackgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: gameStarted
            ? Center(
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
              )
            : Center(
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
                      onPressed: startGame,
                      child: Text('게임 시작'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
