import 'package:json_annotation/json_annotation.dart';

part 'pull_message_response_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PullMessageResponseDto {
  final String messageId;
  final String ciphertext;
  final String messageNonce;
  final String algorithm;
  final String createdAt;
  final String mayoSignature;

  PullMessageResponseDto({
    required this.messageId,
    required this.ciphertext,
    required this.messageNonce,
    required this.algorithm,
    required this.createdAt,
    required this.mayoSignature,
  });

  factory PullMessageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PullMessageResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PullMessageResponseDtoToJson(this);
}