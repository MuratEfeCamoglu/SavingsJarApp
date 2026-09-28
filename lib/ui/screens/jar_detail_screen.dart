import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/jar_provider.dart';
import '../../data/models/jar_model.dart';
import '../../data/models/transaction_model.dart';
import '../../core/jar_icons.dart';
import '../../core/money_rules.dart';
import '../../core/theme.dart';
import '../widgets/jar_actions.dart';

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
        final isCompleted = isGoalReached(liveJar);
        final withdrawAllowed = canWithdraw(liveJar);
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
                    deleteJarWithConfirmation(context, liveJar, popAfter: true);
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
                      buildJarIcon(liveJar.iconStyle, imageSize: 100, iconColor: Colors.white),
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
                      onPressed: () => showMoneyDialog(context, liveJar,
                          isWithdraw: false, color: _jarColor, replaceRoute: true),
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
                      onPressed: () => showMoneyDialog(context, liveJar,
                          isWithdraw: true, color: _jarColor),
                      icon: Icon(withdrawAllowed ? Icons.remove : Icons.lock_outline),
                      label: Text(withdrawAllowed ? 'Withdraw' : 'Locked'),
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
