import 'package:json_annotation/json_annotation.dart';

part 'join_session_dto.g.dart';

@JsonSerializable()
class JoinSessionDto {
  final String keyHash;
  final String sessionNonce;

  JoinSessionDto({
    required this.keyHash,
    required this.sessionNonce,
  });

    factory JoinSessionDto.fromJson(Map<String, dynamic> json) =>
      _$JoinSessionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$JoinSessionDtoToJson(this);

}