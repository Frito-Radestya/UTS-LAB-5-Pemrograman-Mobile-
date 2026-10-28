# KAGE — The Quiz Sanctuary: Spesifikasi Desain untuk Agent AI

> Dokumen ini mendeskripsikan 2 gambar rancangan desain aplikasi **KAGE**.
> Gambar 1 = "Alur Aplikasi & Tampilan Halaman" + Design System + daftar file Flutter.
> Gambar 2 = Konsep aplikasi + 12 layar + aset + struktur folder.
> Platform target: **Flutter** (mobile, portrait). Bahasa UI: **Indonesia**.

---

## 1. Konsep Aplikasi

| Item | Isi |
|---|---|
| Nama | KAGE |
| Subjudul | The Quiz Sanctuary |
| Tema visual | Sinematik, terinspirasi kuil Jepang malam hari: gerbang torii merah, lentera, bulan purnama, kelopak sakura, langit biru gelap |
| Tagline | "Kuis bukan sekadar permainan, tapi perjalanan untuk menjadi versi terbaik dari dirimu." |
| Kutipan footer | "Pengetahuan adalah cahaya, dan setiap jawaban adalah langkah menuju kebenaran." |
| Slogan Inggris | "Small Steps, Greater Knowledge" |
| Teks Jepang | 知の道 (jalan pengetahuan) |
| Mode | Dark mode (default, ada toggle di Pengaturan) |

**Fitur utama:**
1. Berbagai kategori kuis (Sains, Teknologi, Sejarah, Logika, Pengetahuan Umum)
2. Sistem skor dan badge (tantang diri, kumpulkan pencapaian, lihat progres)
3. Desain sinematik (visual Jepang yang khas)

---

## 2. Design System

### 2.1 Warna

| Nama | Hex | Penggunaan |
|---|---|---|
| Primary / Vermilion | `#B9232C` | Tombol utama, progress bar, jawaban terpilih, tab aktif |
| Dark / Midnight | `#0B0D12` | Background utama |
| Surface / Charcoal | `#171A22` | Kartu, input, panel |
| Gold / Antique Gold | `#C9A56A` | Aksen, ikon level, badge, ornamen, bingkai |
| Text / Ivory | `#E8E4DD` | Teks utama (gambar 1 menulis `#EBE4DD`, selisih sangat kecil; pakai `#E8E4DD`) |
| Muted | `#777C88` | Teks sekunder, placeholder, tab tidak aktif |

### 2.2 Tipografi — font **Onest**

| Gaya | Ukuran/Line height | Berat |
|---|---|---|
| H1 | 28/36 | Bold |
| H2 | 22/32 | SemiBold |
| H3 | 18/26 | SemiBold |
| Body | 16/24 | Regular |
| Caption | 14/20 | Regular |

Font file: `Onest-Regular.ttf`, `Onest-Medium.ttf` (disebut di gambar 2), `Onest-SemiBold.ttf`, `Onest-Bold.ttf`.
Logo "KAGE" memakai huruf serif berspasi lebar berwarna gading/emas (bukan Onest); bisa dipakai sebagai gambar `logo.png`.

### 2.3 Komponen UI

| Komponen | Deskripsi |
|---|---|
| Button Primary | Fill merah `#B9232C`, teks putih/gading, sudut membulat |
| Button Outline | Transparan, border tipis (gading/muted), teks gading |
| Input Field | Background Surface, border tipis, ikon di kiri (user/email/gembok), placeholder Muted, ikon mata di kanan untuk password |
| Card Kategori | Surface, ikon bulat di kiri, judul + "10 soal • Pemula - Ahli", chevron di kanan |
| Badge | Pill kecil: abu-abu (level, mis. "Pemula") dan hijau (status, mis. "Tersedia") |
| Progress Bar | Track gelap, fill merah |
| Tab / Bottom Nav | 4 item: **Beranda, Kuis, Riwayat (gambar 2: "Skor"), Profil**; aktif = merah, tidak aktif = muted |

---

## 3. Daftar Layar

### Gambar 1: 9 layar (Splash, Login, Register, Beranda, Kategori, Kuis, Hasil, Riwayat, Profil)

