import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/wishlist_model.dart';
import '../providers/wishlist_provider.dart';

class AddWishlistModal extends StatefulWidget {
  const AddWishlistModal({super.key});

  @override
  State<AddWishlistModal> createState() => _AddWishlistModalState();
}

class _AddWishlistModalState extends State<AddWishlistModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30)); // Default +1 Bulan

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final targetAmount = double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), ''));

      final wishlist = WishlistModel(
        id: '',
        title: _titleController.text.trim(),
        targetAmount: targetAmount,
        deadline: _selectedDate,
        userId: user.uid,
      );

      try {
        await context.read<WishlistProvider>().addWishlist(wishlist);
        if (!mounted) return;
        Navigator.pop(context);
        SnackbarUtils.showSuccess(context, 'Target tabungan berhasil dibuat');
      } catch (e) {
        if (!mounted) return;
        SnackbarUtils.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<WishlistProvider>().isLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Buat Target Tabungan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _titleController,
                label: 'Nama Impian (Misal: Beli Laptop Baru)',
                prefixIcon: Icons.star_border,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _amountController,
                label: 'Target Nominal (Rp)',
                prefixIcon: Icons.track_changes,
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Target Tanggal Tercapai',
                    prefixIcon: const Icon(Icons.event_available),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(DateFormatter.formatToIndonesianDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Simpan Target',
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}