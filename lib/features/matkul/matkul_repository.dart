import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/providers.dart';
import 'matkul.dart';

class MatkulRepository {
  MatkulRepository(this._api);
  final ApiClient _api;

  Future<List<Matkul>> list() async {
    final res = await _api.dio.get('/mata-kuliah');
    return (res.data as List).map((e) => Matkul.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> create(String nama, String kode, String dosen) =>
      _api.dio.post('/mata-kuliah', data: {'nama': nama, 'kode': kode, 'dosen': dosen});
}

final matkulRepositoryProvider = Provider((ref) => MatkulRepository(ref.watch(apiClientProvider)));

final matkulListProvider = FutureProvider.autoDispose<List<Matkul>>(
  (ref) => ref.watch(matkulRepositoryProvider).list(),
  retry: (_, _) => null,
);
