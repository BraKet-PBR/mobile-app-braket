import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ControllerBase extends GetxController {
  final Connectivity connectivity = Connectivity();

  Future<void> handleSomethingWentWrong(Object? error) async {
    String message;

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        message = "Nie udało się wysłać żądania, spróbuj ponownie później.";
      } else if (error.type == DioExceptionType.unknown &&
          error.error is SocketException) {
        message = "Nie udało się wysłać żądania, spróbuj ponownie później.";
      } else {
        message = "Coś poszło nie tak.";
      }
    } else {
      message = "Coś poszło nie tak.";
    }

    await Sentry.captureException(error);
    await popup("Błąd", message);
  }

  Future<void> popup(String title, String message) async {
    await Get.defaultDialog(
      backgroundColor: Colors.white,
        title: title,
        middleText: message,
        confirm: ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("Ok"),
        ));
  }

  Future<bool> hasInternetConnection() async {
    if (!await hasInternetConnectionNoDialog()) {
      await Get.defaultDialog(
          title: "Błąd",
          middleText: "Brak połączenia z internetem",
          confirm: const Text("Ok"));
      return false;
    }

    return true;
  }

  Future<bool> hasInternetConnectionNoDialog() async {
    var connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.ethernet)
    || connectivityResult.contains(ConnectivityResult.mobile)
    || connectivityResult.contains(ConnectivityResult.wifi);
  }
}
