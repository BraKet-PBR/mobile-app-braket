// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_message_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullMessageResponseDto _$PullMessageResponseDtoFromJson(
  Map<String, dynamic> json,
) => PullMessageResponseDto(
  messageId: json['message_id'] as String,
  ciphertext: json['ciphertext'] as String,
  messageNonce: json['message_nonce'] as String,
  algorithm: json['algorithm'] as String,
  createdAt: json['created_at'] as String,
  mayoSignature: json['mayo_signature'] as String,
);

Map<String, dynamic> _$PullMessageResponseDtoToJson(
  PullMessageResponseDto instance,
) => <String, dynamic>{
  'message_id': instance.messageId,
  'ciphertext': instance.ciphertext,
  'message_nonce': instance.messageNonce,
  'algorithm': instance.algorithm,
  'created_at': instance.createdAt,
  'mayo_signature': instance.mayoSignature,
};
