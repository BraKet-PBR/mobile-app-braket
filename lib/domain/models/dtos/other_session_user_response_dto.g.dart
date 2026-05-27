// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other_session_user_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtherSessionUserResponseDto _$OtherSessionUserResponseDtoFromJson(
  Map<String, dynamic> json,
) => OtherSessionUserResponseDto(
  userId: json['user_id'] as String,
  username: json['username'] as String,
  mayoKey: json['mayo_key'] as String,
);

Map<String, dynamic> _$OtherSessionUserResponseDtoToJson(
  OtherSessionUserResponseDto instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'username': instance.username,
  'mayo_key': instance.mayoKey,
};
