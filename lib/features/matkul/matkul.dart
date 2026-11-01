class Matkul {
  const Matkul({required this.id, required this.nama, required this.kode, required this.dosen});
  final int id;
  final String nama;
  final String kode;
  final String dosen;

  factory Matkul.fromJson(Map<String, dynamic> j) => Matkul(
        id: j['id'] as int,
        nama: j['nama'] as String,
        kode: j['kode'] as String,
        dosen: j['dosen'] as String,
      );
}
