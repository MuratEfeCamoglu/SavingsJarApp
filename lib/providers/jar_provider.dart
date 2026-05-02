import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/jar_model.dart';
import '../data/models/transaction_model.dart';

class JarProvider with ChangeNotifier {
  List<JarModel> _jars = [];
  List<JarModel> get jars => List.unmodifiable(_jars);

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Active Firestore listeners — cancelled on re-fetch
  void Function()? _jarUnsub;
  void Function()? _txUnsub;

  void fetchJars() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Cancel previous listener if re-fetching
    _jarUnsub?.call();

    final sub = _db
        .collection('jars')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      _jars = snapshot.docs
          .map((doc) => JarModel.fromMap(doc.data(), doc.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }, onError: (e) => debugPrint('JarProvider.fetchJars error: $e'));

    _jarUnsub = sub.cancel;
  }

  void fetchTransactions() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _txUnsub?.call();

    // Limit to last 100 to avoid huge list rebuilds
    final sub = _db
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .limit(100)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }, onError: (e) => debugPrint('JarProvider.fetchTransactions error: $e'));

    _txUnsub = sub.cancel;
  }

  /// Returns transactions for a specific jar — computed, no extra subscription.
  List<TransactionModel> transactionsForJar(String jarId) =>
      _transactions.where((t) => t.jarId == jarId).toList();

  Future<void> addJar(JarModel jar) async {
    final data = jar.toMap()..remove('id');
    await _db.collection('jars').add(data);
  }

  Future<void> deleteJar(String jarId) async {
    await _db.collection('jars').doc(jarId).delete();
  }

  /// [amount] positive = deposit, negative = withdrawal.
  Future<void> addMoney(
    String jarId,
    double amount, {
    String title = 'Manual Deposit',
    String? note,
    DateTime? date,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final txDate = date ?? DateTime.now();

    // Batch write for atomicity
    final batch = _db.batch();

    batch.update(_db.collection('jars').doc(jarId), {
      'savedAmount': FieldValue.increment(amount),
    });

    final txRef = _db.collection('transactions').doc();
    batch.set(txRef, {
      'jarId': jarId,
      'title': title,
      'note': note,
      'amount': amount,
      'userId': uid,
      'createdAt': Timestamp.fromDate(txDate),
    });

    await batch.commit();
  }

  @override
  void dispose() {
    _jarUnsub?.call();
    _txUnsub?.call();
    super.dispose();
  }
}
