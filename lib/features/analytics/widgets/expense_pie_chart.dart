import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../transactions/models/transaction_model.dart';

class ExpensePieChart extends StatefulWidget {
  final List<TransactionModel> transactions;

  const ExpensePieChart({super.key, required this.transactions});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int touchedIndex = -1;

  // Fungsi untuk mengelompokkan dan menjumlahkan pengeluaran per kategori
  Map<String, double> _calculateCategoryTotals() {
    Map<String, double> totals = {};
    for (var transaction in widget.transactions) {
      if (transaction.type == TransactionType.expense) {
        totals[transaction.category] = (totals[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return totals;
  }

  // Fungsi untuk memberikan warna unik pada tiap kategori
  Color _getCategoryColor(String category, int index) {
    final colors = [
      Colors.blue.shade400,
      Colors.red.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _calculateCategoryTotals();

    if (categoryTotals.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: Text('Belum ada data pengeluaran untuk ditampilkan.'),
        ),
      );
    }

    final totalExpense = categoryTotals.values.fold(0.0, (sum, item) => sum + item);

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: _buildPieChartSections(categoryTotals, totalExpense),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Legend (Keterangan Warna Kategori)
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: categoryTotals.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value.key;
            final amount = entry.value.value;
            final percentage = (amount / totalExpense * 100).toStringAsFixed(1);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getCategoryColor(category, index),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$category ($percentage%)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> categoryTotals, double totalExpense) {
    return categoryTotals.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final amount = entry.value.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 0.0; // Sembunyikan teks jika tidak disentuh agar rapi
      final radius = isTouched ? 70.0 : 60.0; // Efek membesar saat disentuh

      return PieChartSectionData(
        color: _getCategoryColor(entry.value.key, index),
        value: amount,
        title: isTouched ? CurrencyFormatter.convertToIdr(amount) : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    }).toList();
  }
}