abstract class Asset {
  String id;
  String name;
  double totalValue; // Changed from currentValue to totalValue
  String ownerId;
  bool isProxyManaged;
  DateTime lastUpdated;

  Asset({
    required this.id,
    required this.name,
    required this.totalValue, // Changed parameter name
    required this.ownerId,
    this.isProxyManaged = false,
    required this.lastUpdated,
  });

  // Get the current total value of the asset
  double getValue() {
    return totalValue; // Simplified - now directly returns the total value
  }

  // Update asset total value
  void updateValue(double newValue) {
    totalValue = newValue;
    lastUpdated = DateTime.now();
  }

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return 'Asset{id: $id, name: $name, totalValue: $totalValue, owner: $ownerId, proxy: $isProxyManaged}';
  }
}

class StockAsset extends Asset {
  String ticker;
  double purchasePrice; // Total purchase price, not per share

  StockAsset({
    required super.id,
    required super.name,
    required super.totalValue, // Changed parameter name
    required super.ownerId,
    super.isProxyManaged,
    required super.lastUpdated,
    required this.ticker,
    required this.purchasePrice,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalValue': totalValue, // Changed field name
      'ownerId': ownerId,
      'isProxyManaged': isProxyManaged,
      'lastUpdated': lastUpdated.toIso8601String(),
      'type': 'stock',
      'ticker': ticker,
      'purchasePrice': purchasePrice,
    };
  }
}

class CryptoAsset extends Asset {
  String symbol;
  double purchasePrice; // Total purchase price, not per unit

  CryptoAsset({
    required super.id,
    required super.name,
    required super.totalValue, // Changed parameter name
    required super.ownerId,
    super.isProxyManaged,
    required super.lastUpdated,
    required this.symbol,
    required this.purchasePrice,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalValue': totalValue, // Changed field name
      'ownerId': ownerId,
      'isProxyManaged': isProxyManaged,
      'lastUpdated': lastUpdated.toIso8601String(),
      'type': 'crypto',
      'symbol': symbol,
      'purchasePrice': purchasePrice,
    };
  }
}

class CashAsset extends Asset {
  String bankName;
  String accountNumber;
  double interestRate;

  CashAsset({
    required super.id,
    required super.name,
    required super.totalValue, // Changed parameter name
    required super.ownerId,
    super.isProxyManaged,
    required super.lastUpdated,
    required this.bankName,
    required this.accountNumber,
    this.interestRate = 0.0,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalValue': totalValue, // Changed field name
      'ownerId': ownerId,
      'isProxyManaged': isProxyManaged,
      'lastUpdated': lastUpdated.toIso8601String(),
      'type': 'cash',
      'bankName': bankName,
      'accountNumber': accountNumber,
      'interestRate': interestRate,
    };
  }
}
