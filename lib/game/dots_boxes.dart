import 'dart:math';

import 'package:dots_and_boxes/ai/service.dart';
import 'package:dots_and_boxes/src/generated/game.pb.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class DotsAndBoxesBoard extends StatefulWidget {
  final int rows;
  final int columns;
  final Function(int player, int points) onScoreUpdate;
  final bool playAgainstAI;
  final GameClientService? gameClientService;
  final int difficulty;
  final bool alfaBetaPruning;

  const DotsAndBoxesBoard({
    super.key,
    required this.rows,
    required this.columns,
    required this.onScoreUpdate,
    this.playAgainstAI = false,
    this.gameClientService,
    required this.difficulty,
    required this.alfaBetaPruning,
  });

  @override
  State<DotsAndBoxesBoard> createState() => _DotsAndBoxesBoardState();
}

class _DotsAndBoxesBoardState extends State<DotsAndBoxesBoard> {
  late List<List<int>> horizontalLines;
  late List<List<int>> verticalLines;
  late List<List<int>> boxes;
  int currentPlayer = 1;
  bool isGameInitialized = false;
  bool isAIProcessing = false;
  final player = AudioPlayer();
  String p1Sound = 'audio/p1.wav';
  String p2Sound = 'audio/p2.wav';
  String aiSound = 'audio/ai.wav';

  // Tamaño aumentado para los puntos
  final double widthDot = 20; // Aumentado de 12 a 20
  final double heightDot = 20; // Aumentado de 12 a 20

// Tamaño aumentado para las líneas horizontales
  final double widthHorizontalLine = 80; // Aumentado de 50 a 80
  final double heightHorizontalLine = 12; // Aumentado de 8 a 12

// Tamaño aumentado para las líneas verticales
  final double widthVerticalLine = 12; // Aumentado de 8 a 12
  final double heightVerticalLine = 80; // Aumentado de 50 a 80

// Tamaño aumentado para los cuadros
  final double widthBox = 80; // Aumentado de 50 a 80
  final double heightBox = 80; // Aumentado de 50 a 80

