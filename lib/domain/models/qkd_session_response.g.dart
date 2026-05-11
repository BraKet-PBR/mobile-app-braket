// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qkd_session_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QkdSessionResponse _$QkdSessionResponseFromJson(Map<String, dynamic> json) =>
    QkdSessionResponse(
      sessionId: json['sessionId'] as String,
      expiresAt: json['expiresAt'] as String,
    );

Map<String, dynamic> _$QkdSessionResponseToJson(QkdSessionResponse instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'expiresAt': instance.expiresAt,
    };
