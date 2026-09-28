import 'package:flutter_test/flutter_test.dart';

import 'package:savings/core/money_rules.dart';
import 'package:savings/data/models/jar_model.dart';

JarModel _jar({double saved = 0, double target = 100, bool locked = false}) =>
    JarModel(
      id: 'j1',
      name: 'Test',
      targetAmount: target,
      savedAmount: saved,
      iconStyle: 'piggy',
      locked: locked,
      createdAt: DateTime(2026),
    );

void main() {
  group('parseAmount', () {
    test('accepts comma and dot decimals', () {
      expect(parseAmount('12,5'), 12.5);
      expect(parseAmount(' 12.50 '), 12.5);
    });
    test('rounds to cents and rejects garbage', () {
      expect(parseAmount('1.239'), 1.24);
      expect(parseAmount('abc'), isNull);
      expect(parseAmount(''), isNull);
    });
  });

  group('validateAmount', () {
    test('rejects missing, zero and negative amounts', () {
      for (final a in [null, 0.0, -5.0]) {
        expect(validateAmount(a, isWithdraw: false, balance: 10), isNotNull);
      }
    });
    test('blocks withdrawing more than the balance', () {
      expect(validateAmount(10.01, isWithdraw: true, balance: 10), isNotNull);
      expect(validateAmount(10, isWithdraw: true, balance: 10), isNull);
      expect(validateAmount(5, isWithdraw: true, balance: -3), isNotNull);
    });
    test('tolerates floating-point drift in the balance', () {
      expect(validateAmount(0.3, isWithdraw: true, balance: 0.1 + 0.2), isNull);
      expect(validateAmount(0.3, isWithdraw: true, balance: 0.29999999999), isNull);
    });
    test('deposits are not limited by balance', () {
      expect(validateAmount(500, isWithdraw: false, balance: 0), isNull);
    });
  });

  group('canWithdraw', () {
    test('locked jar blocks withdrawals until the goal is reached', () {
      expect(canWithdraw(_jar(saved: 50, locked: true)), isFalse);
      expect(canWithdraw(_jar(saved: 100, locked: true)), isTrue);
      expect(canWithdraw(_jar(saved: 50)), isTrue);
    });
  });

  test('applyAutoSave rounds up only when enabled', () {
    expect(applyAutoSave(12.3, autoSave: true), 13);
    expect(applyAutoSave(12, autoSave: true), 12);
    expect(applyAutoSave(12.3, autoSave: false), 12.3);
  });

  test('reachesGoal only fires on the deposit that completes the jar', () {
    expect(reachesGoal(_jar(saved: 90), 10), isTrue);
    expect(reachesGoal(_jar(saved: 90), 5), isFalse);
    expect(reachesGoal(_jar(saved: 100), 10), isFalse);
    expect(reachesGoal(_jar(saved: 0, target: 0), 10), isFalse);
  });
}
