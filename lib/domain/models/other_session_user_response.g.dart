// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other_session_user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtherSessionUserResponse _$OtherSessionUserResponseFromJson(
  Map<String, dynamic> json,
) => OtherSessionUserResponse(
  userId: json['userId'] as String,
  username: json['username'] as String,
  mayoKey: json['mayoKey'] as String,
);

Map<String, dynamic> _$OtherSessionUserResponseToJson(
  OtherSessionUserResponse instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'mayoKey': instance.mayoKey,
};
