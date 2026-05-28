import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:mobile_app_braket/core/theme/app_colors.dart';

import 'package:mobile_app_braket/core/usecases/aes_key_storage.dart';
import 'package:mobile_app_braket/core/usecases/aes_key_storage_impl.dart';
import 'package:mobile_app_braket/core/usecases/api_url_storage.dart';
import 'package:mobile_app_braket/core/usecases/api_url_storage_impl.dart';
import 'package:mobile_app_braket/core/usecases/mayo_storage.dart';
import 'package:mobile_app_braket/core/usecases/mayo_storage_impl.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage_impl.dart';
import 'package:mobile_app_braket/core/usecases/token_provider_impl.dart';

import 'package:mobile_app_braket/core/cryptoServices/encryption_service_impl.dart';
import 'package:mobile_app_braket/core/cryptoServices/mayo_service_impl.dart';
import 'package:mobile_app_braket/data/datasources/login_service_impl.dart';
import 'package:mobile_app_braket/data/datasources/message_service_impl.dart';
import 'package:mobile_app_braket/data/datasources/qkd_session_service_impl.dart';

import 'package:mobile_app_braket/core/cryptoServices/encryption_service.dart';
import 'package:mobile_app_braket/core/cryptoServices/mayo_service.dart';
import 'package:mobile_app_braket/data/datasources/qkd_simulator_service_impl.dart';
import 'package:mobile_app_braket/domain/external_services/login_service.dart';
import 'package:mobile_app_braket/domain/external_services/message_service.dart';
import 'package:mobile_app_braket/domain/external_services/qkd_session_service.dart';

import 'package:mobile_app_braket/core/usecases/token_provider.dart';
import 'package:mobile_app_braket/domain/external_services/qkd_simulator_service.dart';

import 'package:mobile_app_braket/presentation/controllers/login_controller.dart';
import 'package:mobile_app_braket/presentation/controllers/message_controller.dart';
import 'package:mobile_app_braket/presentation/controllers/pull_message_controller.dart';
import 'package:mobile_app_braket/presentation/screens/message_screen.dart';
import 'package:mobile_app_braket/presentation/controllers/qkd_session_controller.dart';

import 'package:mobile_app_braket/presentation/screens/home_screen.dart';
import 'package:mobile_app_braket/presentation/screens/login_screen.dart';
import 'package:mobile_app_braket/presentation/screens/pull_message_screen.dart';

const _qkdSimulatorDioTag = 'qkdSimulatorDio';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  final storage = const FlutterSecureStorage();

  final dio = Dio(
    BaseOptions(
      baseUrl: '',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Generowanie klucza qkd na symulatorze trwa około 90 sekund
  // Dopiero wtedy endpoint odpowie stąd wydłużenie czasu
  final qkdSimulatorDio = Dio(
    BaseOptions(
      baseUrl: '',
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    ),
  );

  Get.put<FlutterSecureStorage>(storage);
  Get.put<Dio>(dio);
  Get.put<Dio>(qkdSimulatorDio, tag: _qkdSimulatorDioTag);

  Get.put<ApiUrlStorage>(ApiUrlStorageImpl(storage));

  final apiUrlStorage = Get.find<ApiUrlStorage>();
  final savedApiUrl = await apiUrlStorage.getApiUrl();
  if (savedApiUrl != null && savedApiUrl.isNotEmpty) {
    dio.options.baseUrl = savedApiUrl;
    qkdSimulatorDio.options.baseUrl = savedApiUrl;
  }

  Get.put<TokenProvider>(TokenProviderImpl(storage));

  Get.put<QkdSessionStorage>(QkdSessionStorageImpl(storage));

  Get.put<LoginService>(LoginServiceImpl(dio));

  Get.put<QkdSessionService>(
    QkdSessionServiceImpl(dio, tokenProvider: Get.find<TokenProvider>()),
  );

  Get.put<QkdSimulatorService>(
    QkdSimulatorServiceImpl(
      qkdSimulatorDio,
      tokenProvider: Get.find<TokenProvider>(),
    ),
  );

  Get.put<MessageService>(
    MessageServiceImpl(dio, tokenProvider: Get.find<TokenProvider>()),
  );

  Get.put<EncryptionService>(EncryptionServiceImpl());

  Get.put<AESKeyStorage>(AESKeyStorageImpl(storage));

  Get.put<MayoStorage>(MayoStorageImpl(storage));

  Get.put<MayoService>(MayoServiceImpl(Get.find<MayoStorage>()));

  Get.put(
    LoginController(
      tokenProvider: Get.find<TokenProvider>(),
      loginService: Get.find<LoginService>(),
      apiUrlStorage: Get.find<ApiUrlStorage>(),
      dio: Get.find<Dio>(),
      qkdSimulatorDio: Get.find<Dio>(tag: _qkdSimulatorDioTag),
    ),
  );

  Get.put(
    QkdSessionController(
      qkdSessionService: Get.find<QkdSessionService>(),
      qkdSessionStorage: Get.find<QkdSessionStorage>(),
      aesKeyStorage: Get.find<AESKeyStorage>(),
      mayoStorage: Get.find<MayoStorage>(),
      mayoService: Get.find<MayoService>(),
      qkdSimulatorService: Get.find<QkdSimulatorService>(),
    ),
  );

  Get.put(
    MessageController(
      messageService: Get.find<MessageService>(),
      encryptionService: Get.find<EncryptionService>(),
      qkdSessionStorage: Get.find<QkdSessionStorage>(),
      aesKeyStorage: Get.find<AESKeyStorage>(),
      mayoService: Get.find<MayoService>(),
    ),
  );

  Get.put(
    PullMessageController(
      messageService: Get.find<MessageService>(),
      qkdSessionStorage: Get.find<QkdSessionStorage>(),
      encryptionService: Get.find<EncryptionService>(),
      aesKeyStorage: Get.find<AESKeyStorage>(),
      mayoService: Get.find<MayoService>(),
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
        GetPage(name: '/login', page: () => LoginScreen()),

        GetPage(name: '/home', page: () => HomeScreen()),

        GetPage(name: '/message', page: () => const MessageScreen()),

        GetPage(name: '/pull-message', page: () => const PullMessageScreen()),
      ],
    );
  }
}
