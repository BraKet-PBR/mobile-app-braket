import 'package:get/get.dart';
import 'package:mobile_app_braket/core/cryptoServices/mayo_service.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/usecases/aes_key_storage.dart';
import 'package:mobile_app_braket/core/usecases/mayo_storage.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:mobile_app_braket/core/cryptoServices/encryption_service.dart';
import 'package:mobile_app_braket/domain/external_services/message_service.dart';
import 'package:mobile_app_braket/domain/models/encryption_result.dart';
import 'package:mobile_app_braket/domain/models/send_message_dto.dart';
import 'package:mobile_app_braket/presentation/controllers/controller_base.dart';

class MessageController extends ControllerBase {
  final MessageService messageService;
  final EncryptionService encryptionService;
  final QkdSessionStorage qkdSessionStorage;
  final AESKeyStorage aesKeyStorage;
  final MayoService mayoService;

  MessageController({
    required this.messageService,
    required this.encryptionService,
    required this.qkdSessionStorage,
    required this.aesKeyStorage,
    required this.mayoService,
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

      //TODO: tu by trzeba sprawdzić czy sesja jest aktywna i nie wygasła
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

      final EncryptionResult encryptionResult = await encryptionService.encrypt(plaintext, aesKey);
      if (encryptionResult.ciphertext.isEmpty) {
        await popup(AppStrings.error, AppStrings.encyrptionError);
        return;
      }

      if (encryptionResult.messageNonce.isEmpty) {
        await popup(AppStrings.error, AppStrings.nonceError);
        return;
      }

      String mayoSignature;
      try {
        mayoSignature = await mayoService.signCiphertext(encryptionResult.ciphertext);
      } catch (error) {
        await popup(AppStrings.qkdNoMayoKeyTitle, AppStrings.qkdNoMayoKeyMessage);
        return;
      }

      if (mayoSignature.isEmpty) {
        await popup(AppStrings.error, AppStrings.mayoError);
        return;
      }

      final response = await messageService.sendMessage(
        SendMessageDto(
          sessionId: sessionId,
          ciphertext: encryptionResult.ciphertext,
          messageNonce: encryptionResult.messageNonce,
          mayoSignature: mayoSignature,
          algorithm: 'AES', // Hardcode, to jest okej ponieważ nie ma wyboru algorytmu na ten moment, może będzie kiedyś więc zostawiam
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
