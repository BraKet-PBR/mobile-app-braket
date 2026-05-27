import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/cryptoServices/mayo_service.dart';
import 'package:mobile_app_braket/core/usecases/aes_key_storage.dart';
import 'package:mobile_app_braket/core/usecases/mayo_storage.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:mobile_app_braket/domain/external_services/qkd_session_service.dart';
import 'package:mobile_app_braket/domain/external_services/qkd_simulator_service.dart';
import 'package:mobile_app_braket/domain/models/dtos/join_session_dto.dart';
import 'package:mobile_app_braket/presentation/controllers/controller_base.dart';

class QkdSessionController extends ControllerBase {
  final QkdSessionService qkdSessionService;
  final QkdSessionStorage qkdSessionStorage;
  final AESKeyStorage aesKeyStorage;
  final MayoStorage mayoStorage;
  final MayoService mayoService;
  final QkdSimulatorService qkdSimulatorService;

  QkdSessionController({
    required this.qkdSessionService,
    required this.qkdSessionStorage,
    required this.aesKeyStorage,
    required this.mayoStorage,
    required this.mayoService,
    required this.qkdSimulatorService,
  });

  final RxString otherUserId = ''.obs;
  final RxString otherUsername = ''.obs;
  final RxString sessionStatus = ''.obs;
  final RxString sessionExpiryText = ''.obs;

  final Rx<DateTime?> sessionExpiresAt = Rx<DateTime?>(null);

  Timer? _countdownTimer;
  Timer? _pollTimer;

  final Duration _pollInterval = const Duration(seconds: 3);

  bool isPolling = false;
  bool isBusy = false;


  Future<void> joinOrStartSession() async {

    // ========================= TODO: usunąć
    otherUserId.value = "cdcd3280-fb85-4175-9778-3a6f8bc2606c";
    otherUsername.value = "Andrzej";
    sessionStatus.value = "waiting_peer";
    final testExpiry = DateTime.now().add(const Duration(minutes: 1));
    sessionExpiresAt.value = testExpiry;
    _startCountdown();
    // ========================= TODO: usunąć

    if (isBusy) return;

    isBusy = true;

    try {
      if (!await hasInternetConnection()) return;

      //TODO tutaj wywołanie symulatora qkd
      final response_simulator = await qkdSimulatorService.getAesKeyFromQkd();
      if (response_simulator.statusCode != 200 || response_simulator.body == null) {
        await popup(
          AppStrings.qkdUnexpectedErrorTitle,
          AppStrings.qkdSimulatorError,
        );
        return;
      }

      final storedKey = await aesKeyStorage.getKey();
      if (storedKey == null || storedKey.isEmpty) {
        await popup(AppStrings.qkdNoKeyTitle, AppStrings.qkdNoKeyMessage);
        return;
      }

      await mayoService.generateMayoKeyPairAndStore();

      final mayoPublicSelfKey = await mayoStorage.getMayoPublicSelf();
      if (mayoPublicSelfKey == null || mayoPublicSelfKey.isEmpty) {
        await popup(AppStrings.qkdNoMayoKeyTitle, AppStrings.qkdNoMayoKeyMessage);
        return;
      }

      final keyHash = sha256.convert(utf8.encode(storedKey)).toString();

      final response = await qkdSessionService.joinSession(
        JoinSessionDto(keyHash: keyHash, mayoKey: mayoPublicSelfKey),
      );

      if (response.statusCode != 200 || response.body == null) {
        await popup(
          AppStrings.qkdUnexpectedErrorTitle,
          AppStrings.qkdJoinOrCreateSessionFailed,
        );
        return;
      }

      sessionStatus.value = response.body!.status;

      await qkdSessionStorage.saveSessionId(response.body!.sessionId);
      await qkdSessionStorage.saveSessionStatus(response.body!.status);
      await qkdSessionStorage.saveSessionExpiresAt(response.body!.expiresAt);

      sessionExpiresAt.value = response.body!.expiresAt;

      _startCountdown();

      if (response.body!.status.toLowerCase() == 'waiting_peer') {
        _startPolling();
      } else {
        await fetchOtherUser();
      }
    } catch (e) {
      await handleSomethingWentWrong(e);
    } finally {
      isBusy = false;
    }
  }



  Future<void> fetchOtherUser() async {
    final response = await qkdSessionService.getOtherSessionUser();

    if (response.statusCode == 404) return;
    if (response.statusCode != 200 || response.body == null) return;

    otherUserId.value = response.body!.userId;
    otherUsername.value = response.body!.username;

    if (response.body!.mayoKey.isNotEmpty) {
      await mayoStorage.saveMayoPublicPeer(response.body!.mayoKey);
    }

    _stopPolling();
  }



  void _startPolling() {
    if (isPolling) return;
    isPolling = true;

    _pollTimer?.cancel();

    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      final expiresAt = sessionExpiresAt.value;

      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        _expireSession();
        return;
      }

      await fetchOtherUser();
    });
  }



  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    isPolling = false;
  }



  void _startCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );

    _updateCountdown();
  }



  void _updateCountdown() {
    final expiresAt = sessionExpiresAt.value;

    if (expiresAt == null) {
      sessionExpiryText.value = '';
      return;
    }

    final diff = expiresAt.difference(DateTime.now());

    if (diff.isNegative) {
      _expireSession();
      return;
    }

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    final formatted =
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    sessionExpiryText.value = formatted;
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }


  Future<void> _expireSession() async {
    sessionStatus.value = 'expired';

    sessionExpiresAt.value = null;
    sessionExpiryText.value = AppStrings.sessionExpired;

    _stopPolling();
    _stopCountdown();


    final qkdStorage = Get.find<QkdSessionStorage>();
    final aesStorage = Get.find<AESKeyStorage>();
    final mayoStorage = Get.find<MayoStorage>();

    await qkdStorage.clear();
    await aesStorage.clear();
    await mayoStorage.clear();
  

    otherUserId.value = '';
    otherUsername.value = '';
  }



  void clearSession() {
    _stopPolling();
    _stopCountdown();

    otherUserId.value = '';
    otherUsername.value = '';
    sessionStatus.value = '';
    sessionExpiresAt.value = null;
    sessionExpiryText.value = '';
  }

  @override
  void onClose() {
    _stopPolling();
    _stopCountdown();
    super.onClose();
  }


  bool get isSessionActive {
    final status = sessionStatus.value.toLowerCase();
    final expiresAt = sessionExpiresAt.value;

    if (status == 'expired') return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) return false;

    return status.isNotEmpty;
  }
}