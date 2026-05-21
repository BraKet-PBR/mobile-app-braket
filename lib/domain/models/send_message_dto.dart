import 'package:json_annotation/json_annotation.dart';

part 'send_message_dto.g.dart';

@JsonSerializable()
class SendMessageDto {
  final String sessionId;
  final String ciphertext;
  final String messageNonce;
  final String algorithm;
  final String mayoSignature;

  SendMessageDto({
    required this.sessionId,
    required this.ciphertext,
    required this.messageNonce,
    required this.algorithm,
    required this.mayoSignature,
  });

  factory SendMessageDto.fromJson(Map<String, dynamic> json) =>
      _$SendMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SendMessageDtoToJson(this);
}
