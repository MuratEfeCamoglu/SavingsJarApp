import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/jar_provider.dart';
import '../../data/models/jar_model.dart';
import '../../data/models/transaction_model.dart';
import '../../core/theme.dart';
import 'celebration_screen.dart';

class JarDetailScreen extends StatelessWidget {
  final JarModel jar;
  const JarDetailScreen({Key? key, required this.jar}) : super(key: key);

  Color get _jarColor =>
      jar.color != null ? Color(jar.color!) : AppTheme.primary;

  @override
  Widget build(BuildContext context) {
    return Consumer<JarProvider>(
      builder: (context, provider, _) {
        // Always read the freshest version from provider
        final liveJar = provider.jars.firstWhere(
          (j) => j.id == jar.id,
          orElse: () => jar,
        );
        final progress = (liveJar.targetAmount > 0)
            ? (liveJar.savedAmount / liveJar.targetAmount).clamp(0.0, 1.0)
            : 0.0;
        final isCompleted = liveJar.savedAmount >= liveJar.targetAmount && liveJar.targetAmount > 0;
        final jarTransactions = provider.transactionsForJar(jar.id);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(liveJar.name),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'delete') {
                    provider.deleteJar(jar.id);
                    Navigator.pop(context);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Jar', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_jarColor, _jarColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: _jarColor.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildIcon(liveJar.iconStyle),
                      const SizedBox(height: 16),
                      Text(liveJar.name,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        '\$${liveJar.savedAmount.toStringAsFixed(2)} saved',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'of \$${liveJar.targetAmount.toStringAsFixed(2)} target',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.25),
                          color: Colors.white,
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(progress * 100).toStringAsFixed(1)}% achieved',
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
                          if (isCompleted)
                            const Text('🎉 Goal Reached!',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action buttons
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showTransactionDialog(context, liveJar, isWithdraw: false),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Add Money', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _jarColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showTransactionDialog(context, liveJar, isWithdraw: true),
                      icon: const Icon(Icons.remove),
                      label: const Text('Withdraw'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 28),

                // Transaction history
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Transaction History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text('${jarTransactions.length} records',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 12),

                jarTransactions.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(children: [
                          Icon(Icons.receipt_long_outlined, size: 48,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4)),
                          const SizedBox(height: 8),
                          Text('No transactions yet', style: Theme.of(context).textTheme.bodyMedium),
                        ]),
                      )
                    : Column(
                        children: jarTransactions
                            .map((t) => _TransactionTile(transaction: t, jarColor: _jarColor))
                            .toList(),
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTransactionDialog(BuildContext context, JarModel liveJar, {required bool isWithdraw}) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(ctx).cardColor,
          title: Text(
            isWithdraw ? 'Withdraw from ${liveJar.name}' : 'Add to ${liveJar.name}',
            style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Amount',
                  hintStyle: TextStyle(color: Theme.of(ctx).textTheme.bodyMedium?.color),
                  prefixIcon: Icon(Icons.attach_money,
                      color: isWithdraw ? Colors.orange : _jarColor),
                  filled: true,
                  fillColor: Theme.of(ctx).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Note (optional)',
                  hintStyle: TextStyle(color: Theme.of(ctx).textTheme.bodyMedium?.color),
                  prefixIcon: const Icon(Icons.note_outlined),
                  filled: true,
                  fillColor: Theme.of(ctx).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setDialogState(() => selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today_outlined, size: 18,
                        color: Theme.of(ctx).textTheme.bodyMedium?.color),
                    const SizedBox(width: 10),
                    Text(DateFormat('MMM dd, yyyy').format(selectedDate),
                        style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
                    const Spacer(),
                    Icon(Icons.edit_calendar_outlined, size: 16,
                        color: Theme.of(ctx).textTheme.bodyMedium?.color),
                  ]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isWithdraw ? Colors.orange : _jarColor,
              ),
              onPressed: () async {
                final amount =
                    double.tryParse(amountCtrl.text.replaceAll(',', '.'));
                if (amount == null || amount <= 0) return;
                Navigator.pop(ctx);

                final finalAmount = isWithdraw ? -amount : amount;
                final title = isWithdraw ? 'Withdrawal' : 'Deposit';

                await Provider.of<JarProvider>(context, listen: false).addMoney(
                  liveJar.id,
                  finalAmount,
                  title: title,
                  note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                  date: selectedDate,
                );

                if (!isWithdraw) {
                  final newProgress = (liveJar.targetAmount > 0)
                      ? (liveJar.savedAmount + amount) / liveJar.targetAmount
                      : 0.0;
                  if (newProgress >= 1.0 && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => CelebrationScreen(jar: liveJar)),
                    );
                  }
                }
              },
              child: Text(isWithdraw ? 'Withdraw' : 'Add',
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String iconStyle) {
    const imageStyles = ['car', 'home', 'plane'];
    if (imageStyles.contains(iconStyle)) {
      return Image.asset('lib/images/$iconStyle.png', width: 100, height: 100,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _iconFallback(iconStyle));
    }
    return _iconFallback(iconStyle);
  }

  Widget _iconFallback(String iconStyle) {
    const iconMap = {
      'piggy': Icons.savings_outlined,
      'plane': Icons.flight,
      'home': Icons.home_outlined,
      'car': Icons.directions_car_outlined,
      'tech': Icons.computer_outlined,
      'health': Icons.favorite_outline,
      'education': Icons.school_outlined,
      'gift': Icons.card_giftcard_outlined,
      'emergency': Icons.local_hospital_outlined,
      'luxury': Icons.diamond_outlined,
      'shopping': Icons.shopping_bag_outlined,
      'food': Icons.restaurant_outlined,
      'sports': Icons.sports_soccer,
      'music': Icons.music_note_outlined,
      'pet': Icons.pets_outlined,
    };
    return Icon(iconMap[iconStyle] ?? Icons.savings_outlined, size: 80, color: Colors.white);
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final Color jarColor;
  const _TransactionTile({required this.transaction, required this.jarColor});

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.amount >= 0;
    final color = isDeposit ? AppTheme.accentGreen : Colors.redAccent;
    final sign = isDeposit ? '+' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(transaction.note!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ],
                const SizedBox(height: 2),
                Text(DateFormat('MMM dd, yyyy').format(transaction.date),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Text(
            '$sign\$${transaction.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
