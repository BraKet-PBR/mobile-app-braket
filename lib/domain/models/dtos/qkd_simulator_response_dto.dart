import 'package:json_annotation/json_annotation.dart';

part 'qkd_simulator_response_dto.g.dart';

// TODO: tu jeszcze nie wiem jakie typy danych zwraca api
@JsonSerializable(fieldRename: FieldRename.snake)
class QkdSimulatorResponseDto{
  final String keyMaterial;
  final String status;
  final String stats;
  final String failureReason;

  QkdSimulatorResponseDto({
    required this.keyMaterial,
    required this.status,
    required this.stats,
    required this.failureReason,
  });

  factory QkdSimulatorResponseDto.fromJson(Map<String, dynamic> json) =>
      _$QkdSimulatorResponseDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$QkdSimulatorResponseDtoToJson(this);
}