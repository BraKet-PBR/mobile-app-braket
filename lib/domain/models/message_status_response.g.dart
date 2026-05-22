// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageStatusResponse _$MessageStatusResponseFromJson(
  Map<String, dynamic> json,
) => MessageStatusResponse(
  messageId: json['messageId'] as String,
  status: json['status'] as String,
  deliveredAt: json['deliveredAt'] as String,
);

Map<String, dynamic> _$MessageStatusResponseToJson(
  MessageStatusResponse instance,
) => <String, dynamic>{
  'messageId': instance.messageId,
  'status': instance.status,
  'deliveredAt': instance.deliveredAt,
};
