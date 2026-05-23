import 'package:json_annotation/json_annotation.dart';

part 'qkd_session_response.g.dart';

@JsonSerializable()
class QkdSessionResponse {
  final String sessionId;
  final String status;
  final DateTime expiresAt;

  QkdSessionResponse({
    required this.sessionId,
    required this.status,
    required this.expiresAt,
  });


  factory QkdSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$QkdSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QkdSessionResponseToJson(this);

}