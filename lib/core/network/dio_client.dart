import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        queryParameters: {
          'api_key': ApiConstants.apiKey,
          'language': 'pt-BR', // Já deixa em português
        },
      ),
    );

    // Interceptor para logs (muito útil durante o desenvolvimento)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );

    // Interceptor para tratamento global de erros (podemos melhorar depois)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          // Aqui depois podemos tratar 401, 404, timeout etc de forma centralizada
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}   