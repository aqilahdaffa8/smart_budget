import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/widgets/add_transaction_modal.dart';
import '../../transactions/widgets/transaction_card.dart';

// Import Navigasi
import '../../analytics/screens/analytics_screen.dart';
import '../../wishlist/screens/wishlist_screen.dart';
import '../../settings/screens/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Variabel kontrol "Lihat Lebih Banyak"
  bool _showAllTransactions = false;
  
  // Variabel untuk menyimpan aliran data (Stream) agar tidak ter-reset
  late Stream<List<TransactionModel>> _transactionsStream;

  @override
  void initState() {
    super.initState();
    // Membuka koneksi stream HANYA SATU KALI saat layar dirender pertama kali
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _transactionsStream = context.read<TransactionProvider>().getTransactionsStream(user.uid);
    } else {
      _transactionsStream = const Stream.empty();
    }
  }

  void _showAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddTransactionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final transactionProvider = context.read<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartBudget', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => const AnalyticsScreen())
            ),
          ),
          IconButton(
            icon: const Icon(Icons.savings_outlined),
            onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => const WishlistScreen())
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => const SettingsScreen())
            ),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          : StreamBuilder<List<TransactionModel>>(
              stream: _transactionsStream, // Menggunakan stream yang sudah di-cache
              builder: (context, snapshot) {
                // Tampilkan loading HANYA JIKA belum ada data sama sekali di memori
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const LoadingIndicator(message: 'Memuat data keuangan...');
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }

                // Ambil semua data transaksi dari database
                final allTransactions = snapshot.data ?? [];
                
                // Kalkulasi Saldo (Harus menggunakan semua data, bukan yang dipotong)
                double totalIncome = 0;
                double totalExpense = 0;
                for (var t in allTransactions) {
                  if (t.type == TransactionType.income) totalIncome += t.amount;
                  else totalExpense += t.amount;
                }
                double balance = totalIncome - totalExpense;

                // Logika Pembatasan 5 Transaksi
                final bool hasMoreThan5 = allTransactions.length > 5;
                final displayedTransactions = (hasMoreThan5 && !_showAllTransactions)
                    ? allTransactions.take(5).toList() 
                    : allTransactions;

                return CustomScrollView(
                  slivers: [
                    // Header Summary Saldo
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Total Saldo',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.convertToIdr(balance),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSummaryItem(context, 'Pemasukan', totalIncome, AppColors.income),
                                _buildSummaryItem(context, 'Pengeluaran', totalExpense, AppColors.expense),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    
                    // Judul List Transaksi
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          'Transaksi Terakhir',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    // Jika List Transaksi Kosong
                    if (allTransactions.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text('Belum ada transaksi. Yuk catat keuanganmu!'),
                          ),
                        ),
                      ),

                    // Render List Transaksi yang sudah difilter (maksimal 5 atau semua)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final transaction = displayedTransactions[index];
                          return TransactionCard(
                            transaction: transaction,
                            onDelete: () async {
                              try {
                                await transactionProvider.deleteTransaction(transaction.id);
                                if (!context.mounted) return;
                                SnackbarUtils.showSuccess(context, 'Transaksi dihapus');
                              } catch (e) {
                                if (!context.mounted) return;
                                SnackbarUtils.showError(context, e.toString());
                              }
                            },
                          );
                        },
                        childCount: displayedTransactions.length,
                      ),
                    ),

                    // Tombol Dinamis "Lihat Lebih Banyak / Sedikit"
                    if (hasMoreThan5)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showAllTransactions = !_showAllTransactions;
                              });
                            },
                            icon: Icon(
                              _showAllTransactions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            ),
                            label: Text(
                              _showAllTransactions ? 'Lihat Lebih Sedikit' : 'Lihat Lebih Banyak',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      
                    // Spasi tambahan di bawah agar item terbawah tidak tertutup FloatingActionButton
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget Helper untuk kotak Pemasukan & Pengeluaran
  Widget _buildSummaryItem(BuildContext context, String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.convertToIdr(amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }
}