| # | Layar | Detail |
|---|---|---|
| 1 | **Splash Screen** | Latar torii + bulan + sakura. Logo "KAGE", subjudul "The Quiz Sanctuary", progress bar tipis merah di bawah. Tagline di versi besar. |
| 2 | **Login** | Judul "Masuk ke Akun". Input: "Email atau Username", "Password". Tombol "Masuk" (merah). Link "Lupa password?". Pemisah "Atau masuk dengan" → tombol Google dan Apple. Footer "Belum punya akun? Daftar". |
| 3 | **Register** | Judul "Daftar Akun". Input: Nama Lengkap, Email, Password. Tombol "Daftar". Footer "Sudah punya akun? Masuk". |
| 4 | **Beranda / Home** | Sapaan "Halo, Frito 👋" + avatar. Kartu level ("Level 3"). Kartu hero "Lanjutkan Petualangan" (Sains - Level 2) dengan tombol "Lanjut". Statistik: Total Kuis 10, Akurasi 78%, Streak 3. Baris ikon kategori (Sains, Teknologi, Sejarah, Logika, Umum). Bottom nav. |
| 5 | **Kategori Kuis** | Header "Pilih Kategori" + tombol back. Tab segmen: Semua / Tersedia. Daftar 5 kartu kategori. |
| 6 | **Halaman Kuis** | Header: progress bar merah + "3/10". Soal: "Apa nama galaksi tempat kita berada?" Pilihan A Andromeda, B Bima Sakti (terpilih, border emas/teal + ikon radio), C Triangulum, D Sombrero. Tombol "Selanjutnya". |
| 7 | **Hasil Kuis** | Emblem bunga sakura emas bercahaya. "Hebat!" + "Kamu menyelesaikan skor" → **80 dari 100**. Statistik: Benar 8, Salah 2, Waktu 04:32. Tombol "Coba Lagi" (merah) dan "Kembali ke Beranda" (outline). |
| 8 | **Riwayat Kuis** | Judul "Riwayat Kuis". Tab: Semua / Sains / Riwayat. Daftar item: ikon kategori, nama, tanggal, skor. |
| 9 | **Profil** | Avatar, nama "Frito Radestya S.", "Level 3 • 1,250 XP". Tombol "Statistik". Menu: Ubah Profil, Pengaturan, Bantuan, Keluar. |

### Gambar 2: 12 layar (versi lebih lengkap; **gunakan ini sebagai acuan utama untuk konten dan alur**)

| # | Layar | Detail |
|---|---|---|
| 1 | **Login** | Latar torii + sakura. Logo lingkaran merah dengan bunga di atas "KAGE". Judul "Selamat Datang", sub "Masuk untuk melanjutkan perjalanan pengetahuanmu." Tombol "Masuk" (merah), "Daftar" (outline). "atau masuk dengan" → ikon Google dan satu ikon sosial lain. Footer "Belum punya akun? Daftar". |
| 2 | **Register** | Back arrow. Judul "Buat Akun", sub "Mulai perjalanan pengetahuanmu bersama KAGE." Input: Nama Lengkap, Email, Password. Tombol "Daftar". "Sudah punya akun? Masuk". |
| 3 | **Beranda** | "Halo, Frito 👋" + "Terus belajar, terus berkembang." + avatar. Kartu **Progres Belajar**: "3 / 5 Kategori", bar merah, 60%. Kartu hero gambar kuil + "Lanjutkan Petualangan / Teknologi • 3/10" + tombol bulat merah play. Bagian "Kategori Kuis" + link "Lihat Semua" + 5 ikon kategori bulat. Bottom nav: Beranda, Kuis, Skor, Profil. |
| 4 | **Pilih Kategori** | Judul "Pilih Kategori", sub "Tantang pengetahuanmu di berbagai bidang." 5 kartu dengan ikon berwarna per kategori, "10 soal • Pemula - Ahli", chevron: Sains, Teknologi, Sejarah, Logika, Pengetahuan Umum. |
| 5 | **Halaman Kuis** | Back + progress bar merah + "3/10". Soal: "Apa nama planet yang dikenal sebagai Planet Merah?" A Jupiter, **B Mars (terpilih, merah)**, C Venus, D Saturnus. Latar bawah lentera/lilin. Tombol "Simpan" (outline). |
| 6 | **Hasil Kuis** | Emblem sakura emas. "Kamu Hebat!" • "Skor Akhir **80**" • "8/10 Benar". Dua kartu: Waktu 02:45, Akurasi 80%. Kutipan "Pengetahuan adalah cahaya yang tak pernah padam." Tombol "Coba Lagi", "Kembali ke Beranda". |
| 7 | **Skor & Profil** | Avatar foto, "Frito Radestya S.", "Level 3 • Pembelajar". Tab: **Riwayat** / Badge / Statistik. Daftar: Teknologi 80 (08 Okt 2025, 02:45), Sains 100 (06 Okt 2025, 02:12), Sejarah 70 (04 Okt 2025, 03:01), Logika 90 (03 Okt 2025, 02:57). |
| 8 | **Detail Kategori (Sains)** | Gambar hero astrolab emas. Deskripsi "Jelajahi misteri alam semesta, tubuh manusia, dan fenomena sains lainnya." Chip level: Pemula (aktif hijau), Menengah, Ahli. Baris: "10 Soal", "Skor Terbaik 90". Tombol "Mulai". |
| 9 | **Penjelasan Jawaban** | Kartu hijau "Benar!" + "Jawaban yang benar: B. Mars" + penjelasan (warna merah karena oksida besi). Kartu "Fakta Menarik": Olympus Mons ±22 km. Tombol "Lanjutkan". |
| 10 | **Riwayat Skor** | Filter chip: Semua, Sains, Teknologi, Sejarah. Daftar skor (Teknologi 80, Sains 100, Sejarah 70, Logika 90) dengan tanggal dan durasi. Bottom nav, tab "Skor" aktif. |
| 11 | **Badge & Pencapaian** | Grid/daftar badge emas: **First Quiz** (selesaikan kuis pertama), **Perfect 10** (dapatkan 100% benar), **Streak 7** (main selama 7 hari berturut-turut), **Explorer** (selesaikan semua kategori). |
| 12 | **Pengaturan** | Avatar + nama + email (frito@example.com). Menu: Edit Profil, Ubah Password, Notifikasi, **Tema (Dark Mode) toggle ON**, Bantuan, Tentang Aplikasi. Tombol "Logout" (merah). |

