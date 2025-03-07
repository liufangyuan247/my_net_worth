enum TransactionType {
  deposit,
  withdrawal,
}

class Transaction {
  final String id;
  final String ownerId;
  final double amount;
  final double shares;
  final double netValueAtTransaction;
  final TransactionType type;
  final DateTime timestamp;
  final String notes;

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
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      amount: json['amount'] as double,
      shares: json['shares'] as double,
      netValueAtTransaction: json['netValueAtTransaction'] as double,
      type: json['type'] == 'deposit'
          ? TransactionType.deposit
          : TransactionType.withdrawal,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String? ?? '',
    );
  }
}
