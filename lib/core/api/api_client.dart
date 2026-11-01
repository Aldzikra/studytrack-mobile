import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://arkividia-studytrack-be.vercel.app/api',
);

class ApiClient {
  ApiClient(TokenStorage storage)
      : dio = Dio(BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
        )) {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) async {
      final token = await storage.read();
      if (token != null) o.headers['Authorization'] = 'Bearer $token';
      h.next(o);
    }));
  }

  final Dio dio;
}
