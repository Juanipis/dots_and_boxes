from typing import Optional, Union
from .board import Board
from copy import deepcopy
import random


class GameManager:
    def __init__(self, m, n, level, mode="minimax"):
        self._level = level
        self._board = Board(m, n)

        if mode == "alphabeta":
            self._mode = self.alpha_beta
        else:
            self._mode = self.mini_max

    def _repr_pretty_(self, p, cycle):
        if cycle:
            pass

        # Display player scores
        p.text(f"    AI Score : {self._board.ai_score}\n")
        p.text(f"Player Score : {self._board.player_score}\n")
        self._board._repr_pretty_(p, cycle)

    def get_victor(self):
        print("The game ended")
        print(f"Score: Player={self._board.player_score}, AI={self._board.ai_score}")

        if self._board.player_score > self._board.ai_score:
            victor = "player"
        elif self._board.player_score < self._board.ai_score:
            victor = "ai"
        else:
            victor = "draw"

        return victor

    def ai_start(self):
        pass

    def get_move(
        self, origin, dest
    ) -> tuple[Optional[Union[list[tuple[int, int]], tuple[int, int]]], Optional[str]]:  # noqa: F821
        ai_moves = []
        # Inicialmente obtenemos el movimiento del jugador.
        coordinates = (origin, dest)
        valid_move = self._board.move(coordinates, player_move=True)
        # Un movimiento valido es aquel que obtiene puntos como rellenar un cuadro.
        if valid_move is None:
            # Si el movimiento no es válido, la IA hace su movimiento.
            board = deepcopy(self._board)
            next_move = self._mode(board, self._level, True)
            ai_moves.append(next_move[1])

            ai_initial_score = self._board.ai_score
            self._board.move(next_move[1])

            # Mientras la IA obtenga puntos, seguirá jugando.
            while self._board.has_moves() and self._board.ai_score > ai_initial_score:
                ai_initial_score = (
                    self._board.ai_score
                )  # Actualizar la puntuación inicial
                next_move = self._mode(board, self._level, True)
                ai_moves.append(next_move[1])
                self._board.move(next_move[1])

            # Si no hay más movimientos, determinar el ganador.
            if not self._board.has_moves():
                return (next_move[1], self.get_victor())
            # Se devuelven todos los movimientos de la IA.
            return (ai_moves, None)
        elif valid_move:
            # Si el jugador hizo un movimiento válido y no hay más movimientos, determinar el ganador.
            if not self._board.has_moves():
                return (None, self.get_victor())
            print("Player got point, plays again")
        else:
            print("Invalid player move")

        return (None, None)

    def mini_max(self, state: Board, ply: int, max_min: bool) -> tuple[float, Board]:
        if ply == 0 or len(state._open_vectors) == 0:
            h = self.evaluate(state)
            return (h, None)

        best_move = None

        available_moves = list(state.get_available_moves())
        # ai turn
        if max_min is True:
            max_val = float("-inf")
            for move in available_moves:
                # new_state = deepcopy(state)
                # new_state.move(move, player_move = False)
                state.move(move, player_move=False)
                eval, _ = self.mini_max(state, ply - 1, False)
                if eval > max_val:
                    max_val = eval
                    best_move = move
                state.undo_last_move()

            return (max_val, best_move)

        # player turn
        else:
            min_val = float("inf")
            for move in available_moves:
                # new_state = deepcopy(state)
                # new_state.move(move, player_move = True)
                state.move(move, player_move=True)
                eval, _ = self.mini_max(state, ply - 1, True)
                if eval < min_val:
                    min_val = eval
                    best_move = move
                state.undo_last_move()

            return (min_val, best_move)

    def alpha_beta(
        self,
        state: Board,
        ply: int,
        is_max: bool,
        alpha=float("-inf"),
        beta=float("inf"),
    ) -> tuple[float, Board]:
        if ply == 0 or not state.has_moves():
            h = self.evaluate(state)
            return (h, None)

        best_move = None

        available_moves = list(state.get_available_moves())
        if is_max:
            max_val = float("-inf")
            for move in available_moves:
                new_state = deepcopy(state)
                new_state.move(move, player_move=False)
                eval, _ = self.alpha_beta(new_state, ply - 1, False, alpha, beta)
                if eval > max_val:
                    max_val = eval
                    best_move = move
                alpha = max(alpha, max_val)

                state.undo_last_move()
                if beta <= alpha:
                    break

            return (max_val, best_move)
        else:
            min_val = float("inf")
            for move in available_moves:
                new_state = deepcopy(state)
                new_state.move(move, player_move=True)
                eval, _ = self.alpha_beta(new_state, ply - 1, True, alpha, beta)
                if eval < min_val:
                    min_val = eval
                    best_move = move

                beta = min(beta, min_val)

                state.undo_last_move()
                if beta <= alpha:
                    break

            return (min_val, best_move)

    def evaluate(self, state: Board):
        return random.randint(0, 100)