---

## 4. Konten Kategori Kuis

| Kategori | Cakupan | Level | Jumlah soal |
|---|---|---|---|
| Sains | Antariksa, tubuh manusia, energi, lingkungan | Pemula - Ahli | 10 soal |
| Teknologi | Internet, AI, keamanan digital, inovasi | Pemula - Ahli | 10 soal |
| Sejarah | Peradaban, penemuan, sejarah Indonesia | Pemula - Ahli | 10 soal |
| Logika | Pola angka, deduksi, penalaran | Pemula - Ahli | 10 soal |
| Pengetahuan Umum | Geografi, budaya, fakta dunia | Pemula - Ahli | 10 soal |

Setiap kategori punya ikon bulat berwarna sendiri (Sains: astrolab/oranye-biru, Teknologi: chip biru, Sejarah: kuil emas, Logika: kristal ungu, Umum: bunga/globe hijau).

---

## 5. Aset Desain yang Dibutuhkan

| Kelompok | Aset | Spesifikasi |
|---|---|---|
| Background | `bg_hero.jpg`, `bg_login.jpg`, `bg_category.jpg` | Hero 1920x1080, resolusi tinggi |
| Ikon kategori | `sains.png`, `teknologi.png`, `sejarah.png`, `logika.png`, `umum.png` | PNG 512x512, ikon + ilustrasi per kategori |
| Badge | `badge_gold.png`, `badge_silver.png` (+ First Quiz, Perfect Score, Streak 7, Master) | PNG |
| Dekorasi | `sakura_petals.png`, `gold_frame.png`, `torii.png`, `cloud.png`, ornamen emas, lentera | PNG transparan |
| Ikon pendukung | Ikon navigasi, sosial media (Google dll), panah, dekorasi | PNG/vektor |
| Logo | `logo.png`, `icon_*.png` | PNG |

---

## 6. Struktur Folder Flutter

```
assets/
├── images/
│   ├── bg_hero.jpg
│   ├── logo.png
│   ├── category_*.png
│   ├── badge_*.png
│   └── icon_*.png
├── decoration/
│   ├── sakura_petals.png
│   ├── gold_frame.png
│   ├── torii.png
│   └── cloud.png
└── fonts/
    ├── Onest-Regular.ttf
    ├── Onest-Medium.ttf
    ├── Onest-SemiBold.ttf
    └── Onest-Bold.ttf

lib/
├── theme/        (app_theme.dart: warna, tipografi, radius, spacing)
├── pages/        (halaman beranda, kategori, kuis, hasil, riwayat, profil)
├── widgets/      (komponen reusable)
├── models/
├── providers/
└── services/
pubspec.yaml      (daftar aset dan font)
```

---

## 7. Langkah Implementasi (urutan yang disarankan di gambar)

1. **Update theme** di `lib/theme/app_theme.dart`: warna, tipografi, radius, spacing.
2. **Tambah aset**: simpan di `assets/`, daftarkan di `pubspec.yaml`.
3. **Update layout**: halaman beranda, kategori, kuis, hasil, riwayat, profil.
4. **Tambah animasi & transisi**: fade, slide, scale (pakai `flutter_animate` atau animation controller).
5. **Test & optimasi**: `flutter analyze`, `flutter test`, cek layout di berbagai ukuran layar.

---

## 8. Catatan Perbedaan Antar Gambar

| Hal | Gambar 1 | Gambar 2 | Saran |
|---|---|---|---|
| Layar Login | Form langsung (email/username + password + Google/Apple) | Layar "Selamat Datang" dengan tombol Masuk/Daftar | Ikuti gambar 2, form login detail dari gambar 1 |
| Nama tab ke-3 | "Riwayat" | "Skor" | Pilih salah satu; samakan di seluruh app |
| Jumlah layar | 9 | 12 (tambah Detail Kategori, Penjelasan Jawaban, Badge, Pengaturan) | Implementasikan 12 layar |
| Statistik Hasil | Benar / Salah / Waktu | Waktu / Akurasi | Gabungkan: skor, benar/salah, waktu, akurasi |
| Soal contoh | Galaksi (Bima Sakti) | Planet Merah (Mars) | Hanya contoh konten, bukan fitur |

> Semua teks, nama, dan angka (mis. "Frito Radestya S.", skor 80, tanggal Okt 2025) adalah **data contoh**, bukan nilai tetap.
