# StudyTrack Mobile — Kontrak API & Prompt per Fase

Simpan file ini di repo `studytrack-mobile` sebagai `docs/MOBILE_PLAN.md`.
Bagian **Kontrak API** dibaca Claude Code di setiap fase; bagian **Prompt** ditempel satu per satu.

---

## Kontrak API (sesuai backend yang ter-deploy)

**Base URL:** `https://arkividia-studytrack-be.vercel.app/api`
(lewat `--dart-define=API_BASE_URL=...`, default ke URL di atas)

**Auth:** header `Authorization: Bearer <token>` untuk semua endpoint kecuali `/auth/*` dan `/health`.
Token kedaluwarsa / tidak valid → **401** `{"error": "..."}`.

**Format error backend:** `{"error": "pesan"}` (string).
Error dari platform Vercel bisa berbentuk `{"error": {"code": "...", "message": "..."}}` — parser error harus menangani keduanya dan selalu menghasilkan `String`.

**Cold start:** backend & database (Neon) bisa "tidur". Request pertama bisa butuh beberapa detik → timeout minimal **20 detik**, tampilkan loading.

### Endpoint

| Method | Path | Body | Respons sukses |
|---|---|---|---|
| GET | `/health` | – | `{"status":"success","database":"connected","message":"..."}` |
| POST | `/auth/register` | `{"username","email","password"}` (password ≥ 8) | **201** objek `User` |
| POST | `/auth/login` | `{"email","password"}` | **200** `{"token": "...", "user": User}` |
| GET | `/mata-kuliah` | – | **200** `Matkul[]` |
| POST | `/mata-kuliah` | `{"nama","kode","dosen"}` | **201** `{"message","data": Matkul}` |
| PUT | `/mata-kuliah/:id` | `{"nama","kode","dosen"}` | **200** `{"message","data": Matkul}` |
| DELETE | `/mata-kuliah/:id` | – | **200** `{"message"}` |
| GET | `/tugas` | – | **200** `Tugas[]` — **sudah terurut**, berisi `deadline_category` |
| POST | `/tugas` | `{"judul","deskripsi","deadline","matkul_id"}` | **201** `{"message","data": Tugas}` |
| GET | `/tugas/:id` | – | **200** `Tugas` |
| PUT | `/tugas/:id` | `{"judul","deskripsi","deadline","matkul_id"}` | **200** `{"message","data": Tugas}` |
| PATCH | `/tugas/:id/status` | `{"status": "belum" \| "selesai"}` | **200** `{"message","data": Tugas}` |
| DELETE | `/tugas/:id` | – | **200** `{"message"}` |

Kode error lain: 400 (format salah), 404 (tidak ditemukan / milik user lain), 409 (email/kode duplikat).

### Model

```text
User   { id: String (UUID), username, email, created_at, updated_at }
Matkul { id: int, nama: String (≤50), kode: String (≤10), dosen: String (≤30) }
Tugas  { id: int, judul: String (≤30), deskripsi: String, deadline: DateTime (RFC3339, UTC),
         status: "belum" | "selesai", matkul_id: int, matkul_nama: String, created_at: DateTime,
         deadline_category?: "mendekati" | "overdue" | "normal" }   // hanya ada di GET /tugas
```

**Aturan penting:**
- Aplikasi **tidak menghitung ulang** kategori deadline. Pakai `deadline_category` dan urutan dari `GET /tugas` apa adanya.
- "Sisa X jam" / "Terlambat X jam" hanya label tampilan, dihitung dari `deadline` vs waktu sekarang.
- Kirim `deadline` dalam UTC RFC3339 (`toUtc().toIso8601String()`); tampilkan dalam **WIB (Asia/Jakarta, UTC+7)**.
- `judul` maksimal 30 karakter — validasi di form.

### Desain (sama dengan web)
Font **Plus Jakarta Sans** (`google_fonts`). Warna:
`primary #1A5FD6`, `brand #2373F4`, `sky #578EF5`, `cyan #65D0F4`, `bg #F4F7FD`, `ink #0F1B33`, `muted #55627A`, `border #DCE5F5`.
Badge: Belum `#F2F7A0`/`#4D4A00`, Selesai `#DDF4E4`/`#14632C`.
Card mendekati: border `#E2580B` 2px + badge oranye "Sisa X jam". Card overdue: latar `#F7F8FA`, border putus-putus `#8D96A8`, badge `#3A4256` "Terlambat X jam", tanggal dicoret.
Navigasi: bottom tab bar (Tugas, Mata Kuliah, Keluar) + FAB "Tambah Tugas". Elemen sentuh ≥ 44px.

---

## Aturan untuk semua fase (tempel sekali di CLAUDE.md repo mobile)

```
- Jangan pernah git commit, push, atau berpindah branch. User yang commit sendiri.
- Kerjakan HANYA cakupan fase yang diminta.
- Ikuti docs/MOBILE_PLAN.md (kontrak API & desain). Jangan mengarang endpoint/field.
- Di akhir tiap fase: jalankan `flutter analyze` dan `flutter test`, lalu beri daftar file berubah
  dan usulan commit message (Conventional Commits), dikelompokkan per commit.
```

---

## Fase 0 — `chore/setup`

