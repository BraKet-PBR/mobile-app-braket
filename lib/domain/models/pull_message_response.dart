import 'package:json_annotation/json_annotation.dart';

part 'pull_message_response.g.dart';

@JsonSerializable()
class PullMessageResponse {
  final String messageId;
  final String ciphertext;
  final String messageNonce;
  final String algorithm;
  final String createdAt;
  final String mayoSignature;

  PullMessageResponse({
    required this.messageId,
    required this.ciphertext,
    required this.messageNonce,
    required this.algorithm,
    required this.createdAt,
    required this.mayoSignature,
  });

  factory PullMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$PullMessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PullMessageResponseToJson(this);
}