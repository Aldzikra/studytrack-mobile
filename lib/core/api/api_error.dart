import 'package:dio/dio.dart';

/// Selalu mengembalikan String. Menangani `{"error": "msg"}` dan
/// `{"error": {"code", "message"}}` (format platform Vercel).
String parseApiError(Object error) {
  if (error is DioException) {
    final msg = _fromBody(error.response?.data);
    if (msg != null) return msg;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Server tidak merespons. Coba lagi sebentar.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
      default:
        final code = error.response?.statusCode;
        return code != null ? 'Terjadi kesalahan ($code).' : 'Terjadi kesalahan.';
    }
  }
  return error.toString();
}

String? _fromBody(Object? data) {
  if (data is! Map) return null;
  final e = data['error'];
  if (e is String && e.isNotEmpty) return e;
  if (e is Map) {
    final m = e['message'];
    if (m is String && m.isNotEmpty) return m;
    final c = e['code'];
    if (c is String && c.isNotEmpty) return c;
  }
  return null;
}
