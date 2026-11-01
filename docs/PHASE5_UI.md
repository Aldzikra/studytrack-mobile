## Fase 5 — `feature/ui-parity`

```
Kerjakan Fase 5 (feature/ui-parity). Tujuan: tampilan & motion app Flutter SAMA dengan desain mobile
dan web. Jangan ubah repository/API/logika state — hanya UI & animasi.

Referensi (WAJIB dibaca dulu):
- docs/design/MobileLogin.html, MobileTugas.html, MobileMatkul.html, MobileForm.html, CardStates.html
  → sumber kebenaran layout, ukuran, radius, warna, jarak. Samakan sedekat mungkin.
- docs/web-ref/*.tsx & index.css → implementasi web yang sudah jadi (komponen & animasi).

1. Login/Register (AuthShell): panel biru tinggi ±300 dengan radius bawah 28, logo kecil di atas,
   headline "Semua tugas kuliah, satu daftar." (extrabold 28), 3 shape dekoratif (lingkaran brand-400
   kanan atas, rounded-square cyan miring 12°, lingkaran lemon kecil). Form di bawah sesuai MobileLogin.html.
2. Daftar Tugas: header sesuai MobileTugas.html (bukan AppBar Material polos), StatCard, judul seksi,
   TaskCard 4 kondisi persis CardStates.html. FAB sesuai web (kotak 56, radius 18) bukan extended FAB
   yang menutupi card; beri padding bawah list agar card terakhir tidak tertutup FAB/tab bar.
3. Mata Kuliah & Form: samakan dengan MobileMatkul.html dan MobileForm.html.
4. Bottom tab bar sesuai MobileTabBar.tsx (ikon, label, indikator aktif, warna).
5. Motion (port dari web, buat di lib/shared/motion/):
   - AuthShell: shape1 scale 0→1 (700ms, delay 150), shape2 dari offset (60,60) rotate 40°→12° (700ms,
     delay 300), shape3 scale (500ms, delay 450); konten panel fade-up y 24→0 600ms easeOut, stagger 150ms.
   - fadeUp: opacity 0→1 + translateY 10→0, 350ms easeOut — untuk form auth, ganti halaman/tab,
     dan tiap TaskCard / item matkul dengan stagger 50ms × index (maks 8).
   - pop: FAB scale 0.6→1, 300ms Cubic(0.34,1.56,0.64,1), delay 200ms.
   - Tombol: scale 0.97 saat ditekan (transisi warna & transform).
   - Hormati reduced motion: jika MediaQuery.disableAnimations true → tanpa animasi.
6. Widget test ringan: TaskCard tiap kondisi ter-render; animasi tidak error dengan disableAnimations.

Jangan commit. Akhiri dengan flutter analyze, flutter test, daftar file, dan usulan commit bertahap.
```
