enum TransactionType { deposit, withdrawal }

class Transaction {
  String id;
  String ownerId;
  double amount; // 金额
  double shares; // 份额
  double netValueAtTransaction; // 交易时的净值
  TransactionType type;
  DateTime timestamp;
  String notes;

  Transaction({
    required this.id,
    required this.ownerId,
    required this.amount,
    required this.shares,
    required this.netValueAtTransaction,
    required this.type,
    required this.timestamp,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'amount': amount,
      'shares': shares,
      'netValueAtTransaction': netValueAtTransaction,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      ownerId: json['ownerId'],
      amount: json['amount'],
      shares: json['shares'],
      netValueAtTransaction: json['netValueAtTransaction'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
    );
  }
}
