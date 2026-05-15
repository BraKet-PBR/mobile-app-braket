import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:mobile_app_braket/core/theme/app_colors.dart';

import 'package:mobile_app_braket/core/usecases/aes_key_storage.dart';
import 'package:mobile_app_braket/core/usecases/aes_key_storage_impl.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage_impl.dart';
import 'package:mobile_app_braket/core/usecases/token_provider_impl.dart';

import 'package:mobile_app_braket/data/datasources/encryption_service_impl.dart';
import 'package:mobile_app_braket/data/datasources/login_service_impl.dart';
import 'package:mobile_app_braket/data/datasources/message_service_impl.dart';
import 'package:mobile_app_braket/data/datasources/qkd_session_service_impl.dart';

import 'package:mobile_app_braket/domain/external_services/encryption_service.dart';
import 'package:mobile_app_braket/domain/external_services/login_service.dart';
import 'package:mobile_app_braket/domain/external_services/message_service.dart';
import 'package:mobile_app_braket/domain/external_services/qkd_session_service.dart';

import 'package:mobile_app_braket/domain/usecases/token_provider.dart';

import 'package:mobile_app_braket/presentation/controllers/login_controller.dart';
import 'package:mobile_app_braket/presentation/controllers/message_controller.dart';
import 'package:mobile_app_braket/presentation/controllers/pull_message_controller.dart';
import 'package:mobile_app_braket/presentation/screens/message_screen.dart';
import 'package:mobile_app_braket/presentation/controllers/qkd_session_controller.dart';

import 'package:mobile_app_braket/presentation/screens/home_screen.dart';
import 'package:mobile_app_braket/presentation/screens/login_screen.dart';
import 'package:mobile_app_braket/presentation/screens/pull_message_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://TODO',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );


  Get.put<TokenProvider>(
    TokenProviderImpl(const FlutterSecureStorage()),
  );

  Get.put<QkdSessionStorage>(
    QkdSessionStorageImpl(const FlutterSecureStorage()),
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

  Get.put<MessageService>(
    MessageServiceImpl(
      dio,
      tokenProvider: Get.find<TokenProvider>(),
    ),
  );

  Get.put<EncryptionService>(
    EncryptionServiceImpl(),
  );

  Get.put<AESKeyStorage>(
    AESKeyStorageImpl(const FlutterSecureStorage()),
  );

  Get.put(
    LoginController(
      tokenProvider: Get.find<TokenProvider>(),
      loginService: Get.find<LoginService>(),
    ),
  );

  Get.put(
    QkdSessionController(
      qkdSessionService: Get.find<QkdSessionService>(),
      qkdSessionStorage: Get.find<QkdSessionStorage>(),
    ),
  );

  Get.put(
    MessageController(
      messageService: Get.find<MessageService>(),
      encryptionService: Get.find<EncryptionService>(),
      qkdSessionStorage: Get.find<QkdSessionStorage>(),
      aesKeyStorage: Get.find<AESKeyStorage>(),
    ),
  );

  Get.put(
    PullMessageController(
      messageService: Get.find<MessageService>(),
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

        GetPage(
          name: '/message',
          page: () => const MessageScreen(),
        ),

        GetPage(
          name: '/pull-message',
          page: () => const PullMessageScreen(),
        ),
      ],
    );
  }
}