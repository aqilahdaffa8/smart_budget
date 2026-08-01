class AppConstants {
  // Nama Koleksi Firestore
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String wishlistCollection = 'wishlists';

  // Key SharedPreferences (jika butuh caching lokal)
  static const String themeKey = 'isDarkMode';
  
  // Pesan Error Umum
  static const String defaultErrorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
  static const String networkErrorMessage = 'Tidak ada koneksi internet.';
}