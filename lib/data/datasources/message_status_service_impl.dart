import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/external_services/message_status_service.dart';
import 'package:mobile_app_braket/domain/models/dtos/message_status_response_dto.dart';

class MessageStatusServiceImpl implements MessageStatusService {
  @override
  Future<APIResponse<MessageStatusResponseDto>> checkMessageStatus(String messageId) {
      throw UnimplementedError();
      //TODO: czy wgl będziemy robić sprawdzanie statusu wiadomości???
  }


}