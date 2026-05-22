import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/external_services/message_status_service.dart';
import 'package:mobile_app_braket/domain/models/message_status_response.dart';

class MessageStatusServiceImpl implements MessageStatusService {
  @override
  Future<APIResponse<MessageStatusResponse>> checkMessageStatus(String messageId) {
      throw UnimplementedError();
      //TODO: czy wgl będziemy robić sprawdzanie statusu wiadomości???
  }


}