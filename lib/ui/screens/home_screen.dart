import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/jar_model.dart';
import '../../providers/jar_provider.dart';
import '../../core/theme.dart';
import 'jar_detail_screen.dart';
import 'celebration_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JarProvider>(context);
    final jars = provider.jars;

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
          ),
        ),
        title: const Text('Savings Jars'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: jars.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_outlined, size: 80, color: AppTheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No jars yet!', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Tap + to create your first savings jar.', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jars.length,
              itemBuilder: (context, index) {
                final jar = jars[index];
                return _JarCard(jar: jar);
              },
            ),
    );
  }
}

class _JarCard extends StatelessWidget {
  final JarModel jar;
  const _JarCard({required this.jar});

  @override
  Widget build(BuildContext context) {
    final progress = (jar.targetAmount > 0) ? (jar.savedAmount / jar.targetAmount).clamp(0.0, 1.0) : 0.0;
    final isCompleted = jar.savedAmount >= jar.targetAmount && jar.targetAmount > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final jarColor = jar.color != null ? Color(jar.color!) : AppTheme.primary;

    final cardColor = isDark
        ? const Color(0xFF1E293B).withOpacity(0.9)
        : Colors.white.withOpacity(0.85);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.9);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => JarDetailScreen(jar: jar)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(isDark ? 0.05 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppTheme.accentGreen.withOpacity(0.12)
                              : Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isCompleted ? '✅ Completed' : '⏳ In Progress',
                          style: TextStyle(
                            color: isCompleted ? AppTheme.accentGreen : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_horiz,
                            color: Theme.of(context).textTheme.bodyMedium?.color),
                        onSelected: (value) {
                          if (value == 'delete') {
                            Provider.of<JarProvider>(context, listen: false).deleteJar(jar.id);
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
                  const SizedBox(height: 16),
                  // Icon
                  Center(child: _buildJarIcon(jar.iconStyle)),
                  const SizedBox(height: 16),
                  // Name & amounts
                  Text(jar.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${jar.savedAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 26,
                              color: AppTheme.accentGreen,
                            ),
                      ),
                      Text(
                        'of \$${jar.targetAmount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.06),
                            color: isCompleted ? AppTheme.accentGreen : jarColor,
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          color: isCompleted ? AppTheme.accentGreen : jarColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  if (isCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => JarDetailScreen(jar: jar))),
                        icon: const Icon(Icons.emoji_events, size: 16, color: Colors.white),
                        label: const Text('Goal Reached! View Details',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showMoneyDialog(context, jar, isWithdraw: false),
                            icon: const Icon(Icons.add, size: 16, color: Colors.white),
                            label: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: jarColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showMoneyDialog(context, jar, isWithdraw: true),
                            icon: const Icon(Icons.remove, size: 16),
                            label: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMoneyDialog(BuildContext context, JarModel jar, {required bool isWithdraw}) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final jarColor = jar.color != null ? Color(jar.color!) : AppTheme.primary;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: Theme.of(ctx).cardColor,
          title: Text(
            isWithdraw ? 'Withdraw from ${jar.name}' : 'Add to ${jar.name}',
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
                  prefixIcon: Icon(isWithdraw ? Icons.remove : Icons.attach_money,
                      color: isWithdraw ? Colors.orange : jarColor),
                  filled: true,
                  fillColor: Theme.of(ctx).scaffoldBackgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Note (optional)',
                  hintStyle: TextStyle(color: Theme.of(ctx).textTheme.bodyMedium?.color),
                  prefixIcon: const Icon(Icons.note_outlined),
                  filled: true,
                  fillColor: Theme.of(ctx).scaffoldBackgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setS(() => selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: Theme.of(ctx).textTheme.bodyMedium?.color),
                    const SizedBox(width: 8),
                    Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
                    const Spacer(),
                    Icon(Icons.edit_calendar_outlined, size: 14, color: Theme.of(ctx).textTheme.bodyMedium?.color),
                  ]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: isWithdraw ? Colors.orange : jarColor),
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.'));
                if (amount == null || amount <= 0) return;
                Navigator.pop(ctx);
                final provider = Provider.of<JarProvider>(context, listen: false);
                final finalAmount = isWithdraw ? -amount : amount;
                await provider.addMoney(jar.id, finalAmount,
                    title: isWithdraw ? 'Withdrawal' : 'Deposit',
                    note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                    date: selectedDate);
                if (!isWithdraw) {
                  final newProgress = (jar.targetAmount > 0)
                      ? (jar.savedAmount + amount) / jar.targetAmount : 0.0;
                  if (newProgress >= 1.0 && context.mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CelebrationScreen(jar: jar)));
                  }
                }
              },
              child: Text(isWithdraw ? 'Withdraw' : 'Add', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJarIcon(String iconStyle) {
    const imageStyles = ['car', 'home', 'plane'];
    if (imageStyles.contains(iconStyle)) {
      return Image.asset('lib/images/$iconStyle.png', width: 140, height: 140,
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
      'wedding': Icons.favorite,
      'baby': Icons.child_care_outlined,
      'business': Icons.business_center_outlined,
    };
    return Icon(iconMap[iconStyle] ?? Icons.savings_outlined, size: 80, color: AppTheme.primary);
  }
}

