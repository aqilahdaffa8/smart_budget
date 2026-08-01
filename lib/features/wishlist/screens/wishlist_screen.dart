import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../models/wishlist_model.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/add_wishlist_modal.dart';

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

  void _showAddSavingsDialog(BuildContext context, WishlistModel wishlist) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              final amount = double.parse(controller.text.replaceAll(RegExp(r'[^0-9]'), ''));
              Navigator.pop(context);
              try {
                await context.read<WishlistProvider>().addSavings(wishlist.id, wishlist.currentAmount, amount);
                if (!context.mounted) return;
                SnackbarUtils.showSuccess(context, 'Tabungan berhasil ditambahkan!');
              } catch (e) {
                if (!context.mounted) return;
                SnackbarUtils.showError(context, e.toString());
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Tabungan'),
      ),
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          : StreamBuilder<List<WishlistModel>>(
              stream: wishlistProvider.getWishlistsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator(message: 'Memuat data impian...');
                }
                
                final wishlists = snapshot.data ?? [];

                if (wishlists.isEmpty) {
                  return const Center(child: Text('Belum ada target tabungan.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: wishlists.length,
                  itemBuilder: (context, index) {
                    final wishlist = wishlists[index];
                    final isCompleted = wishlist.progressPercentage >= 1.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    wishlist.title,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => wishlistProvider.deleteWishlist(wishlist.id),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  CurrencyFormatter.convertToIdr(wishlist.currentAmount),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'dari ${CurrencyFormatter.convertToIdr(wishlist.targetAmount)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: wishlist.progressPercentage,
                                minHeight: 10,
                                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                                color: isCompleted ? AppColors.income : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isCompleted ? 'Tercapai! 🎉' : 'Sisa ${wishlist.remainingDays} Hari',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted ? AppColors.income : Colors.orange,
                                  ),
                                ),
                                if (!isCompleted)
                                  TextButton.icon(
                                    onPressed: () => _showAddSavingsDialog(context, wishlist),
                                    icon: const Icon(Icons.add_circle_outline, size: 18),
                                    label: const Text('Nabung'),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                              ],
                            )
                          ],
                        ),
                      ),
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