import 'package:get/get.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
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

  final RxBool isBusy = false.obs;

  Future<void> sendMessage(String plaintext) async {
    if (isBusy.value) {
      return;
    }

    try {
      isBusy.value = true;

      if (!await hasInternetConnection()) {
        return;
      }

      final sessionId = await qkdSessionStorage.getSessionId();
      if (sessionId == null || sessionId.isEmpty) {
        await popup(AppStrings.messageNoSessionTitle, AppStrings.messageNoSessionMessage);
        return;
      }

      if (plaintext.isEmpty) {
        await popup(AppStrings.messageNoDataTitle, AppStrings.messageNoDataMessage);
        return;
      }

      final aesKey = await aesKeyStorage.getKey();
      if (aesKey == null || aesKey.isEmpty) {
        await popup(AppStrings.messageNoAesKeyTitle, AppStrings.messageNoAesKeyMessage);
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
        await popup(AppStrings.messageUnexpectedErrorTitle, AppStrings.sendMessageFailed);
        return;
      }

      messageId.value = response.body!.messageId;
      sendStatus.value = response.body!.status;
      expiresAt.value = response.body!.expiresAt;
      await popup(AppStrings.messageSentTitle, AppStrings.messagePendingSaved);
    } catch (error) {
      await handleSomethingWentWrong(error);
    } finally {
      isBusy.value = false;
    }
  }
}
