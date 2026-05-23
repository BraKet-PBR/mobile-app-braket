// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qkd_session_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QkdSessionResponse _$QkdSessionResponseFromJson(Map<String, dynamic> json) =>
    QkdSessionResponse(
      sessionId: json['sessionId'] as String,
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$QkdSessionResponseToJson(QkdSessionResponse instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'status': instance.status,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
