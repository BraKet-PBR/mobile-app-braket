import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/theme/app_colors.dart';
import 'package:mobile_app_braket/core/usecases/aes_key_storage.dart';
import 'package:mobile_app_braket/core/usecases/mayo_storage.dart';
import 'package:mobile_app_braket/core/usecases/token_provider.dart';
import 'package:mobile_app_braket/presentation/controllers/controller_base.dart';
import 'package:mobile_app_braket/presentation/controllers/qkd_session_controller.dart';
import 'package:mobile_app_braket/core/usecases/api_url_storage.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final QkdSessionController controller = Get.find<QkdSessionController>();
  final TokenProvider tokenProvider = Get.find<TokenProvider>();
  final QkdSessionStorage qkdSessionStorage = Get.find<QkdSessionStorage>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      appBar: AppBar(
        backgroundColor: AppColors.surface_elevated,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Test MAYO',
            icon: const Icon(
              Icons.security,
              color: AppColors.white54,
              size: 20,
            ),
            onPressed: () async {
              await controller.runMayoSmokeTest();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white54, size: 20),
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
              final mayoStorage = Get.find<MayoStorage>();
              final flutterStorage = Get.find<FlutterSecureStorage>();
              final dio = Get.find<Dio>();

              await apiUrlStorage.clear();
              await qkdStorage.clear();
              await aesStorage.clear();
              await mayoStorage.clear();
              await flutterStorage.delete(key: 'apiToken');
              await tokenProvider.deleteToken();
              dio.options.baseUrl = '';

              Get.offAllNamed('/login');
            },
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              _InfoCard(
                children: [
                  // ======================================================= Zalogowano jako: x
                  FutureBuilder<String?>(
                    future: tokenProvider.getUsername(),
                    builder: (context, snapshot) {
                      // final username = snapshot.data; //TODO: odkomentować
                      final username = "Mikołaj"; //TODO: usunąć

                      // ignore: unnecessary_null_comparison, dead_code
                      if (username == null) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: [
                          _InfoRow(
                            label: AppStrings.loggedInAs,
                            value: username,
                            valueColor: AppColors.white,
                          ),

                          const SizedBox(height: 10),
                          Container(height: 1, color: AppColors.divider),
                          const SizedBox(height: 10),

                          // ======================================================= Status sesji: x
                          Obx(() {
                            final status = controller.sessionStatus.value;
                            final isActive = controller.isSessionActive;

                            return _InfoRow(
                              label: AppStrings.sessionStatusStatic,
                              value: status,
                              valueColor: isActive
                                  ? AppColors.terminal_green
                                  : AppColors.amber,
                              monospace: true,
                            );
                          }),

                          const SizedBox(height: 10),

                          // ======================================================= Sesja wygaśnie za: x
                          Obx(() {
                            final text = controller.sessionExpiryText.value;

                            return _InfoRow(
                              label: AppStrings.sessionExpiresInStatic,
                              value: text,
                              valueColor: AppColors.white54,
                              monospace: true,
                            );
                          }),
                        ],
                      );
                    },
                  ),

                  // ======================================================= Drugi uczestnik: x ID drugiego usera: x
                  Obx(() {
                    if (controller.otherUserId.value.isEmpty) {
                      if (controller.sessionStatus.value.toLowerCase() ==
                          'waiting_peer') {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Container(height: 1, color: AppColors.divider),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    color: AppColors.amber,
                                    strokeWidth: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  AppStrings.awaitingOtherPeer,
                                  style: TextStyle(
                                    color: AppColors.amber,
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(height: 1, color: AppColors.divider),
                        const SizedBox(height: 10),
                        _InfoRow(
                          label: AppStrings.otherUser,
                          value: controller.otherUsername.value,
                          valueColor: AppColors.terminal_green,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: AppStrings.otherUserId,
                          value: controller.otherUserId.value,
                          valueColor: AppColors.white54,
                          monospace: true,
                          small: true,
                        ),
                      ],
                    );
                  }),
                ],
              ),

              const SizedBox(height: 20),

              // ======================================================= Przycisk: Dołącz do sesji
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(() {
                  final isDisabled = controller.isSessionActive;

                  return _CyberButton(
                    label: AppStrings.joinSession,
                    icon: Icons.cable_outlined,
                    onPressed: isDisabled
                        ? null
                        : () async {
                            await controller.joinOrStartSession();
                          },
                    isPrimary: true,
                  );
                }),
              ),

              const SizedBox(height: 12),

              // ======================================================= Przycisk: Wyślij wiadomość
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _CyberButton(
                  label: AppStrings.sendMessage,
                  icon: Icons.arrow_upward_rounded,
                  onPressed: () {
                    Get.toNamed('/message');
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ======================================================= Przycisk: Pobierz wiadomość
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _CyberButton(
                  label: AppStrings.pullMessage,
                  icon: Icons.arrow_downward_rounded,
                  onPressed: () {
                    Get.toNamed('/pull-message');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================== Shared widgets ======================

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface_elevated,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool monospace;
  final bool small;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.monospace = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 155,
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
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _CyberButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _CyberButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? (disabled ? AppColors.red_dark : AppColors.red)
            : AppColors.surface_elevated,
        disabledBackgroundColor: AppColors.red_dark,
        disabledForegroundColor: AppColors.white54,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: isPrimary
                ? (disabled ? AppColors.border_accent : AppColors.red)
                : AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: disabled
                ? AppColors.white54
                : (isPrimary ? AppColors.white : AppColors.white70),
          ),
          const SizedBox(width: 10),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: disabled
                  ? AppColors.white54
                  : (isPrimary ? AppColors.white : AppColors.white70),
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
