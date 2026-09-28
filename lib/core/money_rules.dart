import 'dart:math' as math;
import '../data/models/jar_model.dart';

/// Parses user input ("12,5" or "12.5") and rounds it to whole cents.
double? parseAmount(String input) {
  final value = double.tryParse(input.trim().replaceAll(',', '.'));
  if (value == null || value.isNaN || value.isInfinite) return null;
  return (value * 100).roundToDouble() / 100;
}

bool isGoalReached(JarModel jar) =>
    jar.targetAmount > 0 && jar.savedAmount >= jar.targetAmount;

/// Locked jars block withdrawals until their goal is reached.
bool canWithdraw(JarModel jar) => !jar.locked || isGoalReached(jar);

/// Returns an error message, or null when [amount] is acceptable.
String? validateAmount(double? amount,
    {required bool isWithdraw, required double balance}) {
  if (amount == null || amount <= 0) return 'Enter an amount greater than 0.';
  // Compare in cents so floating-point drift from increments doesn't matter
  final available = math.max(balance, 0.0);
  if (isWithdraw && (amount * 100).round() > (available * 100).round()) {
    return 'You can withdraw at most \$${available.toStringAsFixed(2)}.';
  }
  return null;
}

/// Auto-Save jars round every deposit up to the next whole amount.
double applyAutoSave(double amount, {required bool autoSave}) =>
    autoSave ? amount.ceilToDouble() : amount;

/// True when [deposit] takes a not-yet-completed jar to its goal.
bool reachesGoal(JarModel jar, double deposit) =>
    jar.targetAmount > 0 &&
    !isGoalReached(jar) &&
    jar.savedAmount + deposit >= jar.targetAmount;
