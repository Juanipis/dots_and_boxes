import 'package:grpc/grpc.dart';
import 'package:dots_and_boxes/src/generated/game.pbgrpc.dart';

class GameClientService {
  late ClientChannel channel;
  late GameServiceClient stub;

  GameClientService() {
    channel = ClientChannel(
      'localhost', // Ajusta esto según tu configuración de red
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    stub = GameServiceClient(channel);
  }

  Future<MoveResponse> makeMove(GameMove move) async {
    return await stub.makeMove(move);
  }

  Future<MoveResponse> initializeGame(int rows, int cols, int level,
      GameMove firstMove, bool alfaBetaPrunning) async {
    final gameSetup = GameSetup(
      rows: rows,
      cols: cols,
      level: level,
      firstMove: firstMove,
      alfaBetaPrunning: alfaBetaPrunning,
    );
    return await stub.startGame(gameSetup);
  }

  void close() {
    channel.shutdown();
  }
}
