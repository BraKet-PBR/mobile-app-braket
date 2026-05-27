import 'package:json_annotation/json_annotation.dart';

part 'join_session_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class JoinSessionDto {
  final String keyHash;
  final String mayoKey;

  JoinSessionDto({
    required this.keyHash,
    required this.mayoKey,
  });

    factory JoinSessionDto.fromJson(Map<String, dynamic> json) =>
      _$JoinSessionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$JoinSessionDtoToJson(this);

}