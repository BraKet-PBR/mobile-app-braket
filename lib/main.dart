import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile_app_braket/data/datasources/login_service_impl.dart';
import 'package:mobile_app_braket/domain/external_services/login_service.dart';
import 'package:mobile_app_braket/presentation/controllers/login_controller.dart';
import 'package:mobile_app_braket/presentation/screens/home_screen.dart';
import 'package:mobile_app_braket/presentation/screens/login_screen.dart';
import 'core/theme/app_colors.dart';

void main() {
  final dio = Dio();

  Get.put<LoginService>(
    LoginServiceImpl(dio),
  );

  Get.put(LoginController(
    storage: GetStorage(),
    loginService: Get.find<LoginService>(),
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Logowanie',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.gray,
        fontFamily: 'Roboto',
      ),

      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
        ),
      ],
    );
  }
}