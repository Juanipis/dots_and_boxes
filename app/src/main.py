from concurrent import futures
import grpc
import game_pb2
import game_pb2_grpc
from utils.game_manager import GameManager


class GameService(game_pb2_grpc.GameServiceServicer):
    def __init__(self):
        self.games = {}

    def StartGame(self, request, context):
        game_id = context.peer()
        game = GameManager(request.rows, request.cols, request.level)
        self.games[game_id] = game

        # Ejecutar el primer movimiento
        origin = (request.first_move.origin_x, request.first_move.origin_y)
        dest = (request.first_move.dest_x, request.first_move.dest_y)
        move_result = game.get_move(origin, dest)

        if move_result[1] is not None:
            status = "game_over"
            message = move_result[1]
        else:
            status = "continue"
            message = f"Movimiento de la máquina: {move_result[0]}"

        next_move = (
            game_pb2.GameMove(
                origin_x=move_result[0][0][0],
                origin_y=move_result[0][0][1],
                dest_x=move_result[0][1][0],
                dest_y=move_result[0][1][1],
            )
            if move_result[0]
            else None
        )

        return game_pb2.MoveResponse(
            status=status, message=message, next_move=next_move
        )

    def MakeMove(self, request, context):
        game_id = context.peer()
        game = self.games.get(game_id)

        origin = (request.origin_x, request.origin_y)
        dest = (request.dest_x, request.dest_y)
        move_result = game.get_move(origin, dest)

        if move_result[1] is not None:
            status = "game_over"
            message = move_result[1]
        else:
            status = "continue"
            message = "Movimiento de la máquina: {}".format(move_result[0])

        next_move = (
            game_pb2.GameMove(
                origin_x=move_result[0][0][0],
                origin_y=move_result[0][0][1],
                dest_x=move_result[0][1][0],
                dest_y=move_result[0][1][1],
            )
            if move_result[0]
            else None
        )

        return game_pb2.MoveResponse(
            status=status, message=message, next_move=next_move
        )


def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    game_pb2_grpc.add_GameServiceServicer_to_server(GameService(), server)
    server.add_insecure_port("[::]:50051")
    server.start()
    print("Server started at port 50051 on localhost")
    server.wait_for_termination()


if __name__ == "__main__":
    serve()
