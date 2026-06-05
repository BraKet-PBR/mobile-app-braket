import 'package:dio/dio.dart';
import 'package:mobile_app_braket/domain/external_services/api_response.dart';
import 'package:mobile_app_braket/core/usecases/token_provider.dart';

abstract class APIServiceBase {
  final Dio dio;
  TokenProvider? tokenProvider;

  APIServiceBase(this.dio, {this.tokenProvider});

  Future<Options?> _getOptionsWithAuthorization() async {
    if (tokenProvider == null) {
      return null;
    }

    String? token = await tokenProvider?.getToken();

    if (token == null) {
      return null;
    }

    return Options(headers: {"Authorization": "Bearer $token"});
  }

  APIResponse<T> _handleError<T>(DioException de){
    var response = de.response;
    if (response == null) {
      return APIResponse<T>(error: de);
    }
    return APIResponse<T>(
      statusCode: response.statusCode!,
      errorBody: response.data,
    );
  }

  Future<APIResponse<T>> post<T>(String url, Map<String, dynamic> body) async {
    try {
      Options? options = await _getOptionsWithAuthorization();
      Response<T> response = await dio.post(url, options: options, data: body);
      return APIResponse<T>(statusCode: response.statusCode!, body: response.data);
    } on DioException catch (error) {
        return _handleError(error);
    }
  }

  Future<APIResponse<T>> postAndDeserialize<T>(String url, Map<String, dynamic> body, T Function(dynamic json) deserialize) async {
    try {
      Options? options = await _getOptionsWithAuthorization();
      final Response response = await dio.post(url, options: options, data: body);
      return APIResponse<T>(
        statusCode: response.statusCode,
        body: deserialize(response.data),
      );
    } on DioException catch (error) {
      return _handleError(error);
    }
  }

  Future<APIResponse<T>> getAndDeserialize<T>(String url, T Function(dynamic json) deserialize) async {
    try {
      Options? options = await _getOptionsWithAuthorization();
      final Response response = await dio.get(url, options: options);
      return APIResponse<T>(
        statusCode: response.statusCode,
        body: deserialize(response.data)
      );
    } on DioException catch (error) {
      return _handleError(error);
    }
  }



}
