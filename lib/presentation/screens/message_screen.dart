import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/theme/app_colors.dart';
import 'package:mobile_app_braket/presentation/controllers/message_controller.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final MessageController controller = Get.find<MessageController>();
  final TextEditingController plaintextController = TextEditingController();

  @override
  void dispose() {
    plaintextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray,
// ======================================================= Tytuł na pasku na górze
      appBar: AppBar(
        backgroundColor: AppColors.red,
        title: const Text(AppStrings.sendMessageTitle),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

// ======================================================= Kontener (cały) do wpisania wiadomości
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.gray_light,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.sendEncryptedMessage,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: plaintextController,
                      maxLines: 6,
                      style: const TextStyle(color: AppColors.black87),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: AppStrings.plaintextLabel,
                        labelStyle: const TextStyle(color: AppColors.red),
                        hintText: AppStrings.enterMessageHint,
                        hintStyle: const TextStyle(color: AppColors.black45),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),

              ),


              const SizedBox(height: 24),

// ======================================================= Przycisk: Wyślij wiadomość
              SizedBox(
                height: 55,
                child: Obx(() {
                  return ElevatedButton(
                    onPressed: controller.isBusy.value
                        ? null
                        : () {
                            controller.sendMessage(
                              plaintextController.text.trim(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isBusy.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            AppStrings.sendMessageButton,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                  );
                }),
              ),


              const SizedBox(height: 24),

// ======================================================= Kontener (cały) z informacjami o statusie wiadomości
              Obx(() {
                if (controller.sendStatus.value.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray_light,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.messageStatus(controller.sendStatus.value),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.messageId(controller.messageId.value),
                        style: const TextStyle(
                          color: AppColors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.messageExpiresAt(controller.expiresAt.value),
                        style: const TextStyle(
                          color: AppColors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
