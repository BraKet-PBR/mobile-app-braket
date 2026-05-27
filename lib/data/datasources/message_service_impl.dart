import 'package:mobile_app_braket/data/datasources/api_service_base.dart';
import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/external_services/message_service.dart';
import 'package:mobile_app_braket/domain/models/dtos/message_response_dto.dart';
import 'package:mobile_app_braket/domain/models/dtos/pull_message_dto.dart';
import 'package:mobile_app_braket/domain/models/dtos/pull_message_response_dto.dart';
import 'package:mobile_app_braket/domain/models/dtos/send_message_dto.dart';

class MessageServiceImpl extends APIServiceBase implements MessageService {
  MessageServiceImpl(super.dio, {super.tokenProvider});

  @override
  Future<APIResponse<MessageResponseDto>> sendMessage(SendMessageDto dto) {
    return postAndDeserialize(
      "/api/messages",
      dto.toJson(),
      (json) => MessageResponseDto.fromJson(json),
    );
  }

  @override
  Future<APIResponse<PullMessageResponseDto>> pullMessage(PullMessageDto dto) {
    return postAndDeserialize(
      "/api/messages/pull",
      dto.toJson(),
      (json) => PullMessageResponseDto.fromJson(json),
    );
  }
}
