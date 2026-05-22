import 'package:mobile_app_braket/data/datasources/api_service_base.dart';
import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/external_services/qkd_session_service.dart';
import 'package:mobile_app_braket/domain/models/join_session_dto.dart';
import 'package:mobile_app_braket/domain/models/other_session_user_response.dart';
import 'package:mobile_app_braket/domain/models/qkd_session_response.dart';

class QkdSessionServiceImpl extends APIServiceBase implements QkdSessionService{
  QkdSessionServiceImpl(super.dio, {super.tokenProvider});

  @override
  Future<APIResponse<OtherSessionUserResponse>> getOtherSessionUser(/*String sessionId*/) {
    return getAndDeserialize(
      "/api/qkdsessions/other_user",
      (json) => OtherSessionUserResponse.fromJson(json)
    );
  }

  @override
  Future<APIResponse<QkdSessionResponse>> joinSession(JoinSessionDto dto) {
    return postAndDeserialize(
      "/api/qkdsessions/join",
      dto.toJson(),
      (json) => QkdSessionResponse.fromJson(json)
    );
  }

  
}