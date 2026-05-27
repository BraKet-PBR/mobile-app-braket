import 'package:json_annotation/json_annotation.dart';

part 'other_session_user_response_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class OtherSessionUserResponseDto {
  final String userId;
  final String username;
  final String mayoKey;

  OtherSessionUserResponseDto({
    required this.userId,
    required this.username,
    required this.mayoKey,
  });

  factory OtherSessionUserResponseDto.fromJson(
      Map<String, dynamic> json) =>
      _$OtherSessionUserResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$OtherSessionUserResponseDtoToJson(this);


}