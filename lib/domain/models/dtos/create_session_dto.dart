import 'package:json_annotation/json_annotation.dart';

part 'create_session_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateSessionDto {
  final String userId;
  final String keyHash;

  CreateSessionDto({
    required this.userId,
    required this.keyHash,
  });

    factory CreateSessionDto.fromJson(Map<String, dynamic> json) =>
      _$CreateSessionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSessionDtoToJson(this);

}