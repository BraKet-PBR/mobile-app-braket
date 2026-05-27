// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qkd_session_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QkdSessionResponseDto _$QkdSessionResponseDtoFromJson(
  Map<String, dynamic> json,
) => QkdSessionResponseDto(
  sessionId: json['session_id'] as String,
  status: json['status'] as String,
  expiresAt: DateTime.parse(json['expires_at'] as String),
);

Map<String, dynamic> _$QkdSessionResponseDtoToJson(
  QkdSessionResponseDto instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'status': instance.status,
  'expires_at': instance.expiresAt.toIso8601String(),
};
