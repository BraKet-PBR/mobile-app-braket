import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/theme/app_colors.dart';

class ControllerBase extends GetxController {
  final Connectivity connectivity = Connectivity();

  Future<void> handleSomethingWentWrong(Object? error) async {
    String message;

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        message = AppStrings.requestFailed;
      } else if (error.type == DioExceptionType.unknown &&
          error.error is SocketException) {
        message = AppStrings.requestFailed;
      } else {
        message = AppStrings.somethingWentWrong;
      }
    } else {
      message = AppStrings.somethingWentWrong;
    }

    await Sentry.captureException(error);
    await popup(AppStrings.error, message);
  }

  Future<void> popup(String title, String message) async {
    await Get.defaultDialog(
      backgroundColor: AppColors.gray_light,
      title: title,
      titleStyle: const TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.bold,
      ),
      middleText: message,
      middleTextStyle: const TextStyle(
        color: AppColors.white,
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Get.back();
        },
        child: const Text(
          AppStrings.ok,
          style: TextStyle(color: AppColors.white),
        ),
      ),
    );
  }

  Future<bool> hasInternetConnection() async {
    if (!await hasInternetConnectionNoDialog()) {
      await Get.defaultDialog(
        title: AppStrings.error,
        titleStyle: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
        middleText: AppStrings.noInternet,
        middleTextStyle: const TextStyle(color: AppColors.white),
        backgroundColor: AppColors.gray_light,
        confirm: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
          onPressed: () => Get.back(),
          child: const Text(
            AppStrings.ok,
            style: TextStyle(color: AppColors.white),
          ),
        ),
      );
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
