import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TransactionProvider({TransactionRepository? repository})
      : _repository = repository ?? TransactionRepository();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Mendapatkan stream data real-time
  Stream<List<TransactionModel>> getTransactionsStream(String userId) {
    return _repository.getUserTransactionsStream(userId);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    _setLoading(true);
    try {
      await _repository.addTransaction(transaction);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTransaction(String documentId) async {
    // Kita tidak perlu set loading penuh untuk delete agar UI terasa lebih snappy (cepat)
    try {
      await _repository.deleteTransaction(documentId);
    } catch (e) {
      rethrow;
    }
  }
}