import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/models/message_response.dart';
import 'package:mobile_app_braket/domain/models/pull_message_dto.dart';
import 'package:mobile_app_braket/domain/models/pull_message_response.dart';
import 'package:mobile_app_braket/domain/models/send_message_dto.dart';

abstract class MessageService {
  Future<APIResponse<MessageResponse>> sendMessage(SendMessageDto dto);
  Future<APIResponse<PullMessageResponse>> pullMessage(PullMessageDto dto);
}
