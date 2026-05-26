import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';
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

    // await Sentry.captureException(error); TODO TODO: to powoduje konflikty w sns sentry ale trzeba jakoś ogarnąc
    await popup(AppStrings.error, message);
  }

  Future<void> popup(String title, String message) async {
    await Get.dialog(
      _CyberDialog(
        title: title,
        message: message,
        isError: true,
        actions: [
          _CyberDialogButton(
            label: AppStrings.ok,
            isPrimary: true,
            onPressed: () => Get.back(),
          ),
        ],
      ),
      barrierColor: Colors.black.withOpacity(0.7),
    );
  }

  Future<bool> confirm(String title, String message) async {
    final result = await Get.dialog<bool>(
      _CyberDialog(
        title: title,
        message: message,
        isError: false,
        actions: [
          _CyberDialogButton(
            label: AppStrings.no,
            isPrimary: false,
            onPressed: () => Get.back(result: false),
          ),
          _CyberDialogButton(
            label: AppStrings.yes,
            isPrimary: true,
            onPressed: () => Get.back(result: true),
          ),
        ],
      ),
      barrierColor: Colors.black.withOpacity(0.7),
    );
    return result ?? false;
  }

  Future<bool> hasInternetConnection() async {
    if (!await hasInternetConnectionNoDialog()) {
      await Get.dialog(
        _CyberDialog(
          title: AppStrings.error,
          message: AppStrings.noInternet,
          isError: true,
          actions: [
            _CyberDialogButton(
              label: AppStrings.ok,
              isPrimary: true,
              onPressed: () => Get.back(),
            ),
          ],
        ),
        barrierColor: Colors.black.withOpacity(0.7),
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


class _CyberDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isError;
  final List<Widget> actions;

  const _CyberDialog({
    required this.title,
    required this.message,
    required this.isError,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: AppColors.surface_elevated,
          border: Border.all(
            color: isError ? AppColors.border_accent : AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
              ),
              child: Row(
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.help_outline,
                    color: isError ? AppColors.red : AppColors.white54,
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: isError ? AppColors.red : AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            // Message
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.white70,
                  fontSize: 13,
                  fontFamily: 'monospace',
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            // Divider
            Container(height: 1, color: AppColors.divider),

            // Actions
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (int i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    actions[i],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CyberDialogButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _CyberDialogButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.red : AppColors.surface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(
              color: isPrimary ? AppColors.red : AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isPrimary ? AppColors.white : AppColors.white54,
            letterSpacing: 1.5,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}