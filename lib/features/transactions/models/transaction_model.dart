import 'package:cloud_firestore/cloud_firestore.dart';

// Tipe kategori untuk memudahkan filter dan warna UI nanti
enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType type;
  final String userId;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    required this.userId,
  });

  // Convert dari JSON/Map (Firestore) ke Dart Object
  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      // Mengubah Timestamp Firebase kembali ke DateTime Dart
      date: (map['date'] as Timestamp).toDate(),
      category: map['category'] ?? 'Lainnya',
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      userId: map['userId'] ?? '',
    );
  }

  // Convert dari Dart Object ke JSON/Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      // Firebase membutuhkan format Timestamp
      'date': Timestamp.fromDate(date),
      'category': category,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(), // Audit trail
    };
  }

  // Bermanfaat saat kita mau melakukan Edit/Update data sebagian
  TransactionModel copyWith({
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    TransactionType? type,
  }) {
    return TransactionModel(
      id: id, // ID tidak boleh berubah
      userId: userId, // UserID tidak boleh berubah
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
    );
  }
}