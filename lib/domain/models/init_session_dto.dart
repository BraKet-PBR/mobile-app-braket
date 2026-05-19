import 'package:json_annotation/json_annotation.dart';

part 'init_session_dto.g.dart';

@JsonSerializable()
class InitSessionDto {
  final String keyHash;

  InitSessionDto({
    required this.keyHash,
  });

    factory InitSessionDto.fromJson(Map<String, dynamic> json) =>
      _$InitSessionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InitSessionDtoToJson(this);

}