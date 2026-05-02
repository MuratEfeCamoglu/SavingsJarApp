class TransactionModel {
  final String id;
  final String jarId;
  final String title;
  final double amount;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.jarId,
    required this.title,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jarId': jarId,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      jarId: map['jarId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }
}
