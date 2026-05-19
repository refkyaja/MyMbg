# Aplikasi Pendataan MBG (Makanan Bergizi Gratis)

Aplikasi Pendataan MBG adalah sebuah aplikasi multi-platform (Android, iOS, Web, Desktop) yang dibangun menggunakan kerangka kerja (framework) **Flutter**. Aplikasi ini bertujuan untuk memudahkan pendataan, pemantauan, dan manajemen program Makanan Bergizi Gratis.

Aplikasi ini menggunakan Firebase (Cloud Firestore) sebagai sistem database utama serta dilengkapi fitur untuk mengekspor laporan dalam format PDF dan Excel.

## 📱 Fitur Utama

Aplikasi ini dibagi menjadi beberapa peran (Role) utama, yaitu **Admin** dan **Public/Pengguna**:

### Fitur Autentikasi
- Pemilihan peran (Role Selection) sebelum masuk (Admin atau Siswa).
- Halaman Login yang aman.

### Fitur Admin
- **Dashboard Admin**: Ringkasan data program MBG yang sedang berjalan.
- **Manajemen Kelas**: Mengelola data kelas dan distribusi per kelas.
- **Manajemen Menu**: Mengelola data menu makanan beserta informasi nilai gizinya (Nutrition Info).
- **Pemantauan (Monitoring)**: Memantau proses distribusi makanan secara langsung.
- **Riwayat & Laporan**: Melihat riwayat pendataan dan mengekspor laporan ke format **PDF** maupun **Excel**.
- **Profil Admin**: Manajemen profil administrator.

### Fitur Public / Pengguna
- **Beranda (Home)**: Informasi umum program MBG.
- **Pengambilan (Pickup)**: Proses konfirmasi pengambilan makanan bergizi.
- **Pengembalian (Return)**: Proses konfirmasi pengembalian wadah/tempat makanan.

## 📂 Struktur Folder (Folder Structure)

Struktur kode (Source Code) di dalam folder `lib/` disusun secara modular:

```text
lib/
│
├── models/         # Model data (ClassRoom, MenuData, NutritionInfo, TrackingRecord, dll.)
├── screens/        # Halaman/UI Aplikasi
│   ├── admin/      # Halaman khusus Admin (Dashboard, Menu, History, Classes, dll.)
│   ├── auth/       # Halaman Autentikasi (Login, Role Selection)
│   └── public/     # Halaman khusus Public (Home, Pickup, Return)
├── services/       # File service untuk logika bisnis (AppState, MockDataService)
├── utils/          # Konstanta, tema, format warna, dan helper (ReportGenerator, FileSaver)
├── widgets/        # Komponen UI yang dapat digunakan kembali (Reusable widgets)
├── main.dart       # Titik awal jalannya aplikasi (Entry point)
└── firebase_options.dart # Konfigurasi Firebase
```

## 🛠️ Teknologi & Library yang Digunakan

- **Flutter**: Framework UI.
- **Firebase Core & Cloud Firestore**: Backend dan Database (NoSQL).
- **file_picker**: Untuk memilih dan menyimpan file di perangkat.
- **pdf**: Menghasilkan dokumen laporan berformat PDF.
- **excel**: Menghasilkan dokumen laporan berformat Excel.

## 🚀 Cara Menjalankan Aplikasi (Instructions / How to Use)

### Prasyarat (Prerequisites)
Pastikan Anda sudah menginstal:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.9.2 atau lebih baru)
- IDE (VS Code, Android Studio, dll.)
- Emulator atau perangkat fisik untuk pengujian.

### Langkah-langkah (Steps)
1. **Clone/Buka Project**:
   Buka folder project ini di terminal atau IDE pilihan Anda.
   
2. **Unduh Dependensi**:
   Jalankan perintah berikut untuk mengunduh semua library yang dibutuhkan:
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Firebase (Opsional jika sudah dikonfigurasi)**:
   Aplikasi ini terhubung ke Firebase. Pastikan file konfigurasi (seperti `google-services.json` untuk Android atau `GoogleService-Info.plist` untuk iOS) telah disesuaikan jika ingin menggunakan database Firebase Anda sendiri.

4. **Jalankan Aplikasi**:
   Jalankan perintah berikut di terminal:
   ```bash
   flutter run
   ```
   Atau Anda bisa langsung menekan tombol *Run / Debug* di IDE Anda.

## 📝 Catatan Tambahan
Aplikasi ini sudah dipersiapkan untuk bisa menghasilkan laporan secara multi-platform karena telah dilengkapi helper penyimpanan file yang spesifik untuk Web, IO (Android/iOS), dan stub fallback.
