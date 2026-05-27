// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_status_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageStatusResponseDto _$MessageStatusResponseDtoFromJson(
  Map<String, dynamic> json,
) => MessageStatusResponseDto(
  messageId: json['message_id'] as String,
  status: json['status'] as String,
  deliveredAt: json['delivered_at'] as String,
);

Map<String, dynamic> _$MessageStatusResponseDtoToJson(
  MessageStatusResponseDto instance,
) => <String, dynamic>{
  'message_id': instance.messageId,
  'status': instance.status,
  'delivered_at': instance.deliveredAt,
};
