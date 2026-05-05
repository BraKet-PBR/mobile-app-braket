import 'package:mobile_app_braket/data/datasources/api_service_base.dart';
import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/external_services/login_service.dart';
import 'package:mobile_app_braket/domain/models/login_dto.dart';

class LoginServiceImpl extends APIServiceBase implements LoginService{

  LoginServiceImpl(super.dio);

  @override
  Future<APIResponse<String>> login(LoginDto loginDto) {
    return post<String>("/api/authentication/login", loginDto.toJson());
  }
}