# 📱 SmartBudget

**SmartBudget** adalah aplikasi manajemen keuangan pribadi dan target tabungan (*financial tracker & saving goals*) berbasis **Flutter** dan **Firebase**. Aplikasi ini dirancang menggunakan arsitektur berlapis (*clean architecture principle*), proteksi otentikasi *real-time*, sinkronisasi *cloud database*, serta kemampuan *offline caching*.

---

## 🌟 Fitur Utama

* **🔐 Autentikasi & Keamanan Data**
* Registrasi & Login pengguna berbasis **Firebase Authentication**.
* Manajemen sesi *real-time* via `AuthGate` dan proteksi data terpisah antar pengguna melalui Firestore Security Rules.


* **📊 Dashboard & Ringkasan Keuangan**
* Kalkulasi *real-time* untuk **Total Saldo**, **Pemasukan**, dan **Pengeluaran**.
* Form pencatatan cepat untuk Pemasukan & Pengeluaran dengan format mata uang otomatis (Rupiah).
* Tampilan daftar transaksi yang dinamis (fitur pembatasan 5 transaksi terakhir dengan tombol toggle *Lihat Lebih Banyak / Lebih Sedikit* tanpa *re-loading*).


* **🎯 Target Tabungan & Wishlist**
* Pembuatan target impian lengkap dengan target nominal dan kalkulasi tenggat waktu (*deadline*).
* Indikator *progress bar* visual untuk memantau pencapaian tabungan.
* **Relasi & Validasi Saldo Utama:** Sistem secara otomatis memverifikasi kecukupan saldo sebelum pengguna menabung, dan otomatis mencatat alokasi tabungan sebagai transaksi pengeluaran khusus (*Nabung*) berikon bintang amber.


* **📈 Analisis & Laporan Interaktif**
* Visualisasi distribusi pengeluaran per kategori dalam bentuk grafik *Pie Chart* interaktif (`fl_chart`).
* Fitur sentuh segmen grafik untuk melihat detail nominal dan persentase pengeluaran.


* **🎨 Pengaturan & Kustomisasi UI**
* Fitur **Dark Mode & Light Mode** yang dapat diganti secara instan via `ThemeProvider`.
* Pop-up konfirmasi dialog (*safety check*) untuk aksi sensitif seperti menghapus transaksi atau target tabungan.



---

## 🛠️ Tech Stack & Dependencies

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Backend & Database:** [Firebase Auth](https://firebase.google.com/docs/auth) & [Cloud Firestore](https://firebase.google.com/docs/firestore)
* **State Management:** [Provider](https://pub.dev/packages/provider)
* **Charts:** [fl_chart](https://pub.dev/packages/fl_chart)
* **Utilities:** `intl` (Currency & Date formatting)

---

## 📁 Struktur Proyek

```text
lib/
├── core/
│   ├── constants/       # App colors & styling
│   ├── utils/           # Formatters (Currency, Date) & Snackbar utils
│   └── widgets/         # Shared UI components (Loading indicator, dll)
├── features/
│   ├── analytics/       # Pie chart & financial analytics
│   ├── auth/            # Login, Register, & Auth Provider
│   ├── dashboard/       # Main screen & summary balance
│   ├── settings/        # Profile & Theme switcher
│   ├── transactions/    # CRUD transactions, models, & providers
│   └── wishlist/        # CRUD saving goals & allocation logic
└── shared/
    └── providers/       # Global providers (Theme, dll)

```

---

## 🚀 Cara Menjalankan Proyek (Getting Started)

### Prasyarat

1. Terinstal [Flutter SDK](https://docs.flutter.dev/get-started/install) versi terbaru.
2. Terinstal [Android Studio](https://developer.android.com/studio) atau VS Code dengan ekstensi Flutter/Dart.
3. Proyek Firebase yang sudah dikonfigurasi (`google-services.json` untuk Android).

### Langkah-Langkah

1. **Clone Repository ini**
```bash
git clone https://github.com/USERNAME/smart_budget.git
cd smart_budget

```


2. **Install Dependencies**
```bash
flutter pub get

```


3. **Konfigurasi Firebase**
* Buat proyek baru di [Firebase Console](https://console.firebase.google.com/).
* Aktifkan **Authentication** (Email/Password) dan **Cloud Firestore**.
* Unduh file `google-services.json` dan tempatkan di folder `android/app/`.


4. **Jalankan Aplikasi**
```bash
flutter run

```



---

## 📦 Build Release APK

Untuk mengkompilasi aplikasi menjadi file APK produksi:

```bash
flutter build apk --release

```

Hasil kompilasi file APK dapat ditemukan di lokasi:

`build/app/outputs/flutter-apk/app-release.apk`
