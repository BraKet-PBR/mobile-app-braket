import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/theme/app_colors.dart';
import 'package:mobile_app_braket/core/usecases/aes_key_storage.dart';
import 'package:mobile_app_braket/presentation/controllers/controller_base.dart';
import 'package:mobile_app_braket/presentation/controllers/qkd_session_controller.dart';
import 'package:mobile_app_braket/core/usecases/api_url_storage.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class HomeScreen extends StatelessWidget {

  HomeScreen({super.key});

  final QkdSessionController controller =
      Get.find<QkdSessionController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.gray,

      appBar: AppBar(
        backgroundColor: AppColors.red,

        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: AppColors.gray_light,
            ),
            onPressed: () async {
              final shouldLogout = await ControllerBase().confirm(
                AppStrings.logoutConfirmTitle,
                AppStrings.logoutConfirmMessage,
              );

              if (!shouldLogout) {
                return;
              }

              final apiUrlStorage = Get.find<ApiUrlStorage>();
              final qkdStorage = Get.find<QkdSessionStorage>();
              final aesStorage = Get.find<AESKeyStorage>();
              final flutterStorage = Get.find<FlutterSecureStorage>();
              final dio = Get.find<Dio>();

              await apiUrlStorage.clear();
              await qkdStorage.clear();
              await aesStorage.clear();
              await flutterStorage.delete(key: 'apiToken');
              dio.options.baseUrl = '';

              Get.offAllNamed('/login');
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: () async {
                    await controller.joinOrStartSession();
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: const Text(
                    AppStrings.joinSession,

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed('/message');
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: const Text(
                    AppStrings.sendMessage,

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed('/pull-message');
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: const Text(
                    AppStrings.pullMessage,

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Obx(() {
                if (controller.otherUserId.value.isEmpty) {
                  if (controller.sessionStatus.value.toLowerCase() == 'waiting_peer') {
                    return const Text(
                      AppStrings.awaitingOtherPeer,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    );
                  }
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    Text(
                      AppStrings.otherUser(controller.otherUsername.value),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.otherUserId(controller.otherUserId.value),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}