import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://arkividia-studytrack-be.vercel.app/api',
);

class ApiClient {
  /// [onUnauthorized] dipanggil setelah token dihapus karena 401 di endpoint
  /// non-`/auth/*` (401 di login = kredensial salah, bukan sesi habis).
  ApiClient(TokenStorage storage, {void Function()? onUnauthorized})
      : dio = Dio(BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (o, h) async {
        final token = await storage.read();
        if (token != null) o.headers['Authorization'] = 'Bearer $token';
        h.next(o);
      },
      onError: (e, h) async {
        if (e.response?.statusCode == 401 &&
            !e.requestOptions.path.startsWith('/auth')) {
          await storage.clear();
          onUnauthorized?.call();
        }
        h.next(e);
      },
    ));
  }

  final Dio dio;
}
