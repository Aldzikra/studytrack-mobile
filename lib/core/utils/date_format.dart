const _hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// WIB = UTC+7 tetap (tanpa DST), jadi tak perlu paket timezone.
DateTime toWib(DateTime t) => t.toUtc().add(const Duration(hours: 7));

/// Contoh: "Kam, 2 Jul 2026 · 10.00"
String formatWib(DateTime t) {
  final w = toWib(t);
  final jam = w.hour.toString().padLeft(2, '0');
  final mnt = w.minute.toString().padLeft(2, '0');
  return '${_hari[w.weekday - 1]}, ${w.day} ${_bulan[w.month - 1]} ${w.year} · $jam.$mnt';
}

/// "Sisa X jam" bila deadline di depan, "Terlambat X jam" bila lewat.
/// Hanya label tampilan; bukan penentu kategori.
String deadlineLabel(DateTime deadline, [DateTime? now]) {
  final diff = deadline.difference(now ?? DateTime.now());
  final jam = diff.abs().inHours;
  final x = jam < 1 ? '<1' : '$jam';
  return diff.isNegative ? 'Terlambat $x jam' : 'Sisa $x jam';
}

/// Komponen [wall] dibaca sebagai jam dinding WIB (flag UTC/lokal diabaikan);
/// hasilnya instan UTC untuk dikirim ke API (`toIso8601String()` → RFC3339 'Z').
DateTime wibToUtc(DateTime wall) =>
    DateTime.utc(wall.year, wall.month, wall.day, wall.hour, wall.minute)
        .subtract(const Duration(hours: 7));

const _hariPanjang = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _bulanPanjang = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

String _hm(DateTime w) =>
    '${w.hour.toString().padLeft(2, '0')}.${w.minute.toString().padLeft(2, '0')}';

/// Contoh: "Kamis, 2 Juli 2026 · 09.00 WIB" (header daftar tugas).
String formatWibLong(DateTime t) {
  final w = toWib(t);
  return '${_hariPanjang[w.weekday - 1]}, ${w.day} ${_bulanPanjang[w.month - 1]} ${w.year} · ${_hm(w)} WIB';
}

/// Contoh: "Kam, 2 Jul · 10.00" (tanggal di TaskCard).
String formatWibShort(DateTime t) {
  final w = toWib(t);
  return '${_hari[w.weekday - 1]}, ${w.day} ${_bulan[w.month - 1]} · ${_hm(w)}';
}
