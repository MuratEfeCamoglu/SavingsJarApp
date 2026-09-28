import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/money_rules.dart';
import '../../data/models/jar_model.dart';
import '../../providers/jar_provider.dart';
import '../screens/celebration_screen.dart';

class _MoneyEntry {
  final double amount;
  final String? note;
  final DateTime date;
  const _MoneyEntry(this.amount, this.note, this.date);
}

/// Opens the deposit/withdraw dialog for [jar] and records the transaction.
/// When a deposit completes the goal, the celebration screen is shown;
/// [replaceRoute] replaces the current route instead of pushing over it.
Future<void> showMoneyDialog(
  BuildContext context,
  JarModel jar, {
  required bool isWithdraw,
  required Color color,
  bool replaceRoute = false,
}) async {
  final provider = context.read<JarProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  if (isWithdraw && !canWithdraw(jar)) {
    messenger.showSnackBar(const SnackBar(
        content: Text('This jar is locked until its goal is reached.')));
    return;
  }

  final entry = await showDialog<_MoneyEntry>(
    context: context,
    builder: (_) => _MoneyDialog(jar: jar, isWithdraw: isWithdraw, color: color),
  );
  if (entry == null) return;

  final deposit = applyAutoSave(entry.amount, autoSave: jar.autoSave);
  final amount = isWithdraw ? -entry.amount : deposit;
  final title = isWithdraw
      ? 'Withdrawal'
      : (deposit > entry.amount ? 'Deposit (rounded up)' : 'Deposit');

  try {
    await provider.addMoney(jar.id, amount,
        title: title, note: entry.note, date: entry.date);
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    return;
  }

  if (!isWithdraw && reachesGoal(jar, deposit)) {
    final route = MaterialPageRoute(builder: (_) => CelebrationScreen(jar: jar));
    replaceRoute ? navigator.pushReplacement(route) : navigator.push(route);
  }
}

/// Asks for confirmation, then deletes [jar] together with its transactions.
/// With [popAfter], the current route is closed once the user confirms.
Future<void> deleteJarWithConfirmation(BuildContext context, JarModel jar,
    {bool popAfter = false}) async {
  final provider = context.read<JarProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final txCount = provider.transactionsForJar(jar.id).length;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(ctx).cardColor,
      title: Text('Delete "${jar.name}"?',
          style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
      content: Text(
          'The jar and its $txCount transaction(s) will be permanently deleted.',
          style: Theme.of(ctx).textTheme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  if (popAfter) navigator.pop();
  try {
    await provider.deleteJar(jar.id);
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Delete failed: $e')));
  }
}

class _MoneyDialog extends StatefulWidget {
  final JarModel jar;
  final bool isWithdraw;
  final Color color;
  const _MoneyDialog(
      {required this.jar, required this.isWithdraw, required this.color});

  @override
  State<_MoneyDialog> createState() => _MoneyDialogState();
}

class _MoneyDialogState extends State<_MoneyDialog> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = parseAmount(_amountCtrl.text);
    final error = validateAmount(amount,
        isWithdraw: widget.isWithdraw, balance: widget.jar.savedAmount);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final note = _noteCtrl.text.trim();
    Navigator.pop(context, _MoneyEntry(amount!, note.isEmpty ? null : note, _date));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = widget.isWithdraw ? Colors.orange : widget.color;
    final fieldBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none);

    return AlertDialog(
      backgroundColor: theme.cardColor,
      title: Text(
        widget.isWithdraw
            ? 'Withdraw from ${widget.jar.name}'
            : 'Add to ${widget.jar.name}',
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountCtrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration: InputDecoration(
              hintText: 'Amount',
              hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
              helperText: widget.isWithdraw
                  ? 'Available: \$${widget.jar.savedAmount.toStringAsFixed(2)}'
                  : (widget.jar.autoSave ? 'Auto-Save rounds up to the next whole amount' : null),
              errorText: _error,
              prefixIcon: Icon(Icons.attach_money, color: accent),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: fieldBorder,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: 'Note (optional)',
              hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
              prefixIcon: const Icon(Icons.note_outlined),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor,
              border: fieldBorder,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Icon(Icons.calendar_today_outlined,
                    size: 18, color: theme.textTheme.bodyMedium?.color),
                const SizedBox(width: 10),
                Text(DateFormat('MMM dd, yyyy').format(_date),
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                const Spacer(),
                Icon(Icons.edit_calendar_outlined,
                    size: 16, color: theme.textTheme.bodyMedium?.color),
              ]),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: accent),
          onPressed: _submit,
          child: Text(widget.isWithdraw ? 'Withdraw' : 'Add',
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
