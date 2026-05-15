// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinSessionDto _$JoinSessionDtoFromJson(Map<String, dynamic> json) =>
    JoinSessionDto(
      keyHash: json['keyHash'] as String,
      sessionNonce: json['sessionNonce'] as String,
    );

Map<String, dynamic> _$JoinSessionDtoToJson(JoinSessionDto instance) =>
    <String, dynamic>{
      'keyHash': instance.keyHash,
      'sessionNonce': instance.sessionNonce,
    };
