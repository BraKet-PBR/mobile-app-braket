import 'package:get/get.dart';
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

  bool isBusy = false;

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
          sessionNonce: "SESSION_NONCE"
        )
      );

      if (response.error != null){
        await handleSomethingWentWrong(response.error);
        return;
      }

      if (response.body == null) {
        await popup("Nieoczekiwany Błąd", "Nie udało się utworzyć sesji.");
        return;
      }

      await qkdSessionStorage.saveSessionId(response.body!.sessionId);
      await qkdSessionStorage.saveSessionStatus(response.body!.status);
      await qkdSessionStorage.saveSessionExpiresAt(response.body!.expiresAt);

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
          sessionNonce: "SESSION_NONCE",
        ),
      );

      if (response.error != null) {
        await handleSomethingWentWrong(response.error);
        return;
      }

      if (response.body == null) {
        await popup("Nieoczekiwany Błąd", "Nie udało się dołączyć do sesji.");
        return;
      }

      await qkdSessionStorage.saveSessionId(response.body!.sessionId);
      await qkdSessionStorage.saveSessionStatus(response.body!.status);
      await qkdSessionStorage.saveSessionExpiresAt(response.body!.expiresAt);
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

    if (response.error != null) {
      await handleSomethingWentWrong(response.error);
      return;
    }

    if (response.body == null) {
      await popup(
        "Błąd",
        "Nie udało się pobrać danych drugiego użytkownika.",
      );
      return;
    }

    otherUserId.value = response.body!.userId;
    otherUsername.value = response.body!.username;
  }


}