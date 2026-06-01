import 'package:flutter/material.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/external_services/login_service.dart';
import 'package:mobile_app_braket/domain/models/dtos/login_dto.dart';
import 'package:mobile_app_braket/core/usecases/token_provider.dart';
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

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
        await popup(AppStrings.error, AppStrings.apiUrlEmpty);
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
      //Get.offAllNamed('/home'); //TODO: delete - bypass logowania tylko na testy
    }

  }

  Future handleAPIResponse(APIResponse<String> apiResponse) async {
    if (apiResponse.error?.runtimeType == DioException) {
      popup(AppStrings.error, AppStrings.serverNotResponding);
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
      await handleSomethingWentWrong(AppStrings.loginServerError(apiResponse.statusCode ?? 0));
      return;
    }

    await tokenProvider.saveToken(apiResponse.body!);

    clearLoginFields();

    // print("Username: ${await tokenProvider.getUsername()}"); //TODO: USUNĄĆ

    Get.offAllNamed('/home');
  }





  String? usernameValidator(String? value) {
    const int maxUsernameLen = 250;
    if (value == null || value == ''){
      return AppStrings.usernameEmpty;
    }
    if (value.length > maxUsernameLen) {
      return AppStrings.usernameTooLong;
    }
    return null;

  }


  String? passwordValidator(String? value) {
    const int maxPasswordLen = 250;
    if (value == null || value == ''){
      return AppStrings.passwordEmpty;
    }
    if (value.length > maxPasswordLen) {
      return AppStrings.passwordTooLong;
    }
    return null;
  }


  String? apiUrlValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.apiUrlEmpty;
    }

    final v = value.trim();
    final match = apiUrlRegex.hasMatch(v);
    if (!match) {
      return AppStrings.apiUrlInvalidFormat;
    }

    return null;
  }


  void showInvalidCredentialsError() {
    popup(AppStrings.loginErrorTitle, AppStrings.invalidCredentials);
  }

  void clearLoginFields() {
    usernameController.clear();
    passwordController.clear();
  }

}