import 'package:mobile_app_braket/data/datasources/api_service_base.dart';
import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/external_services/qkd_session_service.dart';
import 'package:mobile_app_braket/domain/models/create_session_dto.dart';
import 'package:mobile_app_braket/domain/models/other_session_user_response.dart';
import 'package:mobile_app_braket/domain/models/qkd_session_response.dart';

class QkdSessionServiceImpl extends APIServiceBase implements QkdSessionService{
  QkdSessionServiceImpl(super.dio, {super.tokenProvider});

  @override
  Future<APIResponse<QkdSessionResponse>> createSession(CreateSessionDto dto) {
    return postAndDeserialize(
      "/api/qkdsessions",
      dto.toJson(),
      (json) => QkdSessionResponse.fromJson(json)
    );
  }

  @override
  Future<APIResponse<OtherSessionUserResponse>> getOtherSessionUser(/*String sessionId*/) {
    return getAndDeserialize(
      "/api/other_session_user",
      (json) => OtherSessionUserResponse.fromJson(json)
    );
  }

  
}