import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app_braket/core/theme/app_colors.dart';
import 'package:mobile_app_braket/presentation/controllers/qkd_session_controller.dart';

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
            onPressed: () {
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
                  onPressed: controller.initSession,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: const Text(
                    'Rozpocznij sesję',

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
                  onPressed: controller.joinSession,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: const Text(
                    'Dołącz do sesji',

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
                    'Wyślij wiadomość',

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
                    'Pobierz wiadomość',

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
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    Text(
                      'Drugi uczestnik: ${controller.otherUsername.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: ${controller.otherUserId.value}',
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