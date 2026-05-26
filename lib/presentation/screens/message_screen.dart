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
      backgroundColor: AppColors.surface,

// ======================================================= Tytuł na pasku na górze
      appBar: AppBar(
        backgroundColor: AppColors.surface_elevated,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        iconTheme: const IconThemeData(color: AppColors.white54),
        titleSpacing: 4,
        title: Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppStrings.sendMessageTitle.toUpperCase(),
              style: const TextStyle(
                color: AppColors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

// ======================================================= Kontener (cały) do wpisania wiadomości
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface_elevated,
                  border: Border.all(color: AppColors.border, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          color: AppColors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.sendEncryptedMessage.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: AppColors.divider),
                    const SizedBox(height: 16),
                    TextField(
                      controller: plaintextController,
                      maxLines: 7,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.6,
                      ),
                      cursorColor: AppColors.red,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.code_gray,
                        labelText: AppStrings.plaintextLabel,
                        labelStyle: const TextStyle(
                          color: AppColors.white54,
                          fontSize: 11,
                          fontFamily: 'monospace',
                          letterSpacing: 1,
                        ),
                        hintText: AppStrings.enterMessageHint,
                        hintStyle: const TextStyle(
                          color: AppColors.white54,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.border, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.red, width: 1),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),

              const SizedBox(height: 20),

// ======================================================= Przycisk: Wyślij wiadomość
              SizedBox(
                height: 52,
                child: Obx(() {
                  final busy = controller.isBusy.value;
                  return ElevatedButton(
                    onPressed: busy
                        ? null
                        : () {
                            controller.sendMessage(
                              plaintextController.text.trim(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      disabledBackgroundColor: AppColors.red_dark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_outlined, color: AppColors.white, size: 15),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.sendMessageButton.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                  letterSpacing: 2,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                  );
                }),
              ),

              const SizedBox(height: 20),

// ======================================================= Kontener (cały) z informacjami o statusie wiadomości
              Obx(() {
                if (controller.sendStatus.value.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface_elevated,
                    border: Border.all(color: AppColors.terminal_green_dim, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.terminal_green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.messageStatus(controller.sendStatus.value),
                            style: const TextStyle(
                              color: AppColors.terminal_green,
                              fontSize: 13,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(height: 1, color: AppColors.divider),
                      const SizedBox(height: 10),
                      _StatusRow(
                        label: AppStrings.messageIdStatic,
                        value: controller.messageId.value,
                      ),
                      const SizedBox(height: 6),
                      _StatusRow(
                        label: AppStrings.expires,
                        value: controller.expiresAt.value,
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

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatusRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.white54,
              fontSize: 13,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.white70,
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}