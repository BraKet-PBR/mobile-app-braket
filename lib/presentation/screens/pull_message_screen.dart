import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_app_braket/core/theme/app_colors.dart';
import 'package:mobile_app_braket/presentation/controllers/pull_message_controller.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';

class PullMessageScreen extends StatefulWidget {
  const PullMessageScreen({super.key});

  @override
  State<PullMessageScreen> createState() => _PullMessageScreenState();
}

class _PullMessageScreenState extends State<PullMessageScreen> {
  final PullMessageController controller = Get.find<PullMessageController>();

  @override
  void dispose() {
    controller.clearMessage();
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
              AppStrings.pullMessageTitle.toUpperCase(),
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

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface_elevated,
                  border: Border.all(color: AppColors.border, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,

// ======================================================= Przycisk "Pobierz wiadomość" + tło
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          color: AppColors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.pullEncryptedMessage.toUpperCase(),
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

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.pullMessage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download_outlined, color: AppColors.white, size: 15),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.pullMessageButton.toUpperCase(),
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
                      ),
                    ),

                    const SizedBox(height: 20),

// ======================================================= Kontener z informacjami o pobranej wiadomości
                    Obx(() {
                      if (controller.hasMessage.value) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(height: 1, color: AppColors.divider),
                            const SizedBox(height: 16),

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
                                  AppStrings.receivedMessage.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.terminal_green,
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.code_gray,
                                border: Border.all(color: AppColors.border, width: 1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _DecryptedRow(
                                    label: AppStrings.messageIdStatic,
                                    value: controller.messageId.value,
                                  ),

                                  const SizedBox(height: 10),
                                  Container(height: 1, color: AppColors.divider),
                                  const SizedBox(height: 10),

                                  _DecryptedRow(
                                    label: AppStrings.plaintext,
                                    value: controller.plaintext.value,
                                    highlight: true,
                                  ),

                                  const SizedBox(height: 10),
                                  Container(height: 1, color: AppColors.divider),
                                  const SizedBox(height: 10),

                                  _DecryptedRow(
                                    label: AppStrings.alg,
                                    value: controller.algorithm.value,
                                  ),

                                  const SizedBox(height: 10),
                                  Container(height: 1, color: AppColors.divider),
                                  const SizedBox(height: 10),

                                  _DecryptedRow(
                                    label: AppStrings.created,
                                    value: controller.createdAt.value,
                                  ),

                                  const SizedBox(height: 16),

                                  SizedBox(
                                    height: 44,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: controller.plaintext.value),
                                        );

                                        Get.snackbar(
                                          AppStrings.success,
                                          AppStrings.plaintextCopySuccess,
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: AppColors.surface_elevated,
                                          colorText: AppColors.white,
                                          borderColor: AppColors.terminal_green_dim,
                                          borderWidth: 1,
                                          margin: const EdgeInsets.all(16),
                                          borderRadius: 6,
                                          icon: const Icon(Icons.check, color: AppColors.terminal_green, size: 16),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.surface_elevated,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                          side: const BorderSide(color: AppColors.border, width: 1),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.copy,
                                        color: AppColors.white70,
                                        size: 15,
                                      ),
                                      label: Text(
                                        AppStrings.copyPlaintextButton.toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.white70,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.warning_amber_outlined, color: AppColors.amber, size: 13),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    AppStrings.messageDeletionWarning,
                                    style: const TextStyle(
                                      color: AppColors.amber_dim,
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecryptedRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _DecryptedRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 77,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.white54,
              fontSize: 10,
              fontFamily: 'monospace',
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: highlight ? AppColors.white : AppColors.white70,
              fontSize: highlight ? 14 : 12,
              fontFamily: 'monospace',
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
