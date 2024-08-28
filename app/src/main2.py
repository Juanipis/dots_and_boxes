from utils2.game_manager import GameManager


game_min = GameManager(3, 3, 3)
move = game_min.get_move((0, 0), (0, 1))
print(move)

# Luego la IA hace su movimiento
ia_move = game_min.get_move(None, None)
print(ia_move)

# mostramos el tablero
game_min._board.display_board()

print("-------------")

# Hago un movimiento
move = game_min.get_move((0, 0), (1, 0))
print(move)

# Luego la IA hace su movimiento
ia_move = game_min.get_move(None, None)
print(ia_move)

# mostramos el tablero
game_min._board.display_board()

# Hago un movimiento
move = game_min.get_move((1, 0), (1, 1))
print(move)

# Luego la IA hace su movimiento
ia_move = game_min.get_move(None, None)
print(ia_move)

# mostramos el tablero
game_min._board.display_board()
