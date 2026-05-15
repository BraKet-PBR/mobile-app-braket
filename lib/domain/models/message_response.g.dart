// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      messageId: json['messageId'] as String,
      status: json['status'] as String,
      expiresAt: json['expiresAt'] as String,
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'status': instance.status,
      'expiresAt': instance.expiresAt,
    };
