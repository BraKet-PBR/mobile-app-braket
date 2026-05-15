import 'package:get/get.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:mobile_app_braket/domain/external_services/message_service.dart';
import 'package:mobile_app_braket/domain/models/pull_message_dto.dart';
import 'package:mobile_app_braket/domain/models/pull_message_response.dart';
import 'package:mobile_app_braket/presentation/controllers/controller_base.dart';

class PullMessageController extends ControllerBase {
  final MessageService messageService;
  final QkdSessionStorage qkdSessionStorage;

  PullMessageController({
    required this.messageService,
    required this.qkdSessionStorage,
  });

  final RxString messageId = ''.obs;
  final RxString ciphertext = ''.obs;
  final RxString algorithm = ''.obs;
  final RxString createdAt = ''.obs;
  final RxBool hasMessage = false.obs;

  bool isBusy = false;

  Future<void> pullMessage() async {
    if (isBusy) {
      return;
    }

    try {
      isBusy = true;

      if (!await hasInternetConnection()) {
        return;
      }

      final sessionId = await qkdSessionStorage.getSessionId();
      if (sessionId == null || sessionId.isEmpty) {
        await popup("Brak sesji", "Najpierw utwórz lub dołącz do sesji.");
        return;
      }

      final response = await messageService.pullMessage(
        PullMessageDto(sessionId: sessionId),
      );

      if (response.error != null) {
        if (response.statusCode == 404) {
          await popup("Brak wiadomości", "Nie masz nowych wiadomości.");
        } else {
          await handleSomethingWentWrong(response.error);
        }
        return;
      }

      if (response.body == null) {
        await popup("Nieoczekiwany Błąd", "Nie udało się pobrać wiadomości.");
        return;
      }

      messageId.value = response.body!.messageId;
      ciphertext.value = response.body!.ciphertext;
      algorithm.value = response.body!.algorithm;
      createdAt.value = response.body!.createdAt;
      hasMessage.value = true;
    } catch (error) {
      await handleSomethingWentWrong(error);
    } finally {
      isBusy = false;
    }
  }

  void clearMessage() {
    messageId.value = '';
    ciphertext.value = '';
    algorithm.value = '';
    createdAt.value = '';
    hasMessage.value = false;
  }
}