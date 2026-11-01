# Desain UI StudyTrack — referensi untuk implementasi frontend

File `.html` di folder ini adalah **sumber desain** (mockup) dari canvas "StudyTrack UI".
Ini bukan kode produksi: markup-nya memakai format canvas (`<x-dc>`, `<helmet>`, style inline).
Pakai sebagai acuan visual & struktur, lalu implementasikan ulang di `frontend/` dengan React + Tailwind.

| File | Layar | Route usulan |
|---|---|---|
| `Login.html` / `MobileLogin.html` | Masuk | `/login` |
| `Main.html` / `MobileTugas.html` | Daftar Tugas (layar utama) | `/` atau `/tugas` |
| `FormTugas.html` / `MobileForm.html` | Tambah / Edit Tugas | `/tugas/baru`, `/tugas/$id/edit` |
| `MataKuliah.html` / `MobileMatkul.html` | Mata Kuliah | `/matkul` |
| `CardStates.html` | 3 kondisi `TaskCard` (normal / mendekati / overdue) | — (acuan komponen) |

Desktop (≥ 768 px): sidebar kiri. Mobile (< 768 px): header atas + tab bar bawah + FAB.
Token warna, tipografi, dan spesifikasi komponen: `../UI_SPEC_FIGMA.md`.

## Aturan penting
- Frontend **tidak menghitung** kategori deadline. Baca `deadline_category` dari `GET /api/tugas`
  (`"mendekati" | "overdue" | "normal"`) dan tampilkan sesuai urutan dari API.
- Teks "Sisa X jam" / "Terlambat X jam" dihitung di frontend hanya untuk label tampilan, dari `deadline` dan waktu sekarang.
- Deadline ditampilkan dalam WIB (`Asia/Jakarta`).
- Elemen yang bisa diklik minimal 44 px; input mobile font 16 px.
