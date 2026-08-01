import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/widgets/add_transaction_modal.dart';
import '../../transactions/widgets/transaction_card.dart';
import '../../wishlist/screens/wishlist_screen.dart';
import '../../analytics/screens/analytics_screen.dart'; // Tambahkan import ini di atas

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
          // Tambahkan tombol Analytics (Pie Chart) di sini
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.stars_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          )
        ],
      ),
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          : StreamBuilder<List<TransactionModel>>(
              stream: transactionProvider.getTransactionsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator(
                      message: 'Memuat data keuangan...');
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }

                final transactions = snapshot.data ?? [];

                // Kalkulasi Saldo
                double totalIncome = 0;
                double totalExpense = 0;
                for (var t in transactions) {
                  if (t.type == TransactionType.income)
                    totalIncome += t.amount;
                  else
                    totalExpense += t.amount;
                }
                double balance = totalIncome - totalExpense;

                return CustomScrollView(
                  slivers: [
                    // Header Summary
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.convertToIdr(balance),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSummaryItem(context, 'Pemasukan',
                                    totalIncome, AppColors.income),
                                _buildSummaryItem(context, 'Pengeluaran',
                                    totalExpense, AppColors.expense),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    // Judul List
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          'Transaksi Terakhir',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    // List Transaksi Kosong
                    if (transactions.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                                'Belum ada transaksi. Yuk catat keuanganmu!'),
                          ),
                        ),
                      ),

                    // List Transaksi
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final transaction = transactions[index];
                          return TransactionCard(
                            transaction: transaction,
                            onDelete: () async {
                              try {
                                await transactionProvider
                                    .deleteTransaction(transaction.id);
                                if (!context.mounted) return;
                                SnackbarUtils.showSuccess(
                                    context, 'Transaksi dihapus');
                              } catch (e) {
                                if (!context.mounted) return;
                                SnackbarUtils.showError(context, e.toString());
                              }
                            },
                          );
                        },
                        childCount: transactions.length,
                      ),
                    ),
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

  Widget _buildSummaryItem(
      BuildContext context, String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer)),
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
