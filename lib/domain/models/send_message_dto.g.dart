// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMessageDto _$SendMessageDtoFromJson(Map<String, dynamic> json) =>
    SendMessageDto(
      sessionId: json['sessionId'] as String,
      ciphertext: json['ciphertext'] as String,
      messageNonce: json['messageNonce'] as String,
      algorithm: json['algorithm'] as String,
    );

Map<String, dynamic> _$SendMessageDtoToJson(SendMessageDto instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'ciphertext': instance.ciphertext,
      'messageNonce': instance.messageNonce,
      'algorithm': instance.algorithm,
    };
