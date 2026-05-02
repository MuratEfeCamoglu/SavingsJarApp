import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/jar_provider.dart';
import '../../data/models/transaction_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('History',
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 28)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Your journey towards financial freedom,\ndocumented.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'All',
                  onTap: () => setState(() => _selectedFilter = 'All'),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'Savings',
                  isSelected: _selectedFilter == 'Savings',
                  onTap: () => setState(() => _selectedFilter = 'Savings'),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'Withdrawals',
                  isSelected: _selectedFilter == 'Withdrawals',
                  onTap: () => setState(() => _selectedFilter = 'Withdrawals'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            // Use Selector to rebuild ONLY when the transaction list changes.
            child: Selector<JarProvider, List<TransactionModel>>(
              selector: (_, p) => p.transactions,
              builder: (context, allTx, _) {
                final transactions = allTx.where((t) {
                  if (_selectedFilter == 'Savings') return t.amount > 0;
                  if (_selectedFilter == 'Withdrawals') return t.amount < 0;
                  return true;
                }).toList();

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('No transactions yet.',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  // Shrink-wrap disabled for perf; items are lazy by default
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    return RepaintBoundary(
                      child: _TransactionRow(transaction: transactions[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Extracted, const-friendly sub-widgets ────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.tabActiveBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionRow({required this.transaction});

  static final _fmt = DateFormat('MMM dd, yyyy');

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.amount > 0;
    final color = isPositive ? AppTheme.primary : Colors.red;
    final amountStr = isPositive
        ? '+\$${transaction.amount.toStringAsFixed(2)}'
        : '-\$${transaction.amount.abs().toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPositive
                  ? AppTheme.primary.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: 4),
                Text(_fmt.format(transaction.date),
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(transaction.note!,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          Text(amountStr,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