  // Definimos los colores de los jugadores
  final Color player1Color = Colors.blue;
  final Color player2Color = Colors.red;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    horizontalLines =
        List.generate(widget.rows + 1, (_) => List.filled(widget.columns, 0));
    verticalLines =
        List.generate(widget.rows, (_) => List.filled(widget.columns + 1, 0));
    boxes = List.generate(widget.rows, (_) => List.filled(widget.columns, 0));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i <= widget.rows; i++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int j = 0; j <= widget.columns; j++) ...[
                  _buildDot(),
                  if (j < widget.columns) _buildHorizontalLine(i, j),
                ],
              ],
            ),
            if (i < widget.rows)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j <= widget.columns; j++) ...[
                    _buildVerticalLine(i, j),
                    if (j < widget.columns) _buildBox(i, j),
                  ],
                ],
              ),
          ],
          if (isAIProcessing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: widthDot,
      height: heightDot,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHorizontalLine(int row, int col) {
    return GestureDetector(
      onTap: () => _handleLineClick(row, col, true),
      child: Container(
        width: widthHorizontalLine,
        height: heightHorizontalLine,
        color: _getLineColor(horizontalLines[row][col]),
      ),
    );
  }

  Widget _buildVerticalLine(int row, int col) {
    return GestureDetector(
      onTap: () => _handleLineClick(row, col, false),
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: (widthDot / 2) -
                (widthVerticalLine / 2)), // Ajusta la alineación horizontal
        width: widthVerticalLine,
        height: heightVerticalLine,
        color: _getLineColor(verticalLines[row][col]),
      ),
    );
  }

  Color _getLineColor(int player) {
    if (player == 1) return player1Color;
    if (player == 2) return player2Color;
    return Colors.grey[300]!;
  }

  Widget _buildBox(int row, int col) {
    return Container(
      width: widthBox,
      height: heightBox,
      color: boxes[row][col] == 1
          ? player1Color.withOpacity(0.3)
          : boxes[row][col] == 2
              ? player2Color.withOpacity(0.3)
              : Colors.transparent,
    );
  }

  Future<void> _handleLineClick(int row, int col, bool isHorizontal) async {
    if (isAIProcessing) return;
    setState(() {
      if (isHorizontal) {
        if (horizontalLines[row][col] == 0) {
          horizontalLines[row][col] = currentPlayer;
        } else {
          return; // La línea ya está marcada, no hacemos nada
        }
      } else {
        if (verticalLines[row][col] == 0) {
          verticalLines[row][col] = currentPlayer;
        } else {
          return; // La línea ya está marcada, no hacemos nada
        }
      }

      bool boxCompleted = _checkBoxCompletion(row, col, isHorizontal);
      if (currentPlayer == 1) {
        playP1Sound();
      } else {
        playP2Sound();
      }
      if (!boxCompleted) {
        currentPlayer = 3 - currentPlayer; // Cambia entre 1 y 2
      }
    });

    if (widget.playAgainstAI) {
      int originX, originY, destX, destY;
      if (isHorizontal) {
        originX = col;
        originY = row;
        destX = col + 1;
        destY = row;
      } else {
        originX = col;
        originY = row;
        destX = col;
        destY = row + 1;
      }
      setState(() {
        isAIProcessing = true;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (!isGameInitialized) {
        await _initializeAIGame(originX, originY, destX, destY);
        setState(() {
          isAIProcessing = false;
        });
      } else {
        await _makeAIMove(originX, originY, destX, destY);
        setState(() {
          isAIProcessing = false;
        });
      }
    }
  }

  Future<void> _initializeAIGame(int originX, originY, destX, destY) async {
    if (widget.gameClientService == null) return;

    final firstMove = GameMove(
        originX: originX, originY: originY, destX: destX, destY: destY);

    try {
      final response = await widget.gameClientService!.initializeGame(
          widget.rows,
          widget.columns,
          widget
              .difficulty, // Nivel de dificultad, puedes ajustarlo según sea necesario
          firstMove,
          widget.alfaBetaPruning);

      if (response.status == 'continue') {
        isGameInitialized = true;
        final moves = response.nextMove;
        //iterar sobre los movimientos de la IA
        for (var aiMove in moves) {
          playAiSound();
          _applyAIMove(aiMove);
        }
        setState(() {
          currentPlayer = 1;
        });
      } else if (response.status == 'game_over') {
        // Manejar el fin del juego
      }
    } catch (e) {
      print('Error al inicializar el juego con la IA: $e');
    }
  }

  Future<void> _makeAIMove(int originX, originY, destX, destY) async {
    if (widget.gameClientService == null) return;

    final move = GameMove(
        originX: originX, originY: originY, destX: destX, destY: destY);

    try {
      final response = await widget.gameClientService!.makeMove(move);

      if (response.status == 'continue') {
        // Pueden haber multiples movimientos de la IA antes de que el juego termine
        final moves = response.nextMove;
        //iterar sobre los movimientos de la IA
        if (moves.isEmpty) {
          setState(() {
            currentPlayer = 1;
          });
          return;
        }
        for (var aiMove in moves) {
          _applyAIMove(aiMove);
          playAiSound();
          // Esperar un poco antes de hacer el siguiente movimiento
          await Future.delayed(const Duration(milliseconds: 500));
        }
        setState(() {
          currentPlayer = 1;
        });
      } else if (response.status == 'game_over') {
        // Manejar el fin del juego
      }
    } catch (e) {
      print('Error al hacer el movimiento de la IA: $e');
    }
  }

  void _applyAIMove(GameMove aiMove) {
    setState(() {
      // Determinar si el movimiento es horizontal basado en si las coordenadas Y son iguales
      final isHorizontal = aiMove.originY == aiMove.destY;

      // Asignar 'row' y 'col' basados en si es un movimiento horizontal o vertical
      final row =
          isHorizontal ? aiMove.originY : min(aiMove.originY, aiMove.destY);
      final col =
          isHorizontal ? min(aiMove.originX, aiMove.destX) : aiMove.originX;

      // Aplicar el movimiento en el array adecuado
      if (isHorizontal) {
        horizontalLines[row][col] =
            2; // Asigna al jugador AI en las líneas horizontales
      } else {
        verticalLines[row][col] =
            2; // Asigna al jugador AI en las líneas verticales
      }

      // Verificar si la adición de esta línea completa una caja
      bool boxCompleted = _checkBoxCompletion(row, col, isHorizontal);
    });
  }

  bool _checkBoxCompletion(int row, int col, bool isHorizontal) {
    bool completed = false;
    int pointsScored = 0;

    if (isHorizontal) {
      if (row > 0 && _isBoxComplete(row - 1, col)) {
        boxes[row - 1][col] = currentPlayer;
        completed = true;
        pointsScored++;
      }
      if (row < widget.rows && _isBoxComplete(row, col)) {
        boxes[row][col] = currentPlayer;
        completed = true;
        pointsScored++;
      }
    } else {
      if (col > 0 && _isBoxComplete(row, col - 1)) {
        boxes[row][col - 1] = currentPlayer;
        completed = true;
        pointsScored++;
      }
      if (col < widget.columns && _isBoxComplete(row, col)) {
        boxes[row][col] = currentPlayer;
        completed = true;
        pointsScored++;
      }
    }

    if (pointsScored > 0) {
      widget.onScoreUpdate(currentPlayer, pointsScored);
    }

    return completed;
  }

  bool _isBoxComplete(int row, int col) {
    return horizontalLines[row][col] != 0 &&
        horizontalLines[row + 1][col] != 0 &&
        verticalLines[row][col] != 0 &&
        verticalLines[row][col + 1] != 0;
  }

  Future<void> playP1Sound() async {
    await player.play(AssetSource(p1Sound), volume: 1.0);
  }

  Future<void> playP2Sound() async {
    await player.play(AssetSource(p2Sound), volume: 1.0);
  }

  Future<void> playAiSound() async {
    await player.play(AssetSource(aiSound), volume: 1.0);
  }
}
