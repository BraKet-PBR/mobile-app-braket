import 'package:mobile_app_braket/domain/models/login_dto.dart';
import 'api_response.dart';

abstract class LoginService {
  Future<APIResponse<String>> login(LoginDto loginDto);
}