import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/theme/app_colors.dart';
import 'package:mobile_app_braket/presentation/controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController controller = Get.find<LoginController>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [

// ======================================================= Przycisk: Więcej informacji
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.info_outline, color: AppColors.white54, size: 16),
                    label: const Text(
                      AppStrings.moreInfo,
                      style: TextStyle(
                        color: AppColors.white54,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

// ======================================================= Logo BraKet
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 4,
                          height: 36,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                            letterSpacing: 6,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.red_glow,
                        border: Border.all(color: AppColors.border_accent, width: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'QUANTUM KEY DISTRIBUTION',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.red,
                          letterSpacing: 3,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

// ======================================================= Pole: API URL
                _CyberField(
                  controller: controller.apiUrlController,
                  hint: AppStrings.apiUrlHint,
                  icon: Icons.dns_outlined,
                  validator: null, // controller.apiUrlValidator, TODO: odkomentować, walidacja wyłączona na testy
                ),

                const SizedBox(height: 14),

// ======================================================= Pole: Login
                TextFormField(
                  controller: usernameController,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                  validator: controller.usernameValidator,
                  onSaved: (value) {
                    controller.model.value.username = value;
                  },
                  decoration: _cyberDecoration(AppStrings.loginHint, Icons.person_2_outlined),
                ),

                const SizedBox(height: 14),

// ======================================================= Pole: Hasło
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                  validator: controller.passwordValidator,
                  onSaved: (value) {
                    controller.model.value.password = value;
                  },
                  decoration: _cyberDecoration(AppStrings.passwordHint, Icons.lock_outlined),
                ),

                const SizedBox(height: 32),

// ======================================================= Przycisk: Zaloguj się
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.login,
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
                        const Icon(Icons.terminal, color: AppColors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.loginButton.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 13,
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

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _cyberDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.white54,
        fontSize: 13,
        fontFamily: 'monospace',
      ),
      prefixIcon: Icon(icon, color: AppColors.white54, size: 18),
      filled: true,
      fillColor: AppColors.code_gray,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.red, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.amber, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.amber, width: 1),
      ),
    );
  }
}

class _CyberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;

  const _CyberField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: AppColors.white,
        fontFamily: 'monospace',
        fontSize: 14,
      ),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.white54,
          fontSize: 13,
          fontFamily: 'monospace',
        ),
        prefixIcon: Icon(icon, color: AppColors.white54, size: 18),
        filled: true,
        fillColor: AppColors.code_gray,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.red, width: 1),
        ),
      ),
    );
  }
}
