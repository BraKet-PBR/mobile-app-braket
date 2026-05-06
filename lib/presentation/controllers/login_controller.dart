import 'package:flutter/material.dart';
import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/domain/external_services/login_service.dart';
import 'package:mobile_app_braket/domain/models/login_dto.dart';
import 'package:mobile_app_braket/presentation/controllers/controller_base.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class LoginController extends ControllerBase {

  final GetStorage storage;
  final formKey = GlobalKey<FormState>();
  final LoginService loginService;
  final Rx<LoginDto> model = LoginDto().obs;

  bool isBusy = false;

  LoginController({required this.storage, required this.loginService});


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

      if (!await hasInternetConnection()){
        return;
      }

      var apiResponse = await loginService.login(model.value);
      await handleAPIResponse(apiResponse);
    }
    catch (error) {
      await handleSomethingWentWrong(error);
    }
    finally {
      isBusy = false;
      Get.offAllNamed('/home'); //TODO usunąć na testy nastepnych ekranów tytlko 
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

    saveToken(apiResponse.body!);
  }


  void saveToken(String token) {
    storage.write('apiToken', token);

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


  void showInvalidCredentialsError() {
    popup("Błąd logowania", "Nieprawidłowy login lub hasło");
  }

}