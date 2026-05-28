import 'package:get/get.dart';
import 'package:mobile_app_braket/core/cryptoServices/mayo_service.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:mobile_app_braket/core/usecases/aes_key_storage.dart';
import 'package:mobile_app_braket/domain/external_services/message_service.dart';
import 'package:mobile_app_braket/core/cryptoServices/encryption_service.dart';
import 'package:mobile_app_braket/domain/models/dtos/pull_message_dto.dart';
import 'package:mobile_app_braket/presentation/controllers/controller_base.dart';

class PullMessageController extends ControllerBase {
  final MessageService messageService;
  final QkdSessionStorage qkdSessionStorage;
  final EncryptionService encryptionService;
  final AESKeyStorage aesKeyStorage;
  final MayoService mayoService;

  PullMessageController({
    required this.messageService,
    required this.qkdSessionStorage,
    required this.encryptionService,
    required this.aesKeyStorage,
    required this.mayoService,
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
        await popup(
          AppStrings.pullNoSessionTitle,
          AppStrings.pullNoSessionMessage,
        );
        return;
      }

      // TODO sprawdzenie czy sesja aktywna

      final response = await messageService.pullMessage(
        PullMessageDto(sessionId: sessionId),
      );

      // 404 oznacza że wszystko jest ok tylko nie ma nowych wiadomości dla danego usera
      if (response.statusCode == 404) {
        await popup(
          AppStrings.pullNoMessagesTitle,
          AppStrings.pullNoMessagesMessage,
        );
        return;
      }

      if (response.statusCode != 200 || response.body == null) {
        await popup(
          AppStrings.pullUnexpectedErrorTitle,
          AppStrings.pullMessageFailed,
        );
        return;
      }

      bool isSignatureValid = false;
      try {
        isSignatureValid = await mayoService.validateMessagePayloadSignature(
          sessionId: sessionId,
          ciphertext: response.body!.ciphertext,
          messageNonce: response.body!.messageNonce,
          algorithm: response.body!.algorithm,
          signature: response.body!.mayoSignature,
        );
      } catch (error) {
        await popup(AppStrings.error, AppStrings.pullNoMayoPeerKey);
        return;
      }

      if (!isSignatureValid) {
        await popup(
          AppStrings.pullUnexpectedErrorTitle,
          AppStrings.pullInvalidSignature,
        );
        return;
      }

      final cid = response.body!.ciphertext;
      messageId.value = response.body!.messageId;
      ciphertext.value = cid;
      algorithm.value = response.body!.algorithm;
      createdAt.value = response.body!.createdAt;

      final aesKey = await aesKeyStorage.getKey();
      if (aesKey == null || aesKey.isEmpty) {
        await popup(
          AppStrings.pullUnexpectedErrorTitle,
          AppStrings.messageNoAesKeyMessage,
        );
        return;
      }

      final decrypted = await encryptionService.decrypt(
        cid,
        aesKey,
        response.body!.messageNonce,
      );
      if (decrypted.isEmpty) {
        await popup(
          AppStrings.pullUnexpectedErrorTitle,
          AppStrings.pullDecryptFailed,
        );
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
