import 'package:json_annotation/json_annotation.dart';

part 'message_status_response_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MessageStatusResponseDto {
  final String messageId;
  final String status;
  final String deliveredAt;

  MessageStatusResponseDto({
    required this.messageId,
    required this.status,
    required this.deliveredAt,
  });

  factory MessageStatusResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MessageStatusResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageStatusResponseDtoToJson(this);
}