import 'package:intl/intl.dart';

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
      'timestamp': timestamp.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      ownerId: json['ownerId'],
      amount: json['amount'].toDouble(),
      shares: json['shares'].toDouble(),
      netValueAtTransaction: json['netValueAtTransaction'].toDouble(),
      type: json['type'] == 'deposit'
          ? TransactionType.deposit
          : TransactionType.withdrawal,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      notes: json['notes'] ?? '',
    );
  }

  @override
  String toString() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return 'Transaction{id: $id, ownerId: $ownerId, amount: $amount, shares: $shares, type: $type, date: ${formatter.format(timestamp)}}';
  }
}
