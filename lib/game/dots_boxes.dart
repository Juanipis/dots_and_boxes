import 'dart:math';

import 'package:dots_and_boxes/ai/service.dart';
import 'package:dots_and_boxes/src/generated/game.pb.dart';
import 'package:flutter/material.dart';

class DotsAndBoxesBoard extends StatefulWidget {
  final int rows;
  final int columns;
  final Function(int player, int points) onScoreUpdate;
  final bool playAgainstAI;
  final GameClientService? gameClientService;

  const DotsAndBoxesBoard({
    super.key,
    required this.rows,
    required this.columns,
    required this.onScoreUpdate,
    this.playAgainstAI = false,
    this.gameClientService,
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
      width: 10,
      height: 10,
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
        width: 40,
        height: 10,
        color: _getLineColor(horizontalLines[row][col]),
      ),
    );
  }

  Widget _buildVerticalLine(int row, int col) {
    return GestureDetector(
      onTap: () => _handleLineClick(row, col, false),
      child: Container(
        width: 10,
        height: 40,
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
      width: 40,
      height: 40,
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
      if (!isGameInitialized) {
        await _initializeAIGame(originX, originY, destX, destY);
        setState(() {
          isAIProcessing = false;
        });
      } else if (currentPlayer == 2) {
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
        3, // Nivel de dificultad, puedes ajustarlo según sea necesario
        firstMove,
      );

      if (response.status == 'continue') {
        isGameInitialized = true;
        _applyAIMove(response.nextMove);
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
        _applyAIMove(response.nextMove);
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
      if (!boxCompleted) {
        currentPlayer =
            1; // Cambiar el turno al jugador humano si no se completa una caja
      }
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
}
