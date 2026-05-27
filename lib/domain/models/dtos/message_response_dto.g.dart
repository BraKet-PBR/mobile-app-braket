// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageResponseDto _$MessageResponseDtoFromJson(Map<String, dynamic> json) =>
    MessageResponseDto(
      messageId: json['messageId'] as String,
      status: json['status'] as String,
      expiresAt: json['expiresAt'] as String,
    );

Map<String, dynamic> _$MessageResponseDtoToJson(MessageResponseDto instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'status': instance.status,
      'expiresAt': instance.expiresAt,
    };
