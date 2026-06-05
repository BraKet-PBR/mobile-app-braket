import 'package:mobile_app_braket/data/datasources/api_service_base.dart';
import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/external_services/qkd_session_service.dart';
import 'package:mobile_app_braket/domain/models/dtos/join_session_dto.dart';
import 'package:mobile_app_braket/domain/models/dtos/other_session_user_response_dto.dart';
import 'package:mobile_app_braket/domain/models/dtos/qkd_session_response_dto.dart';

class QkdSessionServiceImpl extends APIServiceBase implements QkdSessionService{
  QkdSessionServiceImpl(super.dio, {super.tokenProvider});

  @override
  Future<APIResponse<OtherSessionUserResponseDto>> getOtherSessionUser(/*String sessionId*/) {
    return getAndDeserialize(
      "/api/qkdsessions/other_user",
      (json) => OtherSessionUserResponseDto.fromJson(json)
    );
  }

  @override
  Future<APIResponse<QkdSessionResponseDto>> joinSession(JoinSessionDto dto) {
    return postAndDeserialize(
      "/api/qkdsessions/join",
      dto.toJson(),
      (json) => QkdSessionResponseDto.fromJson(json)
    );
  }

  @override
  Future<APIResponse<QkdSessionResponseDto>> getCurrentSession() {
    return getAndDeserialize(
      "/api/qkdsessions/current",
      (json) => QkdSessionResponseDto.fromJson(json)
    );
  }

  
}
