import 'package:get/get.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:mobile_app_braket/domain/external_services/qkd_session_service.dart';
import 'package:mobile_app_braket/domain/models/create_session_dto.dart';
import 'package:mobile_app_braket/presentation/controllers/controller_base.dart';

class QkdSessionController extends ControllerBase{

  final QkdSessionService qkdSessionService;
  final QkdSessionStorage qkdSessionStorage;

  QkdSessionController({
    required this.qkdSessionService,
    required this.qkdSessionStorage
  });

  final RxString otherUserId = ''.obs;

  bool isBusy = false;

  Future<void> startSession() async {
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
      final response = await qkdSessionService.createSession(
        CreateSessionDto(
          userId: "USER_ID",
          keyHash: "KEY_HASH"
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

      qkdSessionStorage.saveSessionId(response.body!.sessionId);

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
  }


}