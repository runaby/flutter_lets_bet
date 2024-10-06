import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class GameResult extends StatefulWidget {
  final VoidCallback restartCallback;

  // 배경 이미지 경로
  final String loseBackgroundImage = 'assets/stick_game_lose_background.png';

  GameResult({required this.restartCallback});

  @override
  _GameResultState createState() => _GameResultState();
}

class _GameResultState extends State<GameResult> with SingleTickerProviderStateMixin {
  double _scale = 1.2; // 배경 이미지 확대 비율
  late AnimationController _controller; // 애니메이션 컨트롤러
  late Animation<double> _animation; // 애니메이션 설정

  @override
  void initState() {
    super.initState();

    // AnimationController 설정 (애니메이션 재생 시간 1초)
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    // Tween을 이용해 0부터 30픽셀까지 오른쪽으로 이동하는 애니메이션 생성
    _animation = Tween<double>(begin: 0, end: 30).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    // 애니메이션을 시작하도록 딜레이 설정
    Future.delayed(Duration(milliseconds: 300), () {
      _controller.forward(); // 애니메이션 시작
    });
  }

  // 다시 시작 버튼을 누를 때 애니메이션을 재실행하도록 설정
  void _restartAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // AnimationController 메모리 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게임 종료'),
      ),
      body: GestureDetector(
        onTap: () {
          _restartAnimation(); // 화면 터치 시 애니메이션 재실행
        },
        child: Stack(
          children: [
            // 애니메이션이 적용된 배경 이미지
            Transform.translate(
              offset: Offset(_animation.value, 0), // X축으로 이동
              child: Transform.scale(
                scale: _scale, // 배경 이미지를 확대
                child: Container(
                  width: MediaQuery.of(context).size.width, // 화면 너비에 맞춤
                  height: MediaQuery.of(context).size.height, // 화면 높이에 맞춤
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(widget.loseBackgroundImage),
                      fit: BoxFit.cover, // 이미지가 화면을 덮도록
                    ),
                  ),
                ),
              ),
            ),
            // UI 요소는 고정
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '꽝! 다시 시도하세요!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    },
                    child: Text('메인으로'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.restartCallback();
                      _restartAnimation(); // 애니메이션 재시작
                    },
                    child: Text('다시 시작'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
