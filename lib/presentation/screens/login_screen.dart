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
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    label: const Text(
                      AppStrings.moreInfo,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const Spacer(),

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


                TextFormField(
                  controller: usernameController,
                  style: const TextStyle(color: Colors.white),
                  validator: controller.usernameValidator,
                  onSaved: (value) {
                    controller.model.value.username = value;
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.loginHint,
                    hintStyle: const TextStyle(color: Colors.white54),
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


                TextFormField(
                  controller: controller.apiUrlController,
                  style: const TextStyle(color: Colors.white),
                  //validator: controller.apiUrlValidator, TODO: odkomentować to, walidacja tylko na testy wyłączona
                  decoration: InputDecoration(
                    hintText: AppStrings.apiUrlHint,
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(
                      Icons.link,
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


                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  validator: controller.passwordValidator,
                  onSaved: (value) {
                    controller.model.value.password = value;
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.passwordHint,
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
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


                const SizedBox(height: 30),


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
                        color: Colors.white,
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