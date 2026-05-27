import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/models/dtos/message_response_dto.dart';
import 'package:mobile_app_braket/domain/models/dtos/pull_message_dto.dart';
import 'package:mobile_app_braket/domain/models/dtos/pull_message_response_dto.dart';
import 'package:mobile_app_braket/domain/models/dtos/send_message_dto.dart';

abstract class MessageService {
  Future<APIResponse<MessageResponseDto>> sendMessage(SendMessageDto dto);
  Future<APIResponse<PullMessageResponseDto>> pullMessage(PullMessageDto dto);
}
