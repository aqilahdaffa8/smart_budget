import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateFormatter {
  /// WAJIB dipanggil di main.dart untuk inisialisasi lokal data Indonesia
  static Future<void> initialize() async {
    await initializeDateFormatting('id_ID', null);
  }

  /// Format: 25 Agustus 2026
  static String formatToIndonesianDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  /// Format: Agustus 2026 (Untuk filter Dashboard)
  static String formatToMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  /// Format: Hari, dd MMM yyyy (Senin, 25 Agt 2026)
  static String formatWithDay(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(date);
  }
}