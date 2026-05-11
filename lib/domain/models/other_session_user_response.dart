import 'package:json_annotation/json_annotation.dart';

part 'other_session_user_response.g.dart';

@JsonSerializable()
class OtherSessionUserResponse {
  final String userId;

  OtherSessionUserResponse({
    required this.userId,
  });

  factory OtherSessionUserResponse.fromJson(
      Map<String, dynamic> json) =>
      _$OtherSessionUserResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$OtherSessionUserResponseToJson(this);


}