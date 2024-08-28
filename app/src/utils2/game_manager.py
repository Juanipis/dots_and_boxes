from copy import deepcopy
from typing import Optional, Tuple
from .board import Board


class GameManager:
    def __init__(self, m, n, level, mode="minimax"):
        self._level = level
        self._board = Board(m, n)
        self.current_turn = "player"  # El turno inicial es del jugador
        self.last_move = None

        if mode == "alphabeta":
            self._mode = self.alpha_beta
            print("Using AlphaBeta pruning")
        else:
            self._mode = self.mini_max
            print("Using Minimax")

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
            return "player"
        elif self._board.player_score < self._board.ai_score:
            return "ai"
        else:
            return "draw"

    def get_move(
        self, origin, dest
    ) -> tuple[Optional[tuple[tuple[int, int], tuple[int, int]]], Optional[str]]:
        coordinates = (origin, dest)

        while True:  # Ciclo para manejar turnos adicionales
            result = self._handle_turn(coordinates)

            if result is not None:
                return result

            if not self._board.has_moves():  # Verificar si el juego ha terminado
                return (None, self.get_victor())

    def _handle_turn(
        self, coordinates
    ) -> Optional[
        tuple[Optional[tuple[tuple[int, int], tuple[int, int]]], Optional[str]]
    ]:
        if self.current_turn == "player":
            return self._player_move(coordinates)
        elif self.current_turn == "ai":
            return self._ai_move()
        return None

    def _player_move(
        self, coordinates, is_simulation: bool = False
    ) -> Optional[
        tuple[Optional[tuple[tuple[int, int], tuple[int, int]]], Optional[str]]
    ]:
        if is_simulation:
            # Crear una copia del estado del tablero para simular
            simulated_board = deepcopy(self._board)
            self.current_turn = (
                "player"  # Cambiar el turno al jugador durante la simulación
            )
            simulated_board.move(coordinates, player_move=True, is_simulation=True)
            self.current_turn = (
                "ai"  # Después de la simulación, cambiar el turno a la IA
            )
            return simulated_board  # Devolver el estado simulado

        # Movimiento real del jugador
        self.current_turn = "player"  # Asegurarse de que es el turno del jugador
        closed_box = self._board.move(coordinates, player_move=True)

        if closed_box:
            print("Player closed a box, gets another turn.")
            if not self._board.has_moves():
                return (None, self.get_victor())
            return None  # El jugador mantiene el turno si cierra una caja

        # Después del movimiento real del jugador, cambiar el turno a la IA
        self.current_turn = "ai"

        self._board.display_board()  # Mostrar el estado del tablero después del movimiento del jugador
        self._board.validate_board_state()  # Verificar consistencia del estado del tablero
        self._board.print_board_summary()  # Imprimir resumen del estado del tablero

        return (None, None)

    def _ai_move(
        self, is_simulation: bool = False
    ) -> Optional[
        tuple[Optional[tuple[tuple[int, int], tuple[int, int]]], Optional[str]]
    ]:
        if is_simulation:
            simulated_board = deepcopy(self._board)
            eval, best_state = self._mode(simulated_board, self._level, True)
            return best_state

        self.current_turn = "ai"

        eval, best_move = self._mode(self._board, self._level, True)

        if best_move is not None:
            self.last_move = best_move

            closed_box_ai = self._board.move(
                best_move, player_move=False, is_simulation=False
            )

            self._board.display_board()
            self._board.validate_board_state()
            self._board.print_board_summary()

            if closed_box_ai:
                print("AI closed a box, gets another turn.")
                if not self._board.has_moves():
                    self.current_turn = "player"
                    return (best_move, self.get_victor())

                # La IA tiene otro turno, por lo que retornamos None para continuar
                return (best_move, None)

            # Si la IA no cerró una caja, cambiamos el turno al jugador
            self.current_turn = "player"
            return (best_move, None)

        return (None, None)

    def _find_best_move(
        self, current_state: Board, best_state: Board
    ) -> Optional[tuple[tuple[int, int], tuple[int, int]]]:
        for move in current_state.get_available_moves():
            simulated_state, _ = self.simulate_move(current_state, move, "ai")
            # print(f"Checking move: {move}")
            # print(f"Simulated state: {simulated_state}")
            # print(f"Best state: {best_state}")
            if simulated_state == best_state:
                return move
        # print("No matching move found.")
        return None

    def evaluate(self, state: Board) -> float:
        ai_score = state.ai_score
        player_score = state.player_score

        total_lines = (state.m + 1) * state.n + state.m * (state.n + 1)
        remaining_lines = len(state._open_vectors)

        # Determinar la etapa del juego
        if remaining_lines > total_lines * 0.66:
            game_stage = "early"
        elif remaining_lines > total_lines * 0.33:
            game_stage = "mid"
        else:
            game_stage = "late"

        long_chains = 0

        # Analizar líneas y detectar cadenas
        chains = self._detect_chains(state)

        for chain in chains:
            if len(chain) >= 3:
                long_chains += 1

        # Evaluar el valor heurístico según la etapa del juego
        heuristic_value = ai_score - player_score

        if game_stage == "early":
            heuristic_value -= (
                long_chains * 15
            )  # Penaliza fuertemente cadenas largas en el inicio
        elif game_stage == "mid":
            heuristic_value -= (
                long_chains * 10
            )  # Penaliza pero menos en la mitad del juego
        else:
            heuristic_value += (
                len(chains) - long_chains
            ) * 5  # Valora cerrar cadenas si están disponibles

        return heuristic_value

    def _detect_chains(self, state: Board):
        chains = []
        visited = set()

        for line in state._moves:
            if line not in visited:
                chain = self._explore_chain(state, line, visited)
                if chain:
                    chains.append(chain)

        return chains

    def _explore_chain(self, state: Board, start_line, visited: set):
        chain = []
        stack = [start_line]

        while stack:
            line = stack.pop()
            if line in visited:
                continue

            visited.add(line)
            chain.append(line)

            connected_lines = self._get_connected_lines(state, line, visited)
            stack.extend(connected_lines)

        return chain

    def _get_connected_lines(self, state: Board, line, visited: set):
        connected_lines = []

        for box in state._boxes:
            for b in box:
                if line in b.lines:
                    for l in b.lines:
                        if l != line and l in state._moves and l not in visited:
                            connected_lines.append(l)

        return connected_lines

    @staticmethod
    def simulate_move(state, move, current_turn):
        # Realiza una copia profunda del estado para no modificar el original
        simulated_state = deepcopy(state)

        # Aplica el movimiento para el jugador actual
        simulated_state.move(
            move, player_move=(current_turn == "player"), is_simulation=True
        )

        # Cambia el turno para la siguiente simulación
        next_turn = "player" if current_turn == "ai" else "ai"

        # Retorna el estado simulado y el próximo turno
        return simulated_state, next_turn

    def mini_max(self, state: Board, ply: int, max_min: bool) -> tuple[float, Board]:
        if ply == 0 or len(state._open_vectors) == 0:
            h = self.evaluate(state)
            return (h, None)

        available_moves = list(state.get_available_moves())

        if max_min:
            return self._maximize(state, available_moves, ply)
        else:
            return self._minimize(state, available_moves, ply)

    def _maximize(
        self, state: Board, available_moves: list, ply: int
    ) -> tuple[float, tuple[int, int]]:
        max_val = float("-inf")
        best_move = None

        for move in available_moves:
            # Simula el movimiento en una copia del tablero
            simulated_state, _ = self.simulate_move(state, move, "ai")

            # Evalúa el estado resultante mediante una llamada recursiva a minimax
            eval, _ = self.mini_max(simulated_state, ply - 1, False)

            # Si el valor es mejor, guarda el movimiento como el mejor
            if eval > max_val:
                max_val = eval
                best_move = move  # Solo guardas el mejor movimiento

        return (max_val, best_move)

    def _minimize(
        self, state: Board, available_moves: list, ply: int
    ) -> tuple[float, tuple[int, int]]:
        min_val = float("inf")
        best_move = None

        for move in available_moves:
            # Simula el movimiento en una copia del tablero
            simulated_state, _ = self.simulate_move(state, move, "player")

            # Evalúa el estado resultante mediante una llamada recursiva a minimax
            eval, _ = self.mini_max(simulated_state, ply - 1, True)

            # Si el valor es mejor, guarda el movimiento como el mejor
            if eval < min_val:
                min_val = eval
                best_move = move  # Solo guardas el mejor movimiento

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

        available_moves = list(state.get_available_moves())

        if is_max:
            return self._maximize_alpha_beta(state, available_moves, ply, alpha, beta)
        else:
            return self._minimize_alpha_beta(state, available_moves, ply, alpha, beta)

    def _maximize_alpha_beta(
        self, state: Board, available_moves: list, ply: int, alpha: float, beta: float
    ) -> tuple[float, tuple[int, int]]:
        max_val = float("-inf")
        best_move = None

        for move in available_moves:
            # Simula el movimiento en una copia del tablero
            simulated_state, _ = self.simulate_move(state, move, "ai")

            # Evalúa el estado resultante mediante una llamada recursiva a alpha_beta
            eval, _ = self.alpha_beta(simulated_state, ply - 1, False, alpha, beta)

            # Si el valor es mejor, guarda el movimiento como el mejor
            if eval > max_val:
                max_val = eval
                best_move = move  # Solo guardas el mejor movimiento

            # Actualiza alfa
            alpha = max(alpha, max_val)

            # Poda alfa-beta
            if beta <= alpha:
                break

        return (max_val, best_move)

    def _minimize_alpha_beta(
        self, state: Board, available_moves: list, ply: int, alpha: float, beta: float
    ) -> tuple[float, tuple[int, int]]:
        min_val = float("inf")
        best_move = None

        for move in available_moves:
            # Simula el movimiento en una copia del tablero
            simulated_state, _ = self.simulate_move(state, move, "player")

            # Evalúa el estado resultante mediante una llamada recursiva a alpha_beta
            eval, _ = self.alpha_beta(simulated_state, ply - 1, True, alpha, beta)

            # Si el valor es mejor, guarda el movimiento como el mejor
            if eval < min_val:
                min_val = eval
                best_move = move  # Solo guardas el mejor movimiento

            # Actualiza beta
            beta = min(beta, min_val)

            # Poda alfa-beta
            if beta <= alpha:
                break

        return (min_val, best_move)

    def play(self, player_coordinates: Tuple[int, int]) -> list:
        """
        Método para manejar la secuencia de juego de un jugador humano y la IA.
        :param player_coordinates: Las coordenadas del movimiento del jugador.
        :return: Una lista de todos los movimientos realizados por la IA.
        """
        ai_moves = []

        # El jugador hace su movimiento
        result = self._player_move(player_coordinates)

        # Si el jugador cierra una caja y tiene otro turno, devolver result como None
        if result is not None and result[1] is not None:
            return ai_moves

        # Mientras sea el turno de la IA, esta jugará
        while self.current_turn == "ai" and self._board.has_moves():
            move, victor = self._ai_move() or (None, None)

            if move is None and self.last_move is not None:
                move = self.last_move

            if move:
                ai_moves.append(move)
                self.last_move = None

            if victor:  # Si el juego ha terminado
                break

        return ai_moves
