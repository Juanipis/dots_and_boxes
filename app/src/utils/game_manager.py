from copy import deepcopy
from typing import Optional, Tuple
from .board import Board
import random


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
        if (cycle):
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

    def get_move(self, origin, dest) -> tuple[Optional[tuple[tuple[int, int], tuple[int, int]]], Optional[str]]:
        coordinates = (origin, dest)

        while True:  # Ciclo para manejar turnos adicionales
            result = self._handle_turn(coordinates)
            if result is not None:
                return result

            if not self._board.has_moves():  # Verificar si el juego ha terminado
                return (None, self.get_victor())

    def _handle_turn(self, coordinates) -> Optional[tuple[Optional[tuple[tuple[int, int], tuple[int, int]]], Optional[str]]]:
        if self.current_turn == "player":
            return self._player_move(coordinates)
        elif self.current_turn == "ai":

            return self._ai_move()
        return None
                     
    def _player_move(self, coordinates, is_simulation: bool = False) -> Optional[tuple[Optional[tuple[tuple[int, int], tuple[int, int]]], Optional[str]]]:
        if is_simulation:
            # Crear una copia del estado del tablero para simular
            simulated_board = deepcopy(self._board)
            self.current_turn = "player"  # Cambiar el turno al jugador durante la simulación
            simulated_board.move(coordinates, player_move=True, is_simulation=True)
            self.current_turn = "ai"  # Después de la simulación, cambiar el turno a la IA
            return simulated_board  # Devolver el estado simulado

        # Movimiento real del jugador
        self.current_turn = "player"  # Asegurarse de que es el turno del jugador
        closed_box = self._board.move(coordinates, player_move=True)

        if closed_box:
            print("Player closed a box, gets another turn.")
            if not self._board.has_moves():
                return (None, self.get_victor())
            # Mantener el turno del jugador si cierra una caja
            return None

        # Después del movimiento real del jugador, cambiar el turno a la IA solo si no se cerró una caja
        self.current_turn = "ai"

        # self._board.display_board()  # Mostrar el estado del tablero después del movimiento del jugador
        self._board.validate_board_state()  # Verificar consistencia del estado del tablero
        self._board.print_board_summary()  # Imprimir resumen del estado del tablero

        return (None, None)


    def _ai_move(self, is_simulation: bool = False) -> Optional[tuple[Optional[tuple[tuple[int, int], tuple[int, int]]], Optional[str]]]:
        if is_simulation:
            # Crear una copia del estado del tablero para simular
            simulated_board = deepcopy(self._board)
            _, best_move = self._mode(simulated_board, self._level, True)
            return best_move

        # Movimiento real de la IA
        self.current_turn = "ai"  # Asegurarse de que es el turno de la IA

        # Determinar la etapa del juego
        total_lines = (self._board.m + 1) * self._board.n + self._board.m * (self._board.n + 1)
        remaining_lines = len(self._board.get_available_moves())
        
        if remaining_lines > total_lines * 0.66:  # Etapa inicial
            # Movimientos rápidos basados en heurística simple
            best_move = self._select_safe_move()
        else:  # Etapas media y final
            # Usar Minimax o Alpha-Beta con profundidad configurada
            _, best_move = self._mode(self._board, self._level, True)

        if best_move is not None:
            self.last_move = best_move
            # Aplica solo el mejor movimiento en el tablero real (tablero del nivel actual)
            closed_box_ai = self._board.move(best_move, player_move=False, is_simulation=False)
            
            #self._board.display_board()
            #self._board.validate_board_state()
            self._board.print_board_summary()

            if closed_box_ai:
                print("AI closed a box, gets another turn.")
                if not self._board.has_moves():
                    return (best_move, self.get_victor())
                # Mantener el turno de la IA si cierra una caja
                return None

            # Después del movimiento, cambiar el turno al jugador solo si no se cerró una caja
            self.current_turn = "player"
            return (best_move, None)

        return (None, None)


    def _select_safe_move(self) -> Optional[tuple[tuple[int, int], tuple[int, int]]]:
        """
        Selecciona un movimiento rápido y seguro en la etapa inicial:
        - Prioriza movimientos que cierren una caja.
        - Evita movimientos que creen tres líneas.
        """
        available_moves = list(self._board.get_available_moves())
        random.shuffle(available_moves)  # Para añadir algo de aleatoriedad en caso de múltiples opciones

        # 1. Buscar movimientos que cierren una caja
        for move in available_moves:
            simulated_state = deepcopy(self._board)
            closed_box = simulated_state.move(move, player_move=False, is_simulation=True)
            if closed_box:
                print(f"AI chooses to close a box with move: {move}")
                return move

        # 2. Evitar movimientos que creen tres líneas
        safe_moves = [move for move in available_moves if not self._creates_three_lines(self._board, move)]

        if safe_moves:
            # 3. Elegir un movimiento seguro al azar
            chosen_move = random.choice(safe_moves)
            print(f"AI chooses a safe move to avoid creating three lines: {chosen_move}")
            return chosen_move

        # 4. Si no hay movimientos seguros, elegir cualquier movimiento disponible
        return random.choice(available_moves) if available_moves else None

    def _creates_three_lines(self, state: Board, move: tuple) -> bool:
        """
        Verifica si un movimiento dado resultará en tres líneas conectadas en una caja.
        """
        simulated_state = deepcopy(state)
        simulated_state.move(move, player_move=False, is_simulation=True)
        
        # Recorremos todas las cajas y verificamos si alguna tiene exactamente tres líneas conectadas
        for i in range(simulated_state.m):
            for j in range(simulated_state.n):
                box = simulated_state._boxes[i][j]
                connected_lines = sum([box._top, box._left, box._right, box._bottom])
                if connected_lines == 3:
                    return True  # Se crea una situación de tres líneas
        return False



    def _find_best_move(self, current_state: Board, best_state: Board) -> Optional[tuple[tuple[int, int], tuple[int, int]]]:
        for move in current_state.get_available_moves():
            simulated_state, _ = self.simulate_move(current_state, move, "ai")
            print(f"Checking move: {move}")
            print(f"Simulated state: {simulated_state}")
            print(f"Best state: {best_state}")
            if simulated_state == best_state:
                return move
        print("No matching move found.")
        return None


    
    def evaluate(self, state: Board) -> float:
        """
        Evalúa el estado del tablero para la IA. Da puntos si el movimiento de la IA cierra una caja y penaliza
        si el movimiento hace una caja de 3 lados.
        """
        ai_score = state.ai_score
        player_score = state.player_score

        # Puntaje inicial es la diferencia en puntajes
        heuristic_value = ai_score - player_score

        # Bonificación y penalización
        bonus_for_closing_boxes = 100  # Puntos por cerrar una caja
        penalty_for_three_lines = 50  # Penalización por crear tres líneas en una caja

        # Recorrer todos los movimientos posibles y simular cada uno
        for move in state.get_available_moves():
            simulated_state = deepcopy(state)
            closed_box = simulated_state.move(move, player_move=False, is_simulation=True)

            # Si el movimiento cierra una caja, se otorga un bonus
            if closed_box:
                heuristic_value += bonus_for_closing_boxes

            # Penalización por crear tres líneas en una caja
            if self._creates_three_lines(simulated_state, move):
                heuristic_value -= penalty_for_three_lines

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
        simulated_state.move(move, player_move=(current_turn == "player"), is_simulation=True)
        
        # Cambia el turno para la siguiente simulación
        next_turn = "player" if current_turn == "ai" else "ai"
        
        # Retorna el estado simulado y el próximo turno
        return simulated_state, next_turn


    def mini_max(self, state: Board, ply: int, max_min: bool) -> tuple[float, Optional[tuple[tuple[int, int], tuple[int, int]]]]:
        if ply == 0 or len(state.get_available_moves()) == 0:
            h = self.evaluate(state)
            return (h, None)
        
        available_moves = list(state.get_available_moves())
        safe_moves = [move for move in available_moves if not self._creates_three_lines(state, move)]

        # Si todos los movimientos crean tres líneas, usamos todos los movimientos
        if not safe_moves:
            safe_moves = available_moves

        best_move = None

        if max_min:
            max_val = float('-inf')
            for move in safe_moves:
                simulated_state, _ = self.simulate_move(state, move, "ai")
                eval, _ = self.mini_max(simulated_state, ply - 1, False)
                if eval > max_val:
                    max_val = eval
                    best_move = move  # Guardar el movimiento en el nivel actual
            return (max_val, best_move)
        else:
            min_val = float('inf')
            for move in safe_moves:
                simulated_state, _ = self.simulate_move(state, move, "player")
                eval, _ = self.mini_max(simulated_state, ply - 1, True)
                if eval < min_val:
                    min_val = eval
                    best_move = move  # Guardar el movimiento en el nivel actual
            return (min_val, best_move)


    def _maximize(self, state: Board, available_moves: list, ply: int) -> tuple[float, tuple[int, int]]:
        max_val = float('-inf')
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


    def _minimize(self, state: Board, available_moves: list, ply: int) -> tuple[float, tuple[int, int]]:
        min_val = float('inf')
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


    def alpha_beta(self, state: Board, ply: int, is_max: bool, alpha=float('-inf'), beta=float('inf')) -> tuple[float, Optional[tuple[tuple[int, int], tuple[int, int]]]]:
        if ply == 0 or not state.has_moves():
            h = self.evaluate(state)
            return (h, None)

        available_moves = list(state.get_available_moves())
        safe_moves = [move for move in available_moves if not self._creates_three_lines(state, move)]

        # Si todos los movimientos crean tres líneas, usamos todos los movimientos
        if not safe_moves:
            safe_moves = available_moves

        best_move = None

        if is_max:
            max_val = float('-inf')
            for move in safe_moves:
                simulated_state, _ = self.simulate_move(state, move, "ai")
                eval, _ = self.alpha_beta(simulated_state, ply - 1, False, alpha, beta)
                if eval > max_val:
                    max_val = eval
                    best_move = move  # Guardar el movimiento en el nivel actual
                alpha = max(alpha, max_val)
                if beta <= alpha:
                    break
            return (max_val, best_move)
        else:
            min_val = float('inf')
            for move in safe_moves:
                simulated_state, _ = self.simulate_move(state, move, "player")
                eval, _ = self.alpha_beta(simulated_state, ply - 1, True, alpha, beta)
                if eval < min_val:
                    min_val = eval
                    best_move = move  # Guardar el movimiento en el nivel actual
                beta = min(beta, min_val)
                if beta <= alpha:
                    break
            return (min_val, best_move)

    def _maximize_alpha_beta(self, state: Board, available_moves: list, ply: int, alpha: float, beta: float) -> tuple[float, tuple[int, int]]:
        max_val = float('-inf')
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



    def _minimize_alpha_beta(self, state: Board, available_moves: list, ply: int, alpha: float, beta: float) -> tuple[float, tuple[int, int]]:
        min_val = float('inf')
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

