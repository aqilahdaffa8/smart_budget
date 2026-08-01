import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Makanan'; // Default kategori

  final List<String> _expenseCategories = ['Makanan', 'Transportasi', 'Tagihan', 'Hiburan', 'Lainnya'];
  final List<String> _incomeCategories = ['Gaji', 'Bonus', 'Investasi', 'Lainnya'];

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
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitTransaction() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final transaction = TransactionModel(
        id: '', // Firebase akan men-generate ID ini
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        date: _selectedDate,
        category: _selectedCategory,
        type: _selectedType,
        userId: user.uid,
      );

      try {
        await context.read<TransactionProvider>().addTransaction(transaction);
        if (!mounted) return;
        Navigator.pop(context); // Tutup modal
        SnackbarUtils.showSuccess(context, 'Transaksi berhasil ditambahkan');
      } catch (e) {
        if (!mounted) return;
        SnackbarUtils.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TransactionProvider>().isLoading;
    final categories = _selectedType == TransactionType.income 
        ? _incomeCategories 
        : _expenseCategories;

    // Pastikan kategori yang dipilih valid saat berpindah tipe
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Padding(
      // Padding dinamis agar form tidak tertutup keyboard
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
                'Tambah Transaksi',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Segmented Control untuk Income/Expense
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Pengeluaran'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Pemasukan'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _titleController,
                label: 'Nama Transaksi (Misal: Makan Siang)',
                prefixIcon: Icons.description_outlined,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _amountController,
                label: 'Nominal (Rp)',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(DateFormatter.formatToIndonesianDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Simpan Transaksi',
                isLoading: isLoading,
                onPressed: _submitTransaction,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}