import 'package:dots_and_boxes/game/dots_boxes.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final int rows;
  final int columns;
  final bool playAgainstAI;

  const GameScreen(
      {super.key,
      required this.rows,
      required this.columns,
      required this.playAgainstAI});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late int player1Score;
  late int player2Score;
  late int currentPlayer;

  @override
  void initState() {
    super.initState();
    player1Score = 0;
    player2Score = 0;
    currentPlayer = 1;
  }

  void _updateScore(int player, int points) {
    setState(() {
      if (player == 1) {
        player1Score += points;
      } else {
        player2Score += points;
      }

      if (player1Score + player2Score == widget.rows * widget.columns) {
        _showWinner();
      }
    });
  }

  void _showWinner() {
    String winner = player1Score > player2Score ? "Player 1" : "Player 2";
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('$winner wins!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Back to Home'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dots and Boxes Game'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Player 1: $player1Score',
                    style: const TextStyle(fontSize: 18, color: Colors.blue)),
                Text('Player 2: $player2Score',
                    style: const TextStyle(fontSize: 18, color: Colors.red)),
              ],
            ),
          ),
          Expanded(
            child: DotsAndBoxesBoard(
              rows: widget.rows,
              columns: widget.columns,
              onScoreUpdate: _updateScore,
            ),
          ),
        ],
      ),
    );
  }
}
