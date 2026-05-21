import 'dart:async';

import 'package:get/get.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/cryptoServices/mayo_service.dart';
import 'package:mobile_app_braket/core/usecases/aes_key_storage.dart';
import 'package:mobile_app_braket/core/usecases/mayo_storage.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:mobile_app_braket/domain/external_services/qkd_session_service.dart';
import 'package:mobile_app_braket/domain/models/join_session_dto.dart';
import 'package:mobile_app_braket/presentation/controllers/controller_base.dart';

class QkdSessionController extends ControllerBase{

  final QkdSessionService qkdSessionService;
  final QkdSessionStorage qkdSessionStorage;
  final AESKeyStorage aesKeyStorage;
  final MayoStorage mayoStorage;
  final MayoService mayoService;

  QkdSessionController({
    required this.qkdSessionService,
    required this.qkdSessionStorage,
    required this.aesKeyStorage,
    required this.mayoStorage,
    required this.mayoService,
  });

  final RxString otherUserId = ''.obs;
  final RxString otherUsername = ''.obs;
  final RxString sessionStatus = ''.obs;

  Timer? _pollTimer;
  final Duration _pollInterval = const Duration(seconds: 3);
  bool isPolling = false;

  bool isBusy = false;

  Future<void> joinOrStartSession() async {
    if (isBusy) {
      return;
    }

    try {
      isBusy = true;

      if (!await hasInternetConnection()) return;

      final String? storedKey = await aesKeyStorage.getKey();
      if (storedKey == null || storedKey.isEmpty) {
        await popup(AppStrings.qkdNoKeyTitle, AppStrings.qkdNoKeyMessage);
        return;
      }

      // Uruchomienie nowej sesji generuje nową parę kluczy mayo 
      await mayoService.generateMayoKeyPairAndStore();

      // pobranie swojego własnego klucza mayo publicznego wcześniej wygeneorwane i wysłanie na endpoint
      String? mayoPublicSelfKey = await mayoStorage.getMayoPublicSelf();
      if (mayoPublicSelfKey == null || mayoPublicSelfKey.isEmpty) {
        await popup(AppStrings.qkdNoMayoKeyTitle, AppStrings.qkdNoMayoKeyMessage);
        return;
      }

      final response = await qkdSessionService.joinSession(
        JoinSessionDto(keyHash: storedKey, mayoKey: mayoPublicSelfKey), 
      );

      if (response.error != null) {
        await handleSomethingWentWrong(response.error);
        return;
      }

      if (response.body == null) {
        await popup(AppStrings.qkdUnexpectedErrorTitle, AppStrings.qkdJoinOrCreateSessionFailed);
        return;
      }

      await qkdSessionStorage.saveSessionId(response.body!.sessionId);
      await qkdSessionStorage.saveSessionStatus(response.body!.status);
      await qkdSessionStorage.saveSessionExpiresAt(response.body!.expiresAt);
      sessionStatus.value = response.body!.status;

      if (response.body!.status.toLowerCase() == 'waiting_peer') {
        // tutaj wpada sytuacja gdy dany user jest pierwszym który dołącza do sesji i musi czekać na drugiego usera
        _startPolling();
      } else {
        await fetchOtherUser();
      }
    } catch (error) {
      await handleSomethingWentWrong(error);
    } finally {
      isBusy = false;
    }
  }



  Future<void> fetchOtherUser() async {
    final response = await qkdSessionService.getOtherSessionUser();

    // Jak serwer odpowie 404 to znaczy że nie ma drugiego usera w sesji!!!!
    if (response.statusCode == 404) {
      return;
    }

    if (response.error != null) {
      await handleSomethingWentWrong(response.error);
      return;
    }

    if (response.body == null) {
      return;
    }

    otherUserId.value = response.body!.userId;
    otherUsername.value = response.body!.username;

    // zapisanie klcuza publicznego wysłanego przez odbiorce przy dołączeniu do sesji. 
    if (response.body!.mayoKey.isNotEmpty) {
      await mayoStorage.saveMayoPublicPeer(response.body!.mayoKey);
    }

    _stopPolling();
  }


  void _stopPolling() {
    if (_pollTimer != null && _pollTimer!.isActive) {
      _pollTimer!.cancel();
    }
    isPolling = false;
  }


  void _startPolling() {
    if (isPolling) return;
    isPolling = true;

    _pollTimer = Timer.periodic(_pollInterval, (timer) async {
      final expiresAt = await qkdSessionStorage.getSessionExpiresAt();
      if (expiresAt != null) {
        final expiry = DateTime.tryParse(expiresAt);
        if (expiry != null && DateTime.now().isAfter(expiry)) {
          // session expired
          _stopPolling();
          sessionStatus.value = 'expired';
          return;
        }
      }

      await fetchOtherUser();
    });
  }


}