import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack_mobile/core/api/api_error.dart';

DioException _err(Object? data, {DioExceptionType type = DioExceptionType.badResponse, int? code}) {
  final o = RequestOptions(path: '/x');
  return DioException(
    requestOptions: o,
    type: type,
    response: data == null && code == null
        ? null
        : Response(requestOptions: o, data: data, statusCode: code),
  );
}

void main() {
  test('error string', () {
    expect(parseApiError(_err({'error': 'email sudah terdaftar'}, code: 409)), 'email sudah terdaftar');
  });
  test('error object (Vercel)', () {
    expect(parseApiError(_err({'error': {'code': 'X', 'message': 'gagal'}}, code: 500)), 'gagal');
  });
  test('error object tanpa message memakai code', () {
    expect(parseApiError(_err({'error': {'code': 'FUNCTION_INVOCATION_FAILED'}}, code: 500)), 'FUNCTION_INVOCATION_FAILED');
  });
  test('body bukan JSON map → fallback status', () {
    expect(parseApiError(_err('<html>', code: 502)), 'Terjadi kesalahan (502).');
  });
  test('timeout & koneksi', () {
    expect(parseApiError(_err(null, type: DioExceptionType.receiveTimeout)), contains('tidak merespons'));
    expect(parseApiError(_err(null, type: DioExceptionType.connectionError)), contains('terhubung'));
  });
  test('non-Dio selalu String', () {
    expect(parseApiError(Exception('boom')), isA<String>());
    expect(parseApiError(42), '42');
  });
}
