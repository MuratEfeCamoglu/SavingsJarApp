class TransactionModel {
  final String id;
  final String jarId;
  final String title;
  final String? note;
  final double amount;
  final DateTime date;
  final String? userId;

  TransactionModel({
    required this.id,
    required this.jarId,
    required this.title,
    this.note,
    required this.amount,
    required this.date,
    this.userId,
  });

  bool get isDeposit => amount >= 0;

  Map<String, dynamic> toMap() {
    return {
      'jarId': jarId,
      'title': title,
      'note': note,
      'amount': amount,
      'createdAt': date.toIso8601String(),
      'userId': userId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value != null && value.runtimeType.toString() == 'Timestamp') {
        try { return value.toDate(); } catch (_) {}
      }
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return TransactionModel(
      id: documentId,
      jarId: map['jarId']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Transaction',
      note: map['note']?.toString(),
      amount: parseDouble(map['amount']),
      date: parseDate(map['createdAt'] ?? map['date']),
      userId: map['userId']?.toString(),
    );
  }
}
