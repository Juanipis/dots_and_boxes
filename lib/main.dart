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
  int rows = 5;
  int columns = 5;
  bool playAgainstAI = false;

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
