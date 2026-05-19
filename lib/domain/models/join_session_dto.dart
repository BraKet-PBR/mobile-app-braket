import 'package:json_annotation/json_annotation.dart';

part 'join_session_dto.g.dart';

@JsonSerializable()
class JoinSessionDto {
  final String keyHash;

  JoinSessionDto({
    required this.keyHash,
  });

    factory JoinSessionDto.fromJson(Map<String, dynamic> json) =>
      _$JoinSessionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$JoinSessionDtoToJson(this);

}