import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Mengubah angka (double/int) menjadi format Rupiah (contoh: Rp 150.000)
  static String convertToIdr(dynamic amount, {int decimalDigit = 0}) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    
    // Jika menerima string, ubah dulu ke double
    if (amount is String) {
      final parsedAmount = double.tryParse(amount) ?? 0.0;
      return currencyFormatter.format(parsedAmount);
    }
    
    return currencyFormatter.format(amount);
  }
}