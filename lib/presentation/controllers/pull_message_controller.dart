import 'package:get/get.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:mobile_app_braket/core/usecases/aes_key_storage.dart';
import 'package:mobile_app_braket/domain/external_services/message_service.dart';
import 'package:mobile_app_braket/domain/external_services/encryption_service.dart';
import 'package:mobile_app_braket/domain/models/pull_message_dto.dart';
import 'package:mobile_app_braket/presentation/controllers/controller_base.dart';

class PullMessageController extends ControllerBase {
  final MessageService messageService;
  final QkdSessionStorage qkdSessionStorage;
  final EncryptionService encryptionService;
  final AESKeyStorage aesKeyStorage;

  PullMessageController({
    required this.messageService,
    required this.qkdSessionStorage,
    required this.encryptionService,
    required this.aesKeyStorage,
  });

  final RxString messageId = ''.obs;
  final RxString ciphertext = ''.obs;
  final RxString plaintext = ''.obs;
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
        await popup(AppStrings.pullNoSessionTitle, AppStrings.pullNoSessionMessage);
        return;
      }

      final response = await messageService.pullMessage(
        PullMessageDto(sessionId: sessionId),
      );

      if (response.error != null) {
        if (response.statusCode == 404) {
          await popup(AppStrings.pullNoMessagesTitle, AppStrings.pullNoMessagesMessage);
        } else {
          await handleSomethingWentWrong(response.error);
        }
        return;
      }

      if (response.body == null) {
        await popup(AppStrings.pullUnexpectedErrorTitle, AppStrings.pullMessageFailed);
        return;
      }

      final cid = response.body!.ciphertext;
      messageId.value = response.body!.messageId;
      ciphertext.value = cid;
      algorithm.value = response.body!.algorithm;
      createdAt.value = response.body!.createdAt;

      final aesKey = await aesKeyStorage.getKey();
      if (aesKey == null || aesKey.isEmpty) {
        await popup(AppStrings.pullUnexpectedErrorTitle, AppStrings.messageNoAesKeyMessage);
        return;
      }

        final decrypted = await encryptionService.decrypt(cid, aesKey, response.body!.messageNonce);
      if (decrypted.isEmpty) {
        await popup(AppStrings.pullUnexpectedErrorTitle, AppStrings.pullDecryptFailed);
        return;
      }

      plaintext.value = decrypted;
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
    plaintext.value = '';
    algorithm.value = '';
    createdAt.value = '';
    hasMessage.value = false;
  }
}