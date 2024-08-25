//
//  Generated code. Do not modify.
//  source: game.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'game.pb.dart' as $0;

export 'game.pb.dart';

@$pb.GrpcServiceName('game.GameService')
class GameServiceClient extends $grpc.Client {
  static final _$startGame = $grpc.ClientMethod<$0.GameSetup, $0.MoveResponse>(
      '/game.GameService/StartGame',
      ($0.GameSetup value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.MoveResponse.fromBuffer(value));
  static final _$makeMove = $grpc.ClientMethod<$0.GameMove, $0.MoveResponse>(
      '/game.GameService/MakeMove',
      ($0.GameMove value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.MoveResponse.fromBuffer(value));

  GameServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.MoveResponse> startGame($0.GameSetup request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$startGame, request, options: options);
  }

  $grpc.ResponseFuture<$0.MoveResponse> makeMove($0.GameMove request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$makeMove, request, options: options);
  }
}

@$pb.GrpcServiceName('game.GameService')
abstract class GameServiceBase extends $grpc.Service {
  $core.String get $name => 'game.GameService';

  GameServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GameSetup, $0.MoveResponse>(
        'StartGame',
        startGame_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GameSetup.fromBuffer(value),
        ($0.MoveResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GameMove, $0.MoveResponse>(
        'MakeMove',
        makeMove_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GameMove.fromBuffer(value),
        ($0.MoveResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.MoveResponse> startGame_Pre($grpc.ServiceCall call, $async.Future<$0.GameSetup> request) async {
    return startGame(call, await request);
  }

  $async.Future<$0.MoveResponse> makeMove_Pre($grpc.ServiceCall call, $async.Future<$0.GameMove> request) async {
    return makeMove(call, await request);
  }

  $async.Future<$0.MoveResponse> startGame($grpc.ServiceCall call, $0.GameSetup request);
  $async.Future<$0.MoveResponse> makeMove($grpc.ServiceCall call, $0.GameMove request);
}
