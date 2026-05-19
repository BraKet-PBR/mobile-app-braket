import 'package:flutter/material.dart';
import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/external_services/login_service.dart';
import 'package:mobile_app_braket/domain/models/login_dto.dart';
import 'package:mobile_app_braket/domain/usecases/token_provider.dart';
import 'package:mobile_app_braket/presentation/controllers/controller_base.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_app_braket/core/usecases/api_url_storage.dart';

class LoginController extends ControllerBase {

  final TokenProvider tokenProvider;
  final formKey = GlobalKey<FormState>();
  final LoginService loginService;
  final Rx<LoginDto> model = LoginDto().obs;

  final ApiUrlStorage _apiUrlStorage;
  final Dio _dio;
  final TextEditingController apiUrlController = TextEditingController();

  String? apiUrl;
  late RegExp apiUrlRegex = RegExp(r'(https:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)(:\d+)?');

  bool isBusy = false;

  LoginController({required this.tokenProvider, required this.loginService, required ApiUrlStorage apiUrlStorage, required Dio dio}) : _apiUrlStorage = apiUrlStorage, _dio = dio;

  @override
  void onInit() {
    super.onInit();
    _loadSavedApiUrl();
  }

  Future<void> _loadSavedApiUrl() async {
    try{
      final saved = await _apiUrlStorage.getApiUrl();
      if (saved != null && saved.isNotEmpty) {
        apiUrl = saved;
        apiUrlController.text = saved;
        _dio.options.baseUrl = saved;
      }
    } catch (_) {}
  }

  void _saveUrl() {
    var url = apiUrlController.text.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    _apiUrlStorage.saveApiUrl(url);
    _dio.options.baseUrl = url;
    apiUrl = url;
  }


  void login() async {
    if (isBusy) {
      return;
    }

    try{
      isBusy = true;
      final isValid = formKey.currentState!.validate(); //binding metod passwordValidator i usernameValidator na ekranie "validator:"
      Get.focusScope!.unfocus(); //ukrywa klawiaturę

      if(!isValid) {
        return;
      }

      formKey.currentState!.save();

      if (apiUrlController.text.trim().isEmpty) {
        await popup("Błąd", "Pole API URL jest wymagane");
        return;
      }

      _saveUrl();

      if (!await hasInternetConnection()){
        return;
      }

      var apiResponse = await loginService.login(model.value);
      await handleAPIResponse(apiResponse);
    } catch (error) {
      await handleSomethingWentWrong(error);
    } finally {
      isBusy = false;
    }

  }

  Future handleAPIResponse(APIResponse<String> apiResponse) async {
    if (apiResponse.error?.runtimeType == DioException) {
      popup("Błąd", "Serwer nie odpowiada.");
      return;
    }

    if (apiResponse.error != null) {
      await handleSomethingWentWrong(apiResponse.error);
      return;
    }

    if (apiResponse.statusCode == 401) {
      showInvalidCredentialsError();
      return;
    }

    if (apiResponse.statusCode != 200){
      await handleSomethingWentWrong("Logowanie nie powidoło się. Kod odpowiedzi serwera: $apiResponse.statusCode");
      return;
    }

    await saveToken(apiResponse.body!);
  }


  Future<void> saveToken(String token) async {
    await tokenProvider.saveToken(token);

    Get.offAllNamed('/home');
  }


  String? usernameValidator(String? value) {
    const int maxUsernameLen = 250;
    if (value == null || value == ''){
      return "Nazwa użytkownika nie może być pusta";
    }
    if (value.length > maxUsernameLen) {
      return "Nazwa użytkownika za długa";
    }
    return null;

  }


  String? passwordValidator(String? value) {
    const int maxPasswordLen = 250;
    if (value == null || value == ''){
      return "Hasło nie może być puste";
    }
    if (value.length > maxPasswordLen) {
      return "Hasło za długie.";
    }
    return null;
  }


  String? apiUrlValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'API URL nie może być pusty';
    }

    final v = value.trim();
    final match = apiUrlRegex.hasMatch(v);
    if (!match) {
      return 'Nieprawidłowy format adresu';
    }

    return null;
  }


  void showInvalidCredentialsError() {
    popup("Błąd logowania", "Nieprawidłowy login lub hasło");
  }

}