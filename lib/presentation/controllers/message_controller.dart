import 'package:get/get.dart';
import 'package:mobile_app_braket/core/usecases/aes_key_storage.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:mobile_app_braket/domain/external_services/encryption_service.dart';
import 'package:mobile_app_braket/domain/external_services/message_service.dart';
import 'package:mobile_app_braket/domain/models/encryption_result.dart';
import 'package:mobile_app_braket/domain/models/send_message_dto.dart';
import 'package:mobile_app_braket/presentation/controllers/controller_base.dart';

class MessageController extends ControllerBase {
  final MessageService messageService;
  final EncryptionService encryptionService;
  final QkdSessionStorage qkdSessionStorage;
  final AESKeyStorage aesKeyStorage;

  MessageController({
    required this.messageService,
    required this.encryptionService,
    required this.qkdSessionStorage,
    required this.aesKeyStorage,
  });

  final RxString sendStatus = ''.obs;
  final RxString messageId = ''.obs;
  final RxString expiresAt = ''.obs;

  bool isBusy = false;

  Future<void> sendMessage(String plaintext) async {
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

      if (plaintext.isEmpty) {
        await popup("Brak danych", "Uzupełnij tekst wiadomości.");
        return;
      }

      final aesKey = await aesKeyStorage.getKey();
      if (aesKey == null || aesKey.isEmpty) {
        await popup("Brak klucza AES", "Najpierw zapisz klucz AES w bezpiecznym magazynie.");
        return;
      }

      final EncryptionResult result = await encryptionService.encrypt(plaintext, aesKey);

      final response = await messageService.sendMessage(
        SendMessageDto(
          sessionId: sessionId,
          ciphertext: result.ciphertext,
          messageNonce: result.messageNonce,
          algorithm: 'AES',
        ),
      );

      if (response.error != null) {
        await handleSomethingWentWrong(response.error);
        return;
      }

      if (response.body == null) {
        await popup("Nieoczekiwany Błąd", "Nie udało się wysłać wiadomości.");
        return;
      }

      messageId.value = response.body!.messageId;
      sendStatus.value = response.body!.status;
      expiresAt.value = response.body!.expiresAt;
      await popup("Wysłano", "Wiadomość została zapisana jako pending.");
    } catch (error) {
      await handleSomethingWentWrong(error);
    } finally {
      isBusy = false;
    }
  }
}
