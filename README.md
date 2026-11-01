# StudyTrack Mobile

Aplikasi Flutter untuk StudyTrack: pantau tugas kuliah, deadline mendekati naik ke paling atas.

- Backend & web: repo `arkivida-studytrack` (satu repo terpisah dari ini)
- API produksi: `https://arkividia-studytrack-be.vercel.app/api`
- Kontrak API & desain: [docs/MOBILE_PLAN.md](docs/MOBILE_PLAN.md)

## Screenshot

| Login | Daftar Tugas | Tambah Tugas |
|---|---|---|
| _placeholder_ | _placeholder_ | _placeholder_ |

## Menjalankan

```bash
flutter pub get
flutter run                                   # memakai URL API produksi
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api   # backend lokal (emulator Android)
```

`API_BASE_URL` opsional; default ke API produksi di atas.
Request pertama bisa lambat beberapa detik (cold start backend/database).

## Build APK release

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://arkividia-studytrack-be.vercel.app/api
```

Hasil: `build/app/outputs/flutter-apk/app-release.apk`.
APK ini masih ditandatangani dengan kunci debug (cukup untuk dibagikan/uji, belum untuk Play Store).

## Tes

```bash
flutter analyze
flutter test
```

## Checklist uji manual

- [ ] Register akun baru (password ≥ 8) → diarahkan ke Login
- [ ] Login → masuk ke Daftar Tugas; kredensial salah menampilkan pesan error
- [ ] Tambah mata kuliah; kode duplikat menampilkan "Kode mata kuliah sudah dipakai."
- [ ] Tambah tugas dengan deadline < 24 jam → muncul paling atas, border oranye + badge "Sisa X jam"
- [ ] Tugas lewat deadline → abu, border putus-putus, tanggal dicoret, badge "Terlambat X jam"
- [ ] Tandai selesai → penanda mendekati/terlambat hilang; "Batalkan" mengembalikan
- [ ] Edit tugas (tombol pensil) → perubahan tampil di daftar
- [ ] Tarik untuk refresh; matikan internet → pesan error + "Coba lagi"
- [ ] Logout (tab Keluar) → kembali ke Login; buka ulang app tetap di Login
