enum TugasStatus { belum, selesai }

enum DeadlineCategory { mendekati, overdue, normal }

class Tugas {
  const Tugas({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.deadline,
    required this.status,
    required this.matkulId,
    required this.matkulNama,
    required this.createdAt,
    this.category,
  });

  final int id;
  final String judul;
  final String deskripsi;
  final DateTime deadline;
  final TugasStatus status;
  final int matkulId;
  final String matkulNama;
  final DateTime createdAt;

  /// Hanya ada di GET /tugas; dari server, tidak dihitung di app.
  final DeadlineCategory? category;

  bool get selesai => status == TugasStatus.selesai;

  factory Tugas.fromJson(Map<String, dynamic> j) {
    final cat = j['deadline_category'] as String?;
    return Tugas(
      id: j['id'] as int,
      judul: j['judul'] as String,
      deskripsi: (j['deskripsi'] as String?) ?? '',
      deadline: DateTime.parse(j['deadline'] as String).toUtc(),
      status: TugasStatus.values.byName(j['status'] as String),
      matkulId: j['matkul_id'] as int,
      matkulNama: (j['matkul_nama'] as String?) ?? '',
      createdAt: DateTime.parse(j['created_at'] as String).toUtc(),
      category: cat == null ? null : DeadlineCategory.values.byName(cat),
    );
  }
}
