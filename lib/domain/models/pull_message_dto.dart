import 'package:json_annotation/json_annotation.dart';

part 'pull_message_dto.g.dart';

@JsonSerializable()
class PullMessageDto {
  final String sessionId;

  PullMessageDto({
    required this.sessionId,
  });

  factory PullMessageDto.fromJson(Map<String, dynamic> json) =>
      _$PullMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PullMessageDtoToJson(this);
}