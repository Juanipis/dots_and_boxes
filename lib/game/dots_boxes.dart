import 'package:flutter/material.dart';

class DotsAndBoxesBoard extends StatefulWidget {
  final int rows;
  final int columns;
  final Function(int player, int points) onScoreUpdate;

  const DotsAndBoxesBoard({
    super.key,
    required this.rows,
    required this.columns,
    required this.onScoreUpdate,
  });

  @override
  State<DotsAndBoxesBoard> createState() => _DotsAndBoxesBoardState();
}

class _DotsAndBoxesBoardState extends State<DotsAndBoxesBoard> {
  late List<List<int>> horizontalLines;
  late List<List<int>> verticalLines;
  late List<List<int>> boxes;
  int currentPlayer = 1;

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

  void _handleLineClick(int row, int col, bool isHorizontal) {
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
