import 'dart:async';

import 'package:get/get.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:mobile_app_braket/domain/external_services/qkd_session_service.dart';
import 'package:mobile_app_braket/domain/models/init_session_dto.dart';
import 'package:mobile_app_braket/domain/models/join_session_dto.dart';
import 'package:mobile_app_braket/presentation/controllers/controller_base.dart';

class QkdSessionController extends ControllerBase{

  final QkdSessionService qkdSessionService;
  final QkdSessionStorage qkdSessionStorage;

  QkdSessionController({
    required this.qkdSessionService,
    required this.qkdSessionStorage
  });

  final RxString otherUserId = ''.obs;
  final RxString otherUsername = ''.obs;
  final RxString sessionStatus = ''.obs;

  Timer? _pollTimer;
  final Duration _pollInterval = const Duration(seconds: 3);
  bool isPolling = false;

  bool isBusy = false;

  Future<void> joinOrStartSession({required String keyHash}) async {
    if (isBusy) return;

    try {
      isBusy = true;

      if (!await hasInternetConnection()) return;

      final response = await qkdSessionService.joinSession(
        JoinSessionDto(keyHash: keyHash),
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


  Future<void> initSession() async {
    
    if (isBusy) {
      return;
    }

    try {
      isBusy = true;

      if (!await hasInternetConnection()){
        return;
      }

      //TODO: ustalić czym będzie user_id, może jego uuid z bazy??
      //TODO: wstawić key_hash ustalony po qkd
      final response = await qkdSessionService.initSession(
        InitSessionDto(
          keyHash: "KEY_HASH",
        ),
      );

      if (response.error != null){
        await handleSomethingWentWrong(response.error);
        return;
      }

      if (response.body == null) {
        await popup(AppStrings.qkdUnexpectedErrorTitle, AppStrings.qkdCreateSessionFailed);
        return;
      }

      await qkdSessionStorage.saveSessionId(response.body!.sessionId);
      await qkdSessionStorage.saveSessionStatus(response.body!.status);
      await qkdSessionStorage.saveSessionExpiresAt(response.body!.expiresAt);
      sessionStatus.value = response.body!.status;

      await fetchOtherUser();
    }
    catch (error) {
      await handleSomethingWentWrong(error);
    }
    finally {
      isBusy = false;
    }
  }


  Future<void> joinSession() async {
    if (isBusy) {
      return;
    }

    try {
      isBusy = true;

      if (!await hasInternetConnection()){
        return;
      }

      final response = await qkdSessionService.joinSession(
        JoinSessionDto(
          keyHash: "KEY_HASH",
        ),
      );

      if (response.error != null) {
        await handleSomethingWentWrong(response.error);
        return;
      }

      if (response.body == null) {
        await popup(AppStrings.qkdUnexpectedErrorTitle, AppStrings.qkdJoinSessionFailed);
        return;
      }

      await qkdSessionStorage.saveSessionId(response.body!.sessionId);
      await qkdSessionStorage.saveSessionStatus(response.body!.status);
      await qkdSessionStorage.saveSessionExpiresAt(response.body!.expiresAt);
      sessionStatus.value = response.body!.status;
      await fetchOtherUser();
    }
    catch (error) {
      await handleSomethingWentWrong(error);
    }
    finally {
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
      // Check TTL
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