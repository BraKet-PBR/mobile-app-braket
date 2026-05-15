import 'package:mobile_app_braket/data/datasources/api_service_base.dart';
import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/external_services/message_service.dart';
import 'package:mobile_app_braket/domain/models/message_response.dart';
import 'package:mobile_app_braket/domain/models/pull_message_dto.dart';
import 'package:mobile_app_braket/domain/models/pull_message_response.dart';
import 'package:mobile_app_braket/domain/models/send_message_dto.dart';

class MessageServiceImpl extends APIServiceBase implements MessageService {
  MessageServiceImpl(super.dio, {super.tokenProvider});

  @override
  Future<APIResponse<MessageResponse>> sendMessage(SendMessageDto dto) {
    return postAndDeserialize(
      "/api/messages",
      dto.toJson(),
      (json) => MessageResponse.fromJson(json),
    );
  }

  @override
  Future<APIResponse<PullMessageResponse>> pullMessage(PullMessageDto dto) {
    return postAndDeserialize(
      "/api/messages/pull",
      dto.toJson(),
      (json) => PullMessageResponse.fromJson(json),
    );
  }
}
