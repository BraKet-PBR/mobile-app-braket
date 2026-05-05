import 'package:dio/dio.dart';
import 'package:mobile_app_braket/domain/external_services/api_response.dart';

abstract class TokenProvider {
  String getToken();
  String getUsername();
}

abstract class APIServiceBase {
  final Dio dio;
  TokenProvider? tokenProvider;

  APIServiceBase(this.dio, {this.tokenProvider});

  Options? _getOptionsWithAuthorization() {
    if (tokenProvider == null) {
      return null;
    }

    String? token = tokenProvider?.getToken();

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
      Options? options = _getOptionsWithAuthorization();
      Response<T> response = await dio.post(url, options: options, data: body);
      return APIResponse<T>(statusCode: response.statusCode!, body: response.data);
    } on DioException catch (error) {
        return _handleError(error);
    }
  }

  Future<APIResponse<T>> postAndDeserialize<T>(String url, Map<String, dynamic> body, T Function(dynamic json) deserialize) async {
    try {
      Options? options = _getOptionsWithAuthorization();
      Response<T> response = await dio.post(url, options: options, data: body);
      return APIResponse(statusCode: response.statusCode, body: deserialize(response.data));
    } on DioException catch (error) {
      return _handleError(error);
    }
  }



}