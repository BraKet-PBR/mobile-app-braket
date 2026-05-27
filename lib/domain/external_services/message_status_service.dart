import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/models/dtos/message_status_response_dto.dart';

abstract class MessageStatusService {
  Future<APIResponse<MessageStatusResponseDto>> checkMessageStatus(String messageId);
}