import 'package:mobile_app_braket/data/datasources/api_service_base.dart';
import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/external_services/qkd_simulator_service.dart';
import 'package:mobile_app_braket/domain/models/dtos/qkd_simulator_response_dto.dart';

class QkdSimulatorServiceImpl extends APIServiceBase implements QkdSimulatorService {
  QkdSimulatorServiceImpl(super.dio, {super.tokenProvider});

  @override
  Future<APIResponse<QkdSimulatorResponseDto>> getAesKeyFromQkd() {
    return getAndDeserialize(
      "/api/qkd/generate",
      (json) => QkdSimulatorResponseDto.fromJson(json)
    );
  }
  
}