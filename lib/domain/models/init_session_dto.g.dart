// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'init_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InitSessionDto _$InitSessionDtoFromJson(Map<String, dynamic> json) =>
    InitSessionDto(
      keyHash: json['keyHash'] as String,
      sessionNonce: json['sessionNonce'] as String,
    );

Map<String, dynamic> _$InitSessionDtoToJson(InitSessionDto instance) =>
    <String, dynamic>{
      'keyHash': instance.keyHash,
      'sessionNonce': instance.sessionNonce,
    };
