import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/models/dtos/qkd_simulator_response_dto.dart';

abstract class QkdSimulatorService {
  Future<APIResponse<QkdSimulatorResponseDto>> getAesKeyFromQkd(String mode);
}
