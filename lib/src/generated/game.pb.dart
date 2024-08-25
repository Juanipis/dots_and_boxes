//
//  Generated code. Do not modify.
//  source: game.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Definición de mensajes
class GameSetup extends $pb.GeneratedMessage {
  factory GameSetup({
    $core.int? rows,
    $core.int? cols,
    $core.int? level,
    GameMove? firstMove,
  }) {
    final $result = create();
    if (rows != null) {
      $result.rows = rows;
    }
    if (cols != null) {
      $result.cols = cols;
    }
    if (level != null) {
      $result.level = level;
    }
    if (firstMove != null) {
      $result.firstMove = firstMove;
    }
    return $result;
  }
  GameSetup._() : super();
  factory GameSetup.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GameSetup.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GameSetup', package: const $pb.PackageName(_omitMessageNames ? '' : 'game'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'rows', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'cols', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'level', $pb.PbFieldType.O3)
    ..aOM<GameMove>(4, _omitFieldNames ? '' : 'firstMove', subBuilder: GameMove.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GameSetup clone() => GameSetup()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GameSetup copyWith(void Function(GameSetup) updates) => super.copyWith((message) => updates(message as GameSetup)) as GameSetup;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GameSetup create() => GameSetup._();
  GameSetup createEmptyInstance() => create();
  static $pb.PbList<GameSetup> createRepeated() => $pb.PbList<GameSetup>();
  @$core.pragma('dart2js:noInline')
  static GameSetup getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GameSetup>(create);
  static GameSetup? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get rows => $_getIZ(0);
  @$pb.TagNumber(1)
  set rows($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRows() => $_has(0);
  @$pb.TagNumber(1)
  void clearRows() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get cols => $_getIZ(1);
  @$pb.TagNumber(2)
  set cols($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCols() => $_has(1);
  @$pb.TagNumber(2)
  void clearCols() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get level => $_getIZ(2);
  @$pb.TagNumber(3)
  set level($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLevel() => clearField(3);

  @$pb.TagNumber(4)
  GameMove get firstMove => $_getN(3);
  @$pb.TagNumber(4)
  set firstMove(GameMove v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasFirstMove() => $_has(3);
  @$pb.TagNumber(4)
  void clearFirstMove() => clearField(4);
  @$pb.TagNumber(4)
  GameMove ensureFirstMove() => $_ensure(3);
}

class GameMove extends $pb.GeneratedMessage {
  factory GameMove({
    $core.int? originX,
    $core.int? originY,
    $core.int? destX,
    $core.int? destY,
  }) {
    final $result = create();
    if (originX != null) {
      $result.originX = originX;
    }
    if (originY != null) {
      $result.originY = originY;
    }
    if (destX != null) {
      $result.destX = destX;
    }
    if (destY != null) {
      $result.destY = destY;
    }
    return $result;
  }
  GameMove._() : super();
  factory GameMove.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GameMove.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GameMove', package: const $pb.PackageName(_omitMessageNames ? '' : 'game'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'originX', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'originY', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'destX', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'destY', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GameMove clone() => GameMove()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GameMove copyWith(void Function(GameMove) updates) => super.copyWith((message) => updates(message as GameMove)) as GameMove;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GameMove create() => GameMove._();
  GameMove createEmptyInstance() => create();
  static $pb.PbList<GameMove> createRepeated() => $pb.PbList<GameMove>();
  @$core.pragma('dart2js:noInline')
  static GameMove getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GameMove>(create);
  static GameMove? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get originX => $_getIZ(0);
  @$pb.TagNumber(1)
  set originX($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOriginX() => $_has(0);
  @$pb.TagNumber(1)
  void clearOriginX() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get originY => $_getIZ(1);
  @$pb.TagNumber(2)
  set originY($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOriginY() => $_has(1);
  @$pb.TagNumber(2)
  void clearOriginY() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get destX => $_getIZ(2);
  @$pb.TagNumber(3)
  set destX($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDestX() => $_has(2);
  @$pb.TagNumber(3)
  void clearDestX() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get destY => $_getIZ(3);
  @$pb.TagNumber(4)
  set destY($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDestY() => $_has(3);
  @$pb.TagNumber(4)
  void clearDestY() => clearField(4);
}

class MoveResponse extends $pb.GeneratedMessage {
  factory MoveResponse({
    $core.String? status,
    $core.String? message,
    GameMove? nextMove,
  }) {
    final $result = create();
    if (status != null) {
      $result.status = status;
    }
    if (message != null) {
      $result.message = message;
    }
    if (nextMove != null) {
      $result.nextMove = nextMove;
    }
    return $result;
  }
  MoveResponse._() : super();
  factory MoveResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MoveResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MoveResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'game'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<GameMove>(3, _omitFieldNames ? '' : 'nextMove', subBuilder: GameMove.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MoveResponse clone() => MoveResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MoveResponse copyWith(void Function(MoveResponse) updates) => super.copyWith((message) => updates(message as MoveResponse)) as MoveResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MoveResponse create() => MoveResponse._();
  MoveResponse createEmptyInstance() => create();
  static $pb.PbList<MoveResponse> createRepeated() => $pb.PbList<MoveResponse>();
  @$core.pragma('dart2js:noInline')
  static MoveResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MoveResponse>(create);
  static MoveResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  @$pb.TagNumber(3)
  GameMove get nextMove => $_getN(2);
  @$pb.TagNumber(3)
  set nextMove(GameMove v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasNextMove() => $_has(2);
  @$pb.TagNumber(3)
  void clearNextMove() => clearField(3);
  @$pb.TagNumber(3)
  GameMove ensureNextMove() => $_ensure(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
