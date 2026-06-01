import 'package:get/get.dart';
import 'package:mobile_app_braket/core/cryptoServices/mayo_service.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/usecases/aes_key_storage.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:mobile_app_braket/core/cryptoServices/encryption_service.dart';
import 'package:mobile_app_braket/domain/external_services/message_service.dart';
import 'package:mobile_app_braket/domain/models/encryption_result.dart';
import 'package:mobile_app_braket/domain/models/dtos/send_message_dto.dart';
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

    // ========================= TODO: usunąć
    // messageId.value = "6d165395-a472-4ff6-8b26-6c86954f18be";
    // expiresAt.value = "DateTime";
    // sendStatus.value = "Pending";
    // ========================= TODO: usunąć

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

      final EncryptionResult encryptionResult = await encryptionService.encrypt(plaintext, aesKey);
      if (encryptionResult.ciphertext.isEmpty) {
        await popup(AppStrings.error, AppStrings.encyrptionError);
        return;
      }

      if (encryptionResult.messageNonce.isEmpty) {
        await popup(AppStrings.error, AppStrings.nonceError);
        return;
      }

      const algorithm = 'AES';

      String mayoSignature;
      try {
        mayoSignature = await mayoService.signMessagePayload(
          sessionId: sessionId,
          ciphertext: encryptionResult.ciphertext,
          messageNonce: encryptionResult.messageNonce,
          algorithm: algorithm,
        );
      } catch (error) {
        await popup(AppStrings.error, AppStrings.mayoError);
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
          algorithm: algorithm,
        ),
      );

      if (response.statusCode != 201) {
        await handleSomethingWentWrong(response.error ?? "HTTP ${response.statusCode}");
        return;
      }

      if (response.body == null) {
        await popup(AppStrings.messageUnexpectedErrorTitle, AppStrings.sendMessageFailed);
        return;
      }

      messageId.value = response.body!.messageId;
      expiresAt.value = response.body!.expiresAt;
      sendStatus.value = response.body!.status;
      await popup(AppStrings.messageSentTitle, AppStrings.messagePendingSaved);
    } catch (error) {
      await handleSomethingWentWrong(error);
    } finally {
      isBusy.value = false;
    }
  }
}
