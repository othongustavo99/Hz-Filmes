import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';

class ActivityRemoteDataSource {
  final Dio _dio;

  ActivityRemoteDataSource()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.backendBaseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  Future<void> addSearch(String query) async {
    try {
      await _dio.post('/activity/search', data: {'query': query});
    } catch (_) {
      // silencioso: não quebra o app se a API estiver offline
    }
  }
  

  Future<void> addClick(int movieId) async {
    try {
      await _dio.post('/activity/click', data: {'movieId': movieId});
    } catch (_) {}
  }
  
}

