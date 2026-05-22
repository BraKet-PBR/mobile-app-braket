import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/models/message_status_response.dart';

abstract class MessageStatusService {
  Future<APIResponse<MessageStatusResponse>> checkMessageStatus(String messageId);
}