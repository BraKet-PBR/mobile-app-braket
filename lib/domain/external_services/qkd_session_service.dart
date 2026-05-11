import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/models/create_session_dto.dart';
import 'package:mobile_app_braket/domain/models/other_session_user_response.dart';
import 'package:mobile_app_braket/domain/models/qkd_session_response.dart';

abstract class QkdSessionService {

  Future<APIResponse<QkdSessionResponse>> createSession(CreateSessionDto dto);
  Future<APIResponse<OtherSessionUserResponse>> getOtherSessionUser(/*String sessionId*/);

}