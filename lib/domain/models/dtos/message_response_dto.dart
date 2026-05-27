import 'package:json_annotation/json_annotation.dart';

part 'message_response_dto.g.dart';

@JsonSerializable()
class MessageResponseDto {
  final String messageId;
  final String status;
  final String expiresAt;

  MessageResponseDto({
    required this.messageId,
    required this.status,
    required this.expiresAt,
  });

  factory MessageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageResponseDtoToJson(this);
}
