from utils2.game_manager import GameManager
from concurrent import futures
import grpc
import game_pb2
import game_pb2_grpc
from logzero import logger

""" game_min = GameManager(3, 3, 3)
move = game_min.play(((0, 0), (0, 1)))
print(move)

# mostramos el tablero
game_min._board.display_board()

print("-------------")


# Hago un movimiento
move = game_min.play(((0, 0), (1, 0)))
print(move)


# mostramos el tablero
game_min._board.display_board()

print("-------------")

# Hago un movimiento
move = game_min.play(((1, 0), (1, 1)))
print(move)


# mostramos el tablero
game_min._board.display_board()

print("-------------")
 """


class GameService(game_pb2_grpc.GameServiceServicer):
    def __init__(self):
        self.games = {}

    def StartGame(self, request, context):
        # Revisar si el juego ya existe, si es así, se elimina

        if context.peer() in self.games:
            logger.info(f"Juego {context.peer()} ya existe, se eliminará")
            del self.games[context.peer()]
        else:
            logger.info(f"Juego {context.peer()} creado")

        game_id = context.peer()
        mode = "minimax"
        if request.alfa_beta_prunning:
            mode = "alphabeta"
        game = GameManager(request.rows, request.cols, request.level, mode)
        logger.info(
            f"Juego {game_id} creado con {request.rows} filas y {request.cols} columnas"
        )
        logger.info(f"Juego {game_id} creado con nivel {request.level}")
        logger.info(f"Juego {game_id} creado con modo {mode}")
        self.games[game_id] = game

        # Ejecutar el primer movimiento
        origin = (request.first_move.origin_x, request.first_move.origin_y)
        dest = (request.first_move.dest_x, request.first_move.dest_y)
        ia_moves = game.play((origin, dest))
        print(f"Tablero del juego {game_id}")
        game._board.display_board()
        print("-------------")

        next_moves = []
        print("Movimientos de la IA:")
        for i in ia_moves:
            print(f"    Movimiento de la máquina: {i}")
            next_moves.append(
                game_pb2.GameMove(
                    origin_x=i[0][0],
                    origin_y=i[0][1],
                    dest_x=i[1][0],
                    dest_y=i[1][1],
                )
            )

        return game_pb2.MoveResponse(
            status="continue", message="Akiladooos", next_move=next_moves
        )

    def MakeMove(self, request, context):
        game_id = context.peer()
        game: GameManager = self.games.get(game_id)

        origin = (request.origin_x, request.origin_y)
        dest = (request.dest_x, request.dest_y)
        ia_moves = game.play((origin, dest))

        print(f"Tablero del juego {game_id}")
        game._board.display_board()
        print("-------------")
        next_moves = []
        if ia_moves is not None:
            for i in ia_moves:
                print(f"    Movimiento de la máquina: {i}")
                next_moves.append(
                    game_pb2.GameMove(
                        origin_x=i[0][0],
                        origin_y=i[0][1],
                        dest_x=i[1][0],
                        dest_y=i[1][1],
                    )
                )

        return game_pb2.MoveResponse(
            status="continue",
            message="Hoy me desperte con ganas de",
            next_move=next_moves,
        )


def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    game_pb2_grpc.add_GameServiceServicer_to_server(GameService(), server)
    server.add_insecure_port("[::]:50051")
    server.start()
    logger.info("Server started at port 50051 on localhost")
    server.wait_for_termination()


if __name__ == "__main__":
    serve()
