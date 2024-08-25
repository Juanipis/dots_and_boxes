//
//  Generated code. Do not modify.
//  source: game.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use gameSetupDescriptor instead')
const GameSetup$json = {
  '1': 'GameSetup',
  '2': [
    {'1': 'rows', '3': 1, '4': 1, '5': 5, '10': 'rows'},
    {'1': 'cols', '3': 2, '4': 1, '5': 5, '10': 'cols'},
    {'1': 'level', '3': 3, '4': 1, '5': 5, '10': 'level'},
    {'1': 'first_move', '3': 4, '4': 1, '5': 11, '6': '.game.GameMove', '10': 'firstMove'},
  ],
};

/// Descriptor for `GameSetup`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gameSetupDescriptor = $convert.base64Decode(
    'CglHYW1lU2V0dXASEgoEcm93cxgBIAEoBVIEcm93cxISCgRjb2xzGAIgASgFUgRjb2xzEhQKBW'
    'xldmVsGAMgASgFUgVsZXZlbBItCgpmaXJzdF9tb3ZlGAQgASgLMg4uZ2FtZS5HYW1lTW92ZVIJ'
    'Zmlyc3RNb3Zl');

@$core.Deprecated('Use gameMoveDescriptor instead')
const GameMove$json = {
  '1': 'GameMove',
  '2': [
    {'1': 'origin_x', '3': 1, '4': 1, '5': 5, '10': 'originX'},
    {'1': 'origin_y', '3': 2, '4': 1, '5': 5, '10': 'originY'},
    {'1': 'dest_x', '3': 3, '4': 1, '5': 5, '10': 'destX'},
    {'1': 'dest_y', '3': 4, '4': 1, '5': 5, '10': 'destY'},
  ],
};

/// Descriptor for `GameMove`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gameMoveDescriptor = $convert.base64Decode(
    'CghHYW1lTW92ZRIZCghvcmlnaW5feBgBIAEoBVIHb3JpZ2luWBIZCghvcmlnaW5feRgCIAEoBV'
    'IHb3JpZ2luWRIVCgZkZXN0X3gYAyABKAVSBWRlc3RYEhUKBmRlc3RfeRgEIAEoBVIFZGVzdFk=');

@$core.Deprecated('Use moveResponseDescriptor instead')
const MoveResponse$json = {
  '1': 'MoveResponse',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'next_move', '3': 3, '4': 1, '5': 11, '6': '.game.GameMove', '10': 'nextMove'},
  ],
};

/// Descriptor for `MoveResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List moveResponseDescriptor = $convert.base64Decode(
    'CgxNb3ZlUmVzcG9uc2USFgoGc3RhdHVzGAEgASgJUgZzdGF0dXMSGAoHbWVzc2FnZRgCIAEoCV'
    'IHbWVzc2FnZRIrCgluZXh0X21vdmUYAyABKAsyDi5nYW1lLkdhbWVNb3ZlUghuZXh0TW92ZQ==');

