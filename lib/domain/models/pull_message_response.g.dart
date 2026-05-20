// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_message_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullMessageResponse _$PullMessageResponseFromJson(Map<String, dynamic> json) =>
    PullMessageResponse(
      messageId: json['messageId'] as String,
      ciphertext: json['ciphertext'] as String,
      messageNonce: json['message_nonce'] as String,
      algorithm: json['algorithm'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$PullMessageResponseToJson(
  PullMessageResponse instance,
) => <String, dynamic>{
  'messageId': instance.messageId,
  'ciphertext': instance.ciphertext,
  'message_nonce': instance.messageNonce,
  'algorithm': instance.algorithm,
  'createdAt': instance.createdAt,
};
