import 'package:json_annotation/json_annotation.dart';

part 'qkd_session_response_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class QkdSessionResponseDto {
  final String sessionId;
  final String status;
  final DateTime expiresAt;

  QkdSessionResponseDto({
    required this.sessionId,
    required this.status,
    required this.expiresAt,
  });


  factory QkdSessionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$QkdSessionResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QkdSessionResponseDtoToJson(this);

}