import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/providers.dart';
import '../../core/utils/date_format.dart';
import 'tugas.dart';

class TugasRepository {
  TugasRepository(this._api);
  final ApiClient _api;

  /// Urutan & kategori dari server dipakai apa adanya.
  Future<List<Tugas>> list() async {
    final res = await _api.dio.get('/tugas');
    return (res.data as List)
        .map((e) => Tugas.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// [deadlineWib] = jam dinding WIB; dikirim sebagai UTC RFC3339.
  Map<String, dynamic> _body(String judul, String deskripsi, DateTime deadlineWib, int matkulId) => {
        'judul': judul,
        'deskripsi': deskripsi,
        'deadline': wibToUtc(deadlineWib).toIso8601String(),
        'matkul_id': matkulId,
      };

  Future<void> create(String judul, String deskripsi, DateTime deadlineWib, int matkulId) =>
      _api.dio.post('/tugas', data: _body(judul, deskripsi, deadlineWib, matkulId));

  Future<void> update(int id, String judul, String deskripsi, DateTime deadlineWib, int matkulId) =>
      _api.dio.put('/tugas/$id', data: _body(judul, deskripsi, deadlineWib, matkulId));

  Future<void> setStatus(int id, TugasStatus status) =>
      _api.dio.patch('/tugas/$id/status', data: {'status': status.name});
}

final tugasRepositoryProvider =
    Provider((ref) => TugasRepository(ref.watch(apiClientProvider)));

// retry dimatikan agar error tampil segera (default Riverpod 3 mengulang).
final tugasListProvider = FutureProvider.autoDispose<List<Tugas>>(
  (ref) => ref.watch(tugasRepositoryProvider).list(),
  retry: (_, _) => null,
);
