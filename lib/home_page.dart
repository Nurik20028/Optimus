import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cosmosproject/robot.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late Robot red1;
  late Robot yellow2;

  String winnerText = "Who will win?";

  //states
  bool showLotteis = false;
  bool showStaticImages = true;
  bool fireRed1 = false, fireRed2 = false;
  bool fireYellow1 = false, fireYellow2 = false;
  bool lotty2Visible = false, lotty2dVisible = false;
  bool isGameStarted = false;
  bool isGameOver = false;

  int red1MaxEnergy = 1;
  int yellow2MaxEnergy = 1;

  @override
  void initState(){
    super.initState();

    setRandomValues();
    _audioPlayer.setVolume(1.0);
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }

  void setRandomValues(){
    Random random = Random();
    red1 = Robot(
      name: 'OPTIMUS',
      energy: random.nextInt(7000) + 100,
      lasers: random.nextInt(50) + 1,
    );
    yellow2 = Robot(
      name: "Galactus",
      energy: random.nextInt(7000)+100,
      lasers: random.nextInt(50) + 1,
    );

    // Запоминаем максимальное ХП для полосок здоровья
    red1MaxEnergy = red1.energy;
    yellow2MaxEnergy = yellow2.energy;

    winnerText = "Who will win ?";
    isGameOver = false;
  }

  void _playSound(int type) async {
    String filName = "";
    if (type ==1) {
      filName = 'attack_laser.mp3';
    } else if (type == 2) {
      filName = 'laser_shot.mp3';
    } else {
      filName = 'explosion_yellow.mp3';
    }

    try {
      await _audioPlayer.play(AssetSource('sounds/$filName'));
    }catch (e){
      print("Error playing sound: $e");
    }
  }

  bool _checkGaming(){
    if (red1.energy <= 0 || yellow2.energy <=0){
      _stopping();
      return false;
    }
    return true;
  }

  void _stopping(){
    setState(() {
      isGameOver = true;
      winnerText = red1.energy <=0 ? "Galactus won!" : "OPTIMUS win";
      showLotteis = false;
    });
  }

  void _onFight(int type){
    if (!_checkGaming()) return;

    _playSound(type);

    setState((){
      if (type ==1){
        fireRed1 = true;
        yellow2.minusEnergy(200);
        red1.minusEnergy(red1.lasers);
        Future.delayed(
          const Duration(seconds: 1),
              () => setState(() => fireRed1 = false),
        );
      }else if (type ==2){
        fireRed2 = true;
        yellow2.minusEnergy(200);
        red1.minusEnergy(red1.lasers);
        Future.delayed(
          const Duration(seconds: 1),
              () => setState(() => fireRed2 = false),
        );
      }else if (type == 3){
        fireYellow1 = true;
        red1.minusEnergy(200);
        yellow2.minusEnergy(yellow2.lasers);
        Future.delayed(
            const Duration(milliseconds: 1600),
                () => setState(() => fireYellow1 = false)
        );
      }else if(type == 4){
        fireYellow2 = true;
        red1.minusEnergy(200);
        yellow2.minusEnergy(yellow2.lasers);
        Future.delayed(
          const Duration(milliseconds: 1600),
              () => setState(() => fireYellow2 = false),
        );
      }
    });
    _checkGaming();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/cosmos_compositing16.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            if (showLotteis) ...[
              // Первый робот (Оптимус)
              Positioned(
                left: -38,
                top: -50,
                child: Lottie.asset(
                  'assets/lottie/red_robot.json',
                  width: 340,
                  height: 340,
                ),
              ),

              // Второй робот (Галактус)
              if (lotty2dVisible)
                Positioned(
                  right: -30,
                  top: 130,
                  child: Lottie.asset(
                    'assets/lottie/y_robot.json',
                    width: 178,
                    height: 180,
                  ),
                ),
            ],

            // Robots Images
            if(showStaticImages)
              Positioned(
                top:42,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.asset(
                        "assets/images/img_yellow_robot100.png",
                        fit: BoxFit.contain,
                        height:220,
                      ),
                    ),
                    Expanded(
                      child: Image.asset(
                        "assets/images/red_robot100.png",
                        fit: BoxFit.contain,
                        height:220,
                      ),
                    ),
                  ],
                ),
              ),

            // Эффекты выстрелов
            if(fireRed1)
              Positioned(
                left: 290,
                top: 150,
                child: Image.asset(
                  "assets/images/fire_laser_up_to_right.png",
                  width: 220,
                ),
              ),
            if(fireRed2)
              Positioned(
                  left: 280,
                  top: 80,
                  child: Image.asset(
                    "assets/images/fire_laser_down_to_right.png",
                    width: 220,
                  )
              ),
            if(fireYellow1)
              Positioned(
                right: 108,
                top: 86,
                child: Image.asset("assets/images/image_explosion_yellow.png",
                  width: 120,
                  height: 100,
                ),
              ),
            if(fireYellow2)
              Positioned(
                right: 290,
                top: 130,
                child: Image.asset("assets/images/fire_laser_to_left.png",
                  width: 120,
                  height: 100,
                ),
              ),

            // Имена роботов:
            Positioned(
                top:280,
                left:10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Flexible(child: Text(
                      "Galactus",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xffecf4b4),
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ),
                    Flexible(
                      child:Text(
                        "Optimus",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFF3B44D),
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
            ),

            // Who Win Text
            Positioned(
              top:340,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  winnerText,
                  style: const TextStyle(
                    color: Color(0xffecf4b4),
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // --- АНИМИРОВАННЫЕ ШКАЛЫ ЗДОРОВЬЯ ---
            Positioned(
              top: 400,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Галактус слева
                  _buildHealthBar(yellow2.energy, yellow2MaxEnergy, true),
                  // Оптимус справа
                  _buildHealthBar(red1.energy, red1MaxEnergy, false),
                ],
              ),
            ),

            // Показатели урона (Лазеры)
            Positioned(
              top: 468, // Оставили только лазеры, так как HP теперь в полосках
              left: 14,
              right: 14,
              child: _buildStatsRow(
                "Lasers1:",
                red1.lasers.toString(),
                "Lasers2:",
                yellow2.lasers.toString(),
              ),
            ),

            // Start Button
            if(!isGameStarted)
              Positioned(
                top: 500,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff650216),
                      minimumSize: const Size(110, 60),
                    ),
                    onPressed: () => setState(() {
                      isGameStarted = true;
                      showStaticImages = true;
                      showLotteis = true;
                      lotty2dVisible = true;
                    }),
                    child: const Text("start", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),

            if (isGameStarted && !isGameOver) ...[
              Positioned(
                top: 525,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _fightBtn("Fight UP!", () => _onFight(1)),
                    if (lotty2dVisible)
                      _fightBtn("Fight Up!", () => _onFight(3))
                    else
                      const SizedBox(width: 110),
                  ],
                ),
              ),

              Positioned(
                top: 605,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _fightBtn("Fight Down!", () => _onFight(2)),
                    _fightBtn("Fight Down!", () => _onFight(4)),
                  ],
                ),
              ),

              // Hide one of Robots:
              Positioned(
                bottom: 80,
                right: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffc0aef3),
                  ),
                  onPressed: (){
                    if(!_checkGaming()) return;
                    setState(() {
                      lotty2Visible = false;
                      lotty2dVisible = true;
                    });
                    Future.delayed(
                      const Duration(seconds: 3),
                          () => setState(() => lotty2dVisible = false),
                    );
                    Future.delayed(
                      const Duration(seconds: 4),
                          () => setState(() => lotty2Visible = true),
                    );
                  },
                  child: const Text(
                    "Hide \nRight Robot",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],

            if (isGameOver)
              Positioned(
                bottom: 90,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: const Size(240, 90),
                    ),
                    onPressed: () => setState(() {
                      setRandomValues();
                      isGameStarted = true;
                      showLotteis = true;
                    }),
                    child: const Text(
                      "Game Over \nStart Again",
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  // Виджет для текста (сейчас используется только для лазеров)
  Widget _buildStatsRow(String label1, String val1, String label2, String val2) {
    const labelStyle = TextStyle(color: Color(0xFFFFC107), fontSize: 18);
    const valStyle = TextStyle(
      color: Color(0xFFFFC107),
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );

    return Row(
      children: [
        Text(label1, style: labelStyle),
        const SizedBox(width: 5),
        Expanded(child: Text(val1, style: valStyle, overflow: TextOverflow.ellipsis)),
        Text(label2, style: labelStyle),
        const SizedBox(width: 5),
        Expanded(child: Text(val2, style: valStyle, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  // Кнопка атаки
  Widget _fightBtn(String label, VoidCallback onPressed){
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        minimumSize: const Size(110, 60),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
    );
  }

  // --- ЕДИНСТВЕННЫЙ И ПРАВИЛЬНЫЙ ВИДЖЕТ ШКАЛЫ ЗДОРОВЬЯ ---
  Widget _buildHealthBar(int currentEnergy, int maxEnergy, bool isLeft) {
    double percent = currentEnergy / maxEnergy;
    if (percent < 0) percent = 0.0;
    if (percent > 1) percent = 1.0;

    Color barColor = Colors.greenAccent;
    if (percent < 0.5) barColor = Colors.orangeAccent;
    if (percent < 0.2) barColor = Colors.redAccent;

    return Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          "HP: $currentEnergy",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 20,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: FractionallySizedBox(
            alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            widthFactor: percent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: barColor.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}