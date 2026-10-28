# Prompt Konversi: Desain KAGE ke Flutter

Salin seluruh isi bagian "PROMPT" di bawah ke coding agent Anda.
Lampirkan juga folder paket ini dan screenshot tiap layar dari kanvas desain.

---

## Isi paket

| Lokasi | Isi |
|---|---|
| `design_source/*.dc.html` | 13 layar + 1 papan Design System. **Sumber kebenaran** untuk ukuran, warna, jarak, radius, gradien, dan teks. |
| `design_source/canvas.json` | Daftar layar dan ukurannya (390×844 untuk layar ponsel) |
| `assets/svg/` | Ilustrasi dan ikon yang sudah dipisah: torii, emblem logo, 5 ikon kategori, 5 emblem badge, astrolab |
| `KAGE_DESIGN_SPEC.md` (dari percakapan sebelumnya) | Alur layar dan struktur folder Flutter |

Yang belum ada di paket dan harus Anda sediakan:
- Font **Onest** (Regular, Medium, SemiBold, Bold) dan **Cinzel SemiBold** (hanya untuk wordmark "KAGE"), keduanya dari Google Fonts.
- Screenshot tiap layar dari kanvas desain (ekspor dari kanvas), untuk perbandingan visual.

---

## PROMPT

Kamu akan membuat ulang desain aplikasi kuis **KAGE – The Quiz Sanctuary** di Flutter, **sama persis** dengan desain di folder `design_source/`.

### 1. Aturan utama
- Tiap file `design_source/*.dc.html` adalah satu layar. Baca isinya sebagai spesifikasi: setiap `style="..."` inline adalah nilai desain yang harus ditiru (ukuran, padding, gap, radius, warna, font-size, line-height, font-weight, gradien, bayangan).
- Ukuran dasar layar ponsel: **390 × 844** (1 px CSS = 1 logical pixel Flutter). Jangan membulatkan atau "merapikan" angka.
- Jangan mengubah teks, urutan elemen, atau warna. Semua teks UI berbahasa Indonesia.
- Elemen dengan `aria-hidden="true"` hanya dekorasi; elemen dengan `aria-label` perlu `Semantics`/`semanticLabel` yang sama.

### 2. Token desain (buat di `lib/theme/app_theme.dart`)

| Token | Nilai |
|---|---|
| primary (Vermilion) | `#B9232C` |
| primaryText (merah teks, kontras di bg gelap) | `#E4545C` |
| background (Midnight) | `#0B0D12` |
| surface (Charcoal) | `#171A22` |
| border | `#232734` (kartu), `#2A2F3C` (input/divider) |
| gold | `#C9A56A` |
| text (Ivory) | `#E8E4DD` |
| textMuted | `#8B909C` |
| success | `#6FD0A0` |
| Font utama | Onest |
| Font logo | Cinzel SemiBold (hanya "KAGE") |
| H1 | 28/36 Bold |
| H2 | 22/32 SemiBold |
| H3 | 18/26 SemiBold |
| Body | 16/24 Regular |
| Caption | 14/20 Regular |
| Radius | tombol/input 12, kartu 14–16, hero card 20 |

Warna per kategori: Sains `#F0A25A`, Teknologi `#6EB6FF`, Sejarah `#E0B86A`, Logika `#B79CFF`, Pengetahuan Umum `#6FD0A0`.

Catatan Flutter: `line-height` CSS dalam px dikonversi ke `TextStyle.height = lineHeight / fontSize`.

### 3. Pemetaan HTML/CSS ke Flutter

| CSS | Flutter |
|---|---|
| `display:flex` + `flex-direction` + `gap` | `Row` / `Column` + `SizedBox` untuk jarak |
| `flex:1` | `Expanded` |
| `position:absolute` | `Stack` + `Positioned` |
| `linear-gradient` / `radial-gradient` | `LinearGradient` / `RadialGradient` pada `BoxDecoration` |
| `box-shadow` | `BoxShadow` (blur = blur CSS) |
| `border-radius`, `border` | `BorderRadius.circular`, `Border.all` |
| `opacity` | `Opacity` atau alpha warna |
| `clip-path: polygon` | `ClipPath` + `CustomClipper` |
| `background-clip:text` (wordmark emas) | `ShaderMask` dengan `LinearGradient` |
| Latar bintang (`radial-gradient` kecil) | `CustomPainter` |
| Kelopak sakura (`span` kecil berputar) | `Transform.rotate` + `Container` dengan `BorderRadius` tidak simetris |
| `overflow:hidden` | `ClipRRect` |

### 4. Aset
- SVG di `assets/svg/` dipakai lewat paket `flutter_svg`. Daftarkan di `pubspec.yaml`.
- Ikon kecil UI (home, clipboard, grafik batang, user, panah, gembok, mata, bel, bulan, dsb.) ada inline di file `.dc.html`. Salin path-nya ke `assets/svg/` atau gunakan `CustomPaint`/`Icon` yang bentuknya setara.
- Latar sinematik (langit, bulan, gunung, jalan batu, lentera) dibuat dari gradien dan bentuk sederhana di `Main.dc.html`; tiru dengan `Stack`.

### 5. Struktur dan navigasi
- Satu halaman Flutter per file `.dc.html` (`lib/pages/`).
- Link antar file (`<a href="X.dc.html">`) menjadi rute (disarankan `go_router`).
- Bottom navigation (4 item: Beranda, Kuis, Skor, Profil) dibuat satu kali sebagai widget reusable. Tinggi 72, item aktif berwarna `primaryText` dengan garis atas 2 px `primary`.
- Alur: Splash → Login → Register → Beranda → Kategori → Detail Kategori → Kuis → Penjelasan → Hasil. Dari Beranda juga ke Riwayat dan Profil. Profil → Badge dan Pengaturan. Logout → Login.

### 6. Komponen reusable
`PrimaryButton`, `OutlineButton`, `AppTextField` (ikon kiri, ikon mata untuk password), `CategoryCard`, `CategoryIcon`, `StatTile`, `ProgressBar`, `Badge/Chip`, `ScoreRow`, `BottomNav`.

### 7. Cara memverifikasi
1. Jalankan `flutter analyze` dan pastikan bersih.
2. Untuk tiap layar, jalankan di ukuran 390×844 dan bandingkan dengan screenshot dari kanvas. Perbaiki selisih jarak, ukuran, warna, atau font.
3. Opsional: buat golden test per layar (`flutter test --update-goldens`) agar perubahan visual berikutnya terdeteksi.
4. Akui hal yang tidak bisa persis sama (rendering font, blur bayangan, anti-aliasing) dan jangan mengubah desain untuk menutupinya.

### 8. Urutan kerja yang disarankan
1. Tema, font, dan aset.
2. Komponen reusable.
3. Layar satu per satu sesuai urutan alur di atas, dengan verifikasi visual tiap layar sebelum lanjut.
4. Navigasi dan transisi (fade/slide ringan).
5. `flutter analyze`, test, dan pengecekan di beberapa ukuran layar.

### 9. Batasan
- Data pada desain (nama "Frito Radestya S.", skor 80, tanggal Okt 2025, soal tentang Mars) adalah **data contoh**. Pisahkan ke model/data dummy agar mudah diganti.
- Jangan menambah fitur, layar, atau teks yang tidak ada di desain.
