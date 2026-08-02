import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../models/wishlist_model.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/add_wishlist_modal.dart';

// Import tambahan untuk mengakses data Transaksi
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transaction_provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  void _showAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddWishlistModal(),
    );
  }

  // Modifikasi: Menambahkan parameter currentBalance untuk validasi
  // Modifikasi: Menggunakan nama parameter parentContext agar tidak bentrok dengan dialogContext
  void _showAddSavingsDialog(BuildContext parentContext, WishlistModel wishlist,
      double currentBalance) {
    final controller = TextEditingController();
    showDialog(
      context: parentContext, // Menggunakan context dari halaman utama
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Tabungan'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nominal (Rp)',
            prefixIcon: Icon(Icons.attach_money),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // Tutup dialog
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              final amount = double.parse(
                  controller.text.replaceAll(RegExp(r'[^0-9]'), ''));

              // 1. VALIDASI SALDO
              if (amount > currentBalance) {
                Navigator.pop(dialogContext); // Tutup dialog
                SnackbarUtils.showError(parentContext,
                    'Saldo tidak cukup! Sisa saldo Anda: ${CurrencyFormatter.convertToIdr(currentBalance)}');
                return;
              }

              // PENTING: JANGAN TUTUP DIALOG DULU DI SINI!

              try {
                // 2. TAMBAH NOMINAL KE WISHLIST (Memakai parentContext)
                await parentContext
                    .read<WishlistProvider>()
                    .addSavings(wishlist.id, wishlist.currentAmount, amount);

                // 3. CATAT SEBAGAI PENGELUARAN (Memakai parentContext)
                final user = FirebaseAuth.instance.currentUser!;
                final transaction = TransactionModel(
                  id: '',
                  title: 'target: ${wishlist.title}',
                  amount: amount,
                  date: DateTime.now(),
                  category: 'Lainnya',
                  type: TransactionType.expense,
                  userId: user.uid,
                );

                await parentContext
                    .read<TransactionProvider>()
                    .addTransaction(transaction);

                // 4. SETELAH DATABASE SELESAI, BARU TUTUP DIALOG
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);

                // 5. MUNCULKAN NOTIFIKASI
                if (!parentContext.mounted) return;
                SnackbarUtils.showSuccess(parentContext,
                    'Berhasil menabung! Saldo utama telah dipotong.');
              } catch (e) {
                // Jika terjadi error, tutup dialog dan tampilkan error
                if (dialogContext.mounted) Navigator.pop(dialogContext);

                if (!parentContext.mounted) return;
                SnackbarUtils.showError(parentContext, e.toString());
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final wishlistProvider = context.read<WishlistProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Tabungan'),
      ),
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          // 1. Stream Pertama: Mengambil Data Transaksi untuk Menghitung Saldo
          : StreamBuilder<List<TransactionModel>>(
              stream: transactionProvider.getTransactionsStream(user.uid),
              builder: (context, txSnapshot) {
                // Kalkulasi Total Saldo
                double currentBalance = 0;
                if (txSnapshot.hasData) {
                  for (var t in txSnapshot.data!) {
                    if (t.type == TransactionType.income)
                      currentBalance += t.amount;
                    else
                      currentBalance -= t.amount;
                  }
                }

                // 2. Stream Kedua: Mengambil Data Wishlist
                return StreamBuilder<List<WishlistModel>>(
                  stream: wishlistProvider.getWishlistsStream(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingIndicator(
                          message: 'Memuat data impian...');
                    }

                    final wishlists = snapshot.data ?? [];

                    return Column(
                      children: [
                        // UI Baru: Indikator Saldo Tersedia di Layar Wishlist
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Saldo Tersedia:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  )),
                              Text(
                                CurrencyFormatter.convertToIdr(currentBalance),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // List Tabungan
                        Expanded(
                          child: wishlists.isEmpty
                              ? const Center(
                                  child: Text('Belum ada target tabungan.'))
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: wishlists.length,
                                  itemBuilder: (context, index) {
                                    final wishlist = wishlists[index];
                                    final isCompleted =
                                        wishlist.progressPercentage >= 1.0;

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withOpacity(0.2)),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    wishlist.title,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                // Cari bagian ini di dalam ListView.builder / Card wishlist_screen.dart:
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.red),
                                                  onPressed: () async {
                                                    // Munculkan dialog konfirmasi pop-up
                                                    final bool? confirm =
                                                        await showDialog<bool>(
                                                      context: context,
                                                      builder: (BuildContext
                                                          dialogContext) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Hapus Target Tabungan?'),
                                                          content: Text(
                                                              'Target "${wishlist.title}" akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          dialogContext)
                                                                      .pop(
                                                                          false), // Batal
                                                              child: const Text(
                                                                  'Batal'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          dialogContext)
                                                                      .pop(
                                                                          true), // Konfirmasi Hapus
                                                              child: const Text(
                                                                'Hapus',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );

                                                    // Jika user menekan tombol "Hapus"
                                                    if (confirm == true) {
                                                      try {
                                                        await wishlistProvider
                                                            .deleteWishlist(
                                                                wishlist.id);
                                                        if (!context.mounted)
                                                          return;
                                                        SnackbarUtils.showSuccess(
                                                            context,
                                                            'Target tabungan berhasil dihapus');
                                                      } catch (e) {
                                                        if (!context.mounted)
                                                          return;
                                                        SnackbarUtils.showError(
                                                            context,
                                                            e.toString());
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  CurrencyFormatter
                                                      .convertToIdr(wishlist
                                                          .currentAmount),
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'dari ${CurrencyFormatter.convertToIdr(wishlist.targetAmount)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: LinearProgressIndicator(
                                                value:
                                                    wishlist.progressPercentage,
                                                minHeight: 10,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .surfaceVariant,
                                                color: isCompleted
                                                    ? AppColors.income
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  isCompleted
                                                      ? 'Tercapai! 🎉'
                                                      : 'Sisa ${wishlist.remainingDays} Hari',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: isCompleted
                                                        ? AppColors.income
                                                        : Colors.orange,
                                                  ),
                                                ),
                                                if (!isCompleted)
                                                  TextButton.icon(
                                                    // Lempar currentBalance ke fungsi dialog
                                                    onPressed: () =>
                                                        _showAddSavingsDialog(
                                                            context,
                                                            wishlist,
                                                            currentBalance),
                                                    icon: const Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        size: 18),
                                                    label: const Text('Nabung'),
                                                    style: TextButton.styleFrom(
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                    ),
                                                  )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddModal(context),
        child: const Icon(Icons.flag),
      ),
    );
  }
}
