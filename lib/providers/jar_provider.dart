import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/jar_model.dart';
import '../data/models/transaction_model.dart';

class JarProvider with ChangeNotifier {
  List<JarModel> _jars = [];
  List<JarModel> get jars => _jars;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void fetchJars() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    _firestore
        .collection('jars')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _jars = snapshot.docs
          .map((doc) => JarModel.fromMap(doc.data(), doc.id))
          .toList();
      _jars.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    });
  }

  void fetchTransactions() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    });
  }

  List<TransactionModel> transactionsForJar(String jarId) {
    return _transactions.where((t) => t.jarId == jarId).toList();
  }

  Future<void> addJar(JarModel jar) async {
    final data = jar.toMap();
    data.remove('id');
    await _firestore.collection('jars').add(data);
  }

  Future<void> deleteJar(String jarId) async {
    await _firestore.collection('jars').doc(jarId).delete();
  }

  /// [amount] is positive for deposits, negative for withdrawals.
  Future<void> addMoney(
    String jarId,
    double amount, {
    String title = 'Manual Deposit',
    String? note,
    DateTime? date,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final txDate = date ?? DateTime.now();

    await _firestore.collection('jars').doc(jarId).update({
      'savedAmount': FieldValue.increment(amount),
    });

    await _firestore.collection('transactions').add({
      'jarId': jarId,
      'title': title,
      'note': note,
      'amount': amount,
      'userId': userId,
      'createdAt': Timestamp.fromDate(txDate),
    });
  }
}
