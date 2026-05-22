import 'package:json_annotation/json_annotation.dart';

part 'message_status_response.g.dart';

@JsonSerializable()
class MessageStatusResponse {
  final String messageId;
  final String status;
  final String deliveredAt;

  MessageStatusResponse({
    required this.messageId,
    required this.status,
    required this.deliveredAt,
  });

  factory MessageStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MessageStatusResponseToJson(this);
}