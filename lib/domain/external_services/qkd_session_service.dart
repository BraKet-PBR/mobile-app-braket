import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/models/init_session_dto.dart';
import 'package:mobile_app_braket/domain/models/join_session_dto.dart';
import 'package:mobile_app_braket/domain/models/other_session_user_response.dart';
import 'package:mobile_app_braket/domain/models/qkd_session_response.dart';

abstract class QkdSessionService {

  Future<APIResponse<QkdSessionResponse>> initSession(InitSessionDto dto);
  Future<APIResponse<QkdSessionResponse>> joinSession(JoinSessionDto dto);
  Future<APIResponse<OtherSessionUserResponse>> getOtherSessionUser(/*String sessionId*/);

}