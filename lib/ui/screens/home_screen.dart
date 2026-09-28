import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/jar_model.dart';
import '../../providers/jar_provider.dart';
import '../../core/jar_icons.dart';
import '../../core/money_rules.dart';
import '../../core/theme.dart';
import '../widgets/jar_actions.dart';
import 'jar_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          // userChanges() also fires on display name / photo updates
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.userChanges(),
            initialData: FirebaseAuth.instance.currentUser,
            builder: (context, snapshot) {
              final user = snapshot.data;
              final photoURL = user?.photoURL;
              return CircleAvatar(
                backgroundImage: photoURL != null
                    ? NetworkImage(photoURL) as ImageProvider
                    : null,
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                child: photoURL == null
                    ? Text(
                        (user?.displayName?.isNotEmpty == true)
                            ? user!.displayName![0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary))
                    : null,
              );
            },
          ),
        ),
        title: Text('Savings Jars',
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 28)),
        centerTitle: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: Selector<JarProvider, List<JarModel>>(
        selector: (_, p) => p.jars,
        builder: (context, jars, _) {
          if (jars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_outlined,
                      size: 80, color: AppTheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No jars yet!',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Tap + to create your first savings jar.',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jars.length,
            // RepaintBoundary isolates each card from sibling repaints
            itemBuilder: (context, index) => RepaintBoundary(
              child: _JarCard(jar: jars[index]),
            ),
          );
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
    final isCompleted = isGoalReached(jar);
    final withdrawAllowed = canWithdraw(jar);
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
                            deleteJarWithConfirmation(context, jar);
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
                  Center(
                      child: buildJarIcon(jar.iconStyle,
                          imageSize: 140, iconColor: AppTheme.primary)),
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
                            onPressed: () => showMoneyDialog(context, jar,
                                isWithdraw: false, color: jarColor),
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
                            onPressed: () => showMoneyDialog(context, jar,
                                isWithdraw: true, color: jarColor),
                            icon: Icon(withdrawAllowed ? Icons.remove : Icons.lock_outline, size: 16),
                            label: Text(withdrawAllowed ? 'Withdraw' : 'Locked',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
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
}
