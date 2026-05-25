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
                    icon: const Icon(Icons.info_outline, color: AppColors.white),
                    label: const Text(
                      AppStrings.moreInfo,
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ),

                const Spacer(),

// ======================================================= Logo BraKet
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppColors.red,
                    letterSpacing: 2,
                  ),
                ),


                const SizedBox(height: 50),

// ======================================================= Pole: API URL
                TextFormField(
                  controller: controller.apiUrlController,
                  style: const TextStyle(color: AppColors.white),
                  //validator: controller.apiUrlValidator, TODO: odkomentować to, walidacja tylko na testy wyłączona
                  decoration: InputDecoration(
                    hintText: AppStrings.apiUrlHint,
                    hintStyle: const TextStyle(color: AppColors.white54),
                    prefixIcon: const Icon(
                      Icons.link,
                      color: AppColors.white70,
                    ),
                    filled: true,
                    fillColor: AppColors.gray_light,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),


                const SizedBox(height: 20),

// ======================================================= Pole: Login
                TextFormField(
                  controller: usernameController,
                  style: const TextStyle(color: AppColors.white),
                  validator: controller.usernameValidator,
                  onSaved: (value) {
                    controller.model.value.username = value;
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.loginHint,
                    hintStyle: const TextStyle(color: AppColors.white54),
                    prefixIcon: const Icon(
                      Icons.person_2_outlined,
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: AppColors.gray_light,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),


                const SizedBox(height: 20),

// ======================================================= Pole: Hasło
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.white),
                  validator: controller.passwordValidator,
                  onSaved: (value) {
                    controller.model.value.password = value;
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.passwordHint,
                    hintStyle: const TextStyle(color: AppColors.white54),
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
                      color: AppColors.white70,
                    ),
                    filled: true,
                    fillColor: AppColors.gray_light,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),


                const SizedBox(height: 30),

// ======================================================= Przycisk: Zaloguj się
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: controller.login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      AppStrings.loginButton,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
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
}