import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/cryptoServices/mayo_native.dart';
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

  @override
  void onInit() {
    super.onInit();
    unawaited(restoreLocalSession());
  }

  final RxString otherUserId = ''.obs;
  final RxString otherUsername = ''.obs;
  final RxString sessionStatus = ''.obs;
  final RxString sessionExpiryText = ''.obs;
  final RxBool useSimulatedQkd = false.obs;

  final Rx<DateTime?> sessionExpiresAt = Rx<DateTime?>(null);

  Timer? _countdownTimer;
  Timer? _pollTimer;

  final Duration _pollInterval = const Duration(seconds: 3);

  bool isPolling = false;
  bool isBusy = false;
  bool _isPollingRequestInFlight = false;

  String get selectedQkdMode => useSimulatedQkd.value ? 'sim' : 'mock';

  void setQkdMode(bool simulated) {
    if (isSessionActive || isBusy) return;
    useSimulatedQkd.value = simulated;
  }


  Future<void> joinOrStartSession() async {

    // ========================= TODO: usunąć
    // otherUserId.value = "cdcd3280-fb85-4175-9778-3a6f8bc2606c";
    // otherUsername.value = "Andrzej";
    // sessionStatus.value = "waiting_peer";
    // final testExpiry = DateTime.now().add(const Duration(minutes: 1));
    // sessionExpiresAt.value = testExpiry;
    // _startCountdown();
    // ========================= TODO: usunąć

    if (isBusy) return;

    isBusy = true;

    try {
      if (!await hasInternetConnection()) return;

      // ======================================================= Symulator QKD
      showLoadingPopup(
        title: AppStrings.qkdString,
        message: AppStrings.qdkSessionInProgress,
      );

      try {
        final response_simulator = await qkdSimulatorService.getAesKeyFromQkd(
          selectedQkdMode,
        );
        if (
          response_simulator.statusCode != 200 ||
          response_simulator.body == null ||
          response_simulator.body!.status.toLowerCase() != 'available' ||
          response_simulator.body!.keyMaterial.isEmpty
        ) {
          await popup(
            AppStrings.qkdUnexpectedErrorTitle,
            AppStrings.qkdSimulatorError,
          );
          return;
        }

        await aesKeyStorage.saveKey(response_simulator.body!.keyMaterial);

      } on DioException catch (e) {
        await handleSomethingWentWrong(e);
      } finally {
        hideLoadingPopup();
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

      if (response.error != null) {
        await handleSomethingWentWrong(response.error);
        return;
      }

      if (response.statusCode == 200 && response.body == null) {
        await popup(
          AppStrings.qkdUnexpectedErrorTitle,
          'Serwer utworzył sesję, ale aplikacja nie odczytała odpowiedzi.',
        );
        return;
      }

      if (response.statusCode != 200) {
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

      _startPolling();

      if (response.body!.status.toLowerCase() == 'active') {
        await fetchOtherUser();
      } else {
        _clearPeer();
      }
    } catch (e) {
      await handleSomethingWentWrong(e);
      hideLoadingPopup();
    } finally {
      isBusy = false;
      hideLoadingPopup();
    }
  }



  Future<void> fetchOtherUser() async {
    final response = await qkdSessionService.getOtherSessionUser();

    if (response.statusCode == 404) {
      _clearPeer();
      return;
    }
    if (response.statusCode != 200 || response.body == null) return;

    otherUserId.value = response.body!.userId;
    otherUsername.value = response.body!.username;

    if (response.body!.mayoKey.isNotEmpty) {
      await mayoStorage.saveMayoPublicPeer(response.body!.mayoKey);
    }
  }



  Future<void> refreshCurrentSession() async {
    final response = await qkdSessionService.getCurrentSession();

    if (response.statusCode == 404) {
      _clearPeer();
      sessionStatus.value = '';
      return;
    }
    if (response.statusCode != 200 || response.body == null) return;

    sessionStatus.value = response.body!.status;
    sessionExpiresAt.value = response.body!.expiresAt;

    await qkdSessionStorage.saveSessionId(response.body!.sessionId);
    await qkdSessionStorage.saveSessionStatus(response.body!.status);
    await qkdSessionStorage.saveSessionExpiresAt(response.body!.expiresAt);

    final status = response.body!.status.toLowerCase();
    if (status == 'active') {
      await fetchOtherUser();
      return;
    }

    _clearPeer();

    if (status == 'expired') {
      await _expireSession();
    }
  }



  Future<void> restoreLocalSession() async {
    final savedStatus = await qkdSessionStorage.getSessionStatus();
    final savedExpiresAt = await qkdSessionStorage.getSessionExpiresAt();

    if (savedStatus == null || savedStatus.isEmpty || savedExpiresAt == null) {
      return;
    }

    if (DateTime.now().isAfter(savedExpiresAt)) {
      await _expireSession();
      return;
    }

    sessionStatus.value = savedStatus;
    sessionExpiresAt.value = savedExpiresAt;

    _startCountdown();
    _startPolling();
    await refreshCurrentSession();
  }



  void _startPolling() {
    if (isPolling) return;
    isPolling = true;

    _pollTimer?.cancel();

    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      if (_isPollingRequestInFlight) return;

      final expiresAt = sessionExpiresAt.value;

      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        _expireSession();
        return;
      }

      _isPollingRequestInFlight = true;
      try {
        await refreshCurrentSession();
      } finally {
        _isPollingRequestInFlight = false;
      }
    });
  }



  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    isPolling = false;
    _isPollingRequestInFlight = false;
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


    await qkdSessionStorage.clear();
    await aesKeyStorage.clear();
    await mayoStorage.clear();

    _clearPeer();
  }



  Future<void> clearLocalSession() async {
    _stopPolling();
    _stopCountdown();

    _clearPeer();
    sessionStatus.value = '';
    sessionExpiresAt.value = null;
    sessionExpiryText.value = '';

    await qkdSessionStorage.clear();
    await aesKeyStorage.clear();
    await mayoStorage.clear();
  }



  Future<void> clearSession() async {
    await clearLocalSession();
  }



  void _clearPeer() {
    otherUserId.value = '';
    otherUsername.value = '';
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



  Future<void> runMayoSmokeTest() async {
    try {
      final mayo = MayoNative.instance;
      final keyPair = await mayo.generateKeyPair();
      final message = Uint8List.fromList(utf8.encode('MAYO app test'));

      final signature = await mayo.sign(
        message: message,
        privateKey: keyPair.privateKey,
      );

      final originalValid = await mayo.verify(
        message: message,
        signature: signature,
        publicKey: keyPair.publicKey,
      );

      final changedMessage = Uint8List.fromList(
        utf8.encode('MAYO app test changed'),
      );

      final changedValid = await mayo.verify(
        message: changedMessage,
        signature: signature,
        publicKey: keyPair.publicKey,
      );

      final passed = originalValid && !changedValid;
      final result = [
        'Wynik: ${passed ? "PASSED" : "FAILED"}',
        'Klucz publiczny: ${keyPair.publicKey.length} B',
        'Klucz prywatny: ${keyPair.privateKey.length} B',
        'Podpis: ${signature.length} B',
        'Oryginalna wiadomosc poprawna: ${originalValid ? "TAK" : "NIE"}',
        'Zmieniona wiadomosc odrzucona: ${!changedValid ? "TAK" : "NIE"}',
      ].join('\n');

      await popup('Test MAYO', result);
    } catch (e) {
      await popup('Test MAYO', 'Nie udalo sie uruchomic testu MAYO.\n$e');
    }
  }
}