```
Kerjakan Fase 0 (chore/setup) untuk StudyTrack Mobile. Baca docs/MOBILE_PLAN.md dulu.

Cakupan:
1. Tambah package: dio, flutter_secure_storage, go_router, flutter_riverpod, intl, google_fonts.
2. Struktur folder: lib/app (router, theme), lib/core (api, storage, utils), lib/features/{auth,tugas,matkul}, lib/shared/widgets.
3. Theme dari palet di MOBILE_PLAN.md (Material 3, Plus Jakarta Sans).
4. core/api: ApiClient berbasis dio — baseUrl dari --dart-define API_BASE_URL (default URL di kontrak),
   timeout 20 detik, interceptor menambah Bearer token dari secure storage,
   fungsi parseApiError(Object) yang SELALU mengembalikan String (tangani kedua format error).
5. core/utils: format tanggal WIB (mis. "Kam, 2 Jul 2026 · 10.00") dan helper "Sisa X jam"/"Terlambat X jam".
6. Layar sementara yang memanggil GET /health dan menampilkan hasilnya (untuk cek koneksi).
7. Unit test untuk parseApiError dan helper tanggal.

Jangan commit. Akhiri dengan flutter analyze, flutter test, daftar file, dan usulan commit.
```

## Fase 1 — `feature/auth`

```
Kerjakan Fase 1 (feature/auth). Ikuti kontrak di docs/MOBILE_PLAN.md.

Cakupan:
1. Model User + AuthRepository: login (POST /auth/login → simpan token & user), register (POST /auth/register), logout (hapus token).
2. State auth dengan Riverpod; saat app dibuka, cek token tersimpan.
3. Layar Login & Register sesuai desain (panel biru atas, form, tombol penuh). Validasi: email valid, password ≥ 8.
4. go_router redirect: belum login → /login; sudah login → /tugas (placeholder dulu).
5. Respons 401 dari API mana pun → hapus token dan kembali ke /login.
6. Shell navigasi: bottom tab bar (Tugas, Mata Kuliah, Keluar) dengan halaman placeholder.
7. Tes widget sederhana untuk validasi form login.

Jangan commit. Akhiri dengan flutter analyze, flutter test, daftar file, dan usulan commit.
```

## Fase 2 — `feature/daftar-tugas`

```
Kerjakan Fase 2 (feature/daftar-tugas). Ikuti kontrak & desain di docs/MOBILE_PLAN.md.

Cakupan:
1. Model Tugas (termasuk deadline_category opsional) + TugasRepository: GET /tugas, PATCH /tugas/:id/status.
2. Halaman Daftar Tugas:
   - 3 StatCard (Mendekati, Terlambat, Lainnya) dihitung dari deadline_category.
   - Seksi Mendekati → Terlambat → Lainnya; urutan item PERSIS seperti dari API (jangan sort ulang).
   - TaskCard 4 kondisi: normal, mendekati, overdue, selesai (lihat desain).
   - Tombol "Tandai selesai"/"Batalkan" → PATCH status lalu refresh daftar.
   - Pull-to-refresh, loading state, empty state, error state (pakai parseApiError).
3. JANGAN menghitung kategori di aplikasi; hanya label "Sisa/Terlambat X jam" yang dihitung untuk tampilan.
4. Unit test: mapping deadline_category → gaya card, dan parsing JSON Tugas.

Jangan commit. Akhiri dengan flutter analyze, flutter test, daftar file, dan usulan commit.
```

## Fase 3 — `feature/tambah-tugas`

```
Kerjakan Fase 3 (feature/tambah-tugas). Ikuti kontrak di docs/MOBILE_PLAN.md.

Cakupan:
1. Model Matkul + MatkulRepository: GET /mata-kuliah, POST /mata-kuliah.
2. Halaman Mata Kuliah: daftar + form tambah (nama ≤50, kode ≤10, dosen ≤30); tangani 409 kode duplikat.
3. Form Tambah/Edit Tugas (dibuka dari FAB dan dari tombol edit card):
   judul (≤30), mata kuliah (dropdown dari GET /mata-kuliah), deskripsi opsional, tanggal + jam (input WIB).
   Kirim deadline sebagai UTC RFC3339. POST /tugas atau PUT /tugas/:id.
   Info box: "Saat sisa waktunya kurang dari 24 jam, tugas ini otomatis ditandai dan naik ke paling atas."
4. Setelah simpan, kembali ke Daftar Tugas dan refresh.
5. Tes konversi WIB → UTC.

Jangan commit. Akhiri dengan flutter analyze, flutter test, daftar file, dan usulan commit.
```

## Fase 4 — `chore/release`

```
Kerjakan Fase 4 (chore/release).

Cakupan:
1. Nama aplikasi "StudyTrack", ikon aplikasi (flutter_launcher_icons) memakai warna brand #2373F4.
2. Pastikan izin INTERNET di AndroidManifest.
3. README: cara run (--dart-define API_BASE_URL), link repo web & backend, screenshot placeholder.
4. Build APK release: flutter build apk --release --dart-define=API_BASE_URL=https://arkividia-studytrack-be.vercel.app/api
5. Checklist uji manual: register, login, tambah matkul, tambah tugas deadline < 24 jam (harus di atas, oranye),
   tugas lewat deadline (abu, dicoret), tandai selesai (penanda hilang), logout.

Jangan commit. Akhiri dengan daftar file dan usulan commit.
```

---

## Alur per fase (sama dengan repo web)

```bash
git checkout dev && git pull
git checkout -b <branch-fase>
# jalankan prompt di Claude Code, review, commit bertahap sesuai usulan
git push -u origin <branch-fase>
# PR ke dev → merge → lanjut fase berikutnya
# setelah fase 4: PR dev → main, tag v1.0.0
```
