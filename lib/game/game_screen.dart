import 'package:audioplayers/audioplayers.dart';
import 'package:dots_and_boxes/ai/service.dart';
import 'package:dots_and_boxes/game/dots_boxes.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final int rows;
  final int columns;
  final bool playAgainstAI;
  final int difficulty;
  final bool alfaBetaPruning;

  const GameScreen(
      {super.key,
      required this.rows,
      required this.columns,
      required this.playAgainstAI,
      required this.difficulty,
      required this.alfaBetaPruning});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late int player1Score;
  late int player2Score;
  late int currentPlayer;
  GameClientService? gameService;
  final AudioPlayer player = AudioPlayer();
  String winP1 = 'audio/win.wav';
  String winP2 = 'audio/win2.wav';
  String winAI = 'audio/lose.wav';
  String backgroundMusic = 'audio/game_music.mp3'; // Tu canción de fondo

  @override
  void initState() {
    super.initState();
    player1Score = 0;
    player2Score = 0;
    currentPlayer = 1;

    // Inicializar el servicio de juego si se juega contra la IA
    if (widget.playAgainstAI) {
      gameService = GameClientService();
    }
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
    String winner;
    if (player1Score > player2Score) {
      winner = widget.playAgainstAI ? "You win against AI!" : "Player 1 wins!";
      player.play(AssetSource(winP1));
    } else if (player2Score > player1Score) {
      winner = widget.playAgainstAI ? "AI wins!" : "Player 2 wins!";
      if (widget.playAgainstAI) {
        player.play(AssetSource(winAI));
      } else {
        player.play(AssetSource(winP2));
      }
    } else {
      winner = "It's a draw!";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text(winner),
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
                Text(
                    widget.playAgainstAI
                        ? 'AI: $player2Score'
                        : 'Player 2: $player2Score',
                    style: const TextStyle(fontSize: 18, color: Colors.red)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: FittedBox(
                    child: DotsAndBoxesBoard(
                      rows: widget.rows,
                      columns: widget.columns,
                      onScoreUpdate: _updateScore,
                      playAgainstAI: widget.playAgainstAI,
                      gameClientService: gameService,
                      difficulty: widget.difficulty,
                      alfaBetaPruning: widget.alfaBetaPruning,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
