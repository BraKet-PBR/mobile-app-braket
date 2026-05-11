import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:mobile_app_braket/core/theme/app_colors.dart';

import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage_impl.dart';
import 'package:mobile_app_braket/core/usecases/token_provider_impl.dart';

import 'package:mobile_app_braket/data/datasources/login_service_impl.dart';
import 'package:mobile_app_braket/data/datasources/qkd_session_service_impl.dart';

import 'package:mobile_app_braket/domain/external_services/login_service.dart';
import 'package:mobile_app_braket/domain/external_services/qkd_session_service.dart';

import 'package:mobile_app_braket/domain/usecases/token_provider.dart';

import 'package:mobile_app_braket/presentation/controllers/login_controller.dart';
import 'package:mobile_app_braket/presentation/controllers/qkd_session_controller.dart';

import 'package:mobile_app_braket/presentation/screens/home_screen.dart';
import 'package:mobile_app_braket/presentation/screens/login_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  final storage = GetStorage();

  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://TODO',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );


  Get.put<TokenProvider>(
    TokenProviderImpl(storage),
  );

  Get.put<QkdSessionStorage>(
    QkdSessionStorageImpl(storage),
  );

  Get.put<LoginService>(
    LoginServiceImpl(dio),
  );

  Get.put<QkdSessionService>(
    QkdSessionServiceImpl(
      dio,
      tokenProvider: Get.find<TokenProvider>(),
    ),
  );


  Get.put(
    LoginController(
      storage: storage,
      loginService: Get.find<LoginService>(),
    ),
  );

  Get.put(
    QkdSessionController(
      qkdSessionService: Get.find<QkdSessionService>(),
      qkdSessionStorage: Get.find<QkdSessionStorage>(),
    ),
  );

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
          page: () => HomeScreen(),
        ),
      ],
    );
  }
}