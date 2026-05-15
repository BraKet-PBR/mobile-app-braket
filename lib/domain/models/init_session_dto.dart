import 'package:json_annotation/json_annotation.dart';

part 'init_session_dto.g.dart';

@JsonSerializable()
class InitSessionDto {
  final String keyHash;
  final String sessionNonce;

  InitSessionDto({
    required this.keyHash,
    required this.sessionNonce,
  });

    factory InitSessionDto.fromJson(Map<String, dynamic> json) =>
      _$InitSessionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InitSessionDtoToJson(this);

}