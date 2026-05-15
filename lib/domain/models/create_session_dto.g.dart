// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSessionDto _$CreateSessionDtoFromJson(Map<String, dynamic> json) =>
    CreateSessionDto(
      userId: json['userId'] as String,
      keyHash: json['keyHash'] as String,
    );

Map<String, dynamic> _$CreateSessionDtoToJson(CreateSessionDto instance) =>
    <String, dynamic>{'userId': instance.userId, 'keyHash': instance.keyHash};
