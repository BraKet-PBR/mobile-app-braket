// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMessageDto _$SendMessageDtoFromJson(Map<String, dynamic> json) =>
    SendMessageDto(
      sessionId: json['session_id'] as String,
      ciphertext: json['ciphertext'] as String,
      messageNonce: json['message_nonce'] as String,
      algorithm: json['algorithm'] as String,
      mayoSignature: json['mayo_signature'] as String,
    );

Map<String, dynamic> _$SendMessageDtoToJson(SendMessageDto instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'ciphertext': instance.ciphertext,
      'message_nonce': instance.messageNonce,
      'algorithm': instance.algorithm,
      'mayo_signature': instance.mayoSignature,
    };
