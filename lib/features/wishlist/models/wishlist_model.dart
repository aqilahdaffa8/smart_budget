import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String userId;

  WishlistModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0, // Default 0 saat baru dibuat
    required this.deadline,
    required this.userId,
  });

  factory WishlistModel.fromMap(Map<String, dynamic> map, String documentId) {
    return WishlistModel(
      id: documentId,
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      deadline: (map['deadline'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': Timestamp.fromDate(deadline),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Menghitung persentase progress (0.0 sampai 1.0)
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final progress = currentAmount / targetAmount;
    return progress > 1.0 ? 1.0 : progress; // Maksimal 100% (1.0)
  }

  // Menghitung sisa hari
  int get remainingDays {
    final now = DateTime.now();
    final difference = deadline.difference(DateTime(now.year, now.month, now.day)).inDays;
    return difference < 0 ? 0 : difference;
  }
}