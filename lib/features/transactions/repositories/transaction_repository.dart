import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Mendapatkan referensi koleksi transaksi
  CollectionReference get _transactions =>
      _firestore.collection(AppConstants.transactionsCollection);

  // CREATE: Tambah Transaksi
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      // Kita tidak perlu mengirim ID, Firebase akan membuatkan auto-ID secara otomatis
      await _transactions.add(transaction.toMap());
    } catch (e) {
      throw 'Gagal menambahkan transaksi: $e';
    }
  }

  // READ (STREAM): Baca Transaksi Real-time berdasarkan User ID
  // Data otomatis diurutkan dari yang terbaru (descending)
  Stream<List<TransactionModel>> getUserTransactionsStream(String userId) {
    return _transactions
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // UPDATE: Edit Transaksi
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _transactions.doc(transaction.id).update(transaction.toMap());
    } catch (e) {
      throw 'Gagal memperbarui transaksi: $e';
    }
  }

  // DELETE: Hapus Transaksi
  Future<void> deleteTransaction(String documentId) async {
    try {
      await _transactions.doc(documentId).delete();
    } catch (e) {
      throw 'Gagal menghapus transaksi: $e';
    }
  }
}