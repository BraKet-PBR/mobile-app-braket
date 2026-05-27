// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinSessionDto _$JoinSessionDtoFromJson(Map<String, dynamic> json) =>
    JoinSessionDto(
      keyHash: json['key_hash'] as String,
      mayoKey: json['mayo_key'] as String,
    );

Map<String, dynamic> _$JoinSessionDtoToJson(JoinSessionDto instance) =>
    <String, dynamic>{
      'key_hash': instance.keyHash,
      'mayo_key': instance.mayoKey,
    };
