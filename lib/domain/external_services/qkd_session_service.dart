import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/models/dtos/join_session_dto.dart';
import 'package:mobile_app_braket/domain/models/dtos/other_session_user_response_dto.dart';
import 'package:mobile_app_braket/domain/models/dtos/qkd_session_response_dto.dart';

abstract class QkdSessionService {

  Future<APIResponse<QkdSessionResponseDto>> joinSession(JoinSessionDto dto);
  Future<APIResponse<OtherSessionUserResponseDto>> getOtherSessionUser(/*String sessionId*/);
  // Jednak raczej będzie tak że backend po jwt sprawdzi sobie jaki user pyta i czy w sesji do której on należy jest inny user
  // Więc brak potrzeby przesyłania sessionId

}