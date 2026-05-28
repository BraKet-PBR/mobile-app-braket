// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qkd_simulator_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QkdSimulatorResponseDto _$QkdSimulatorResponseDtoFromJson(
  Map<String, dynamic> json,
) => QkdSimulatorResponseDto(
  keyMaterial: json['key_material'] as String,
  status: json['status'] as String?,
  stats: json['stats'],
  failureReason: json['failure_reason'] as String?,
);

Map<String, dynamic> _$QkdSimulatorResponseDtoToJson(
  QkdSimulatorResponseDto instance,
) => <String, dynamic>{
  'key_material': instance.keyMaterial,
  'status': instance.status,
  'stats': instance.stats,
  'failure_reason': instance.failureReason,
};
