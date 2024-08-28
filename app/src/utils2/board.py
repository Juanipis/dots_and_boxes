from copy import deepcopy
from .box import Box


class Board:
    display_single_box = False

    def __init__(self, m, n):
        self.player_score = 0
        self.ai_score = 0
        self.m = m
        self.n = n
        self._boxes = self._generate_boxes(m, n)
        self._open_vectors = self._generate_vectors(m, n)
        self._moves = []
        # Verificar si los vectores se generaron correctamente
        # print(f"Open Vectors Initialized: {self._open_vectors}")

    def _generate_boxes(self, rows, cols):
        """
        This function generates the boxes of the board
        """
        boxes = [[Box(x, y) for x in range(cols)] for y in range(rows)]

        return boxes

    def _generate_vectors(self, m, n):
        """
        The vectors represent the available moves, or lines, which can
        be played on a game board of m rows and n columns. These are stored as tuples
        containing each coordinate and are stored in a queue. The vector queue, along
        with the list of boxes that correspond to the coordinates, are used to represent
        game state.
        Vector format: ((x1, y1), (x2, y2)).

        The vectors always point away from the origin (0, 0), so moving like (1, 0) => (0, 0)
        is not a valid move while (0, 0) => (1, 0) is a valid move
        """
        vectors = set()
        for i in range(0, m + 1):
            for j in range(0, n):
                # Adding horizontal line vectors
                vectors.add(((j, i), (j + 1, i)))
                # Adding vertical line vectors if not in the last row
                if i < m:
                    vectors.add(((j, i), (j, i + 1)))
            # Adding the vertical line for the last column in the current row
            if i < m:
                vectors.add(((n, i), (n, i + 1)))
        return vectors

    def is_valid_move(self, coordinates):
        return coordinates in self._open_vectors

    def move(self, coordinates, player_move: bool = False, is_simulation: bool = False):
        if not self.is_valid_move(coordinates):
            # print(f"Invalid move attempted: {coordinates}")
            return False

        """  if is_simulation:
            print(
                f"Simulating move: {coordinates} by {'Player' if player_move else 'AI'}"
            )
        else:
            print(
                f"Attempting move: {coordinates} by {'Player' if player_move else 'AI'}"
            )

        print(f"Available moves before: {self._open_vectors}") """
        player = "P" if player_move else "A"

        self._open_vectors.remove(coordinates)
        self._moves.append(coordinates)
        closed = self._checkboxes(coordinates, player)

        # print(f"Available moves after: {self._open_vectors}")
        # print(f"Move resulted in closing box: {closed}")

        return closed

    def undo_last_move(self):
        if self._moves:
            move = self._moves.pop()
            self._open_vectors.add(move)
            self._undo_move_on_boxes(move)

    def _undo_move_on_boxes(self, move):
        for i in range(self.m):
            for j in range(self.n):
                box = self._boxes[i][j]
                if move in box.lines:
                    self._undo_box_completion(box, move)

    def _undo_box_completion(self, box, move):
        if box.completed:
            self._adjust_scores(box)
            box.owner = None
        box.un_connect(move)

    def _adjust_scores(self, box):
        if box.owner == "P":
            self.player_score -= 1
        else:
            self.ai_score -= 1

    def has_moves(self):
        return bool(self._open_vectors)

    def get_available_moves(self):
        return self._open_vectors

    def _checkboxes(self, coordinates, player: str):
        closed = None
        for i in range(self.m):
            for j in range(self.n):
                box = self._boxes[i][j]
                if coordinates in box.lines:
                    box.connect(coordinates)
                if box.completed == True and box.owner == None:
                    box.owner = player
                    if player == "P":
                        self.player_score += 1
                    else:
                        self.ai_score += 1
                    closed = True
        return closed

    def copy(self):
        return deepcopy(self)

    def display_board(self):
        # Display player scores
        print(f"Player 1: {self.player_score}")
        print(f"Player AI: {self.ai_score}\n")

        for i in range(self.m):
            top_line, middle_line = self._generate_row_lines(i)
            print(top_line)
            print(middle_line)

        bottom_line = self._generate_bottom_line()
        print(bottom_line)
        print("")  # New line for spacing

    def _generate_row_lines(self, row):
        top_line = "   "  # Start with some spacing for alignment
        middle_line = "   "  # Line below to display vertical lines and boxes

        for j in range(self.n):
            top_line += self._generate_top_line_segment(j, row)
            middle_line += self._generate_middle_line_segment(j, row)

        # Last dot on the right end of the row
        top_line += "*"
        middle_line += "|" if ((self.n, row), (self.n, row + 1)) in self._moves else " "

        return top_line, middle_line

    def _generate_top_line_segment(self, col, row):
        segment = "*"
        if ((col, row), (col + 1, row)) in self._moves:
            segment += "---"
        else:
            segment += "   "
        return segment

    def _generate_middle_line_segment(self, col, row):
        segment = "| " if ((col, row), (col, row + 1)) in self._moves else "  "
        if self._boxes[col][row].completed:
            segment += f"{self._boxes[col][row].owner} "
        else:
            segment += "  "
        return segment

    def _generate_bottom_line(self):
        bottom_line = "   "
        for j in range(self.n):
            bottom_line += "*"
            if ((j, self.m), (j + 1, self.m)) in self._moves:
                bottom_line += "---"
            else:
                bottom_line += "   "
        bottom_line += "*"
        return bottom_line

    def _repr_pretty_(self, p, cycle):
        self.__display_single_box(p)

    def __display_single_box(self, p):
        for i in range(self.m):
            top_line, middle_line = self._generate_row_lines(i)
            p.text(top_line)
            p.break_()
            p.text(middle_line)
            p.break_()

        bottom_line = self._generate_bottom_line()
        p.text(bottom_line)
        p.break_()

    def validate_board_state(self):
        for i in range(self.m):
            for j in range(self.n):
                box = self._boxes[i][j]
                if box.completed:
                    for line in box.lines:
                        if line in self._open_vectors:
                            print(
                                f"Inconsistency found: Closed box at ({i}, {j}) has an open line: {line}"
                            )

    def print_board_summary(self):
        print(f"Player Score: {self.player_score}, AI Score: {self.ai_score}")
        print(f"Open vectors: {self._open_vectors}")
        print(f"Moves made: {self._moves}")
