import 'package:audioplayers/audioplayers.dart';
import 'package:dots_and_boxes/game/game_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DotsAndBoxesApp());
}

class DotsAndBoxesApp extends StatelessWidget {
  const DotsAndBoxesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dots and Boxes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int rows = 3;
  int columns = 3;
  bool playAgainstAI = false;
  int difficulty = 3;
  bool alfaBetaPruning = false;
  final AudioPlayer player = AudioPlayer();
  final String lobbyMusic = 'audio/lobby.mp3';

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  void _playBackgroundMusic() async {
    await player.setReleaseMode(
        ReleaseMode.loop); // Configura el modo de repetición continua
    await player
        .setSource(AssetSource(lobbyMusic)); // Establece la fuente de audio
    await player.setVolume(
        0.3); // Ajusta el volumen (0.0 a 1.0), 0.3 es un volumen bajo
    await player.resume(); // Reproduce la música
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dots and Boxes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Configure Game',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Rows: '),
                DropdownButton<int>(
                  value: rows,
                  items: [3, 4, 5, 6, 7].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      rows = newValue!;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Columns: '),
                DropdownButton<int>(
                  value: columns,
                  items: [3, 4, 5, 6, 7].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      columns = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Play against AI: '),
                Switch(
                  value: playAgainstAI,
                  onChanged: (bool newValue) {
                    setState(() {
                      playAgainstAI = newValue;
                    });
                  },
                ),
              ],
            ),
            if (playAgainstAI)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Difficulty: '),
                  DropdownButton<int>(
                    value: difficulty,
                    items: [1, 2, 3, 4, 5].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        difficulty = newValue!;
                      });
                    },
                  ),
                ],
              ),
            if (playAgainstAI)
              // A Swithc to turn alfa-beta pruning on or off
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Alfa-Beta Pruning: '),
                  Switch(
                    value: alfaBetaPruning,
                    onChanged: (bool newValue) {
                      setState(() {
                        alfaBetaPruning = newValue;
                      });
                    },
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Start Game'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      rows: rows,
                      columns: columns,
                      playAgainstAI: playAgainstAI,
                      difficulty: difficulty,
                      alfaBetaPruning: alfaBetaPruning,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
