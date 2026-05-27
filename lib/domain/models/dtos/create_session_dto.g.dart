// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSessionDto _$CreateSessionDtoFromJson(Map<String, dynamic> json) =>
    CreateSessionDto(
      userId: json['user_id'] as String,
      keyHash: json['key_hash'] as String,
    );

Map<String, dynamic> _$CreateSessionDtoToJson(CreateSessionDto instance) =>
    <String, dynamic>{'user_id': instance.userId, 'key_hash': instance.keyHash};
