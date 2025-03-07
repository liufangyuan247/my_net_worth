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

  static Asset fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'stock':
        return StockAsset(
          id: json['id'] as String,
          name: json['name'] as String,
          totalValue: json['totalValue'] as double,
          ownerId: json['ownerId'] as String,
          isProxyManaged: json['isProxyManaged'] as bool,
          lastUpdated: DateTime.parse(json['lastUpdated'] as String),
          ticker: json['ticker'] as String,
          purchasePrice: json['purchasePrice'] as double,
        );
      case 'crypto':
        return CryptoAsset(
          id: json['id'] as String,
          name: json['name'] as String,
          totalValue: json['totalValue'] as double,
          ownerId: json['ownerId'] as String,
          isProxyManaged: json['isProxyManaged'] as bool,
          lastUpdated: DateTime.parse(json['lastUpdated'] as String),
          symbol: json['symbol'] as String,
          purchasePrice: json['purchasePrice'] as double,
        );
      case 'cash':
        return CashAsset(
          id: json['id'] as String,
          name: json['name'] as String,
          totalValue: json['totalValue'] as double,
          ownerId: json['ownerId'] as String,
          isProxyManaged: json['isProxyManaged'] as bool,
          lastUpdated: DateTime.parse(json['lastUpdated'] as String),
          bankName: json['bankName'] as String,
          accountNumber: json['accountNumber'] as String,
          interestRate: json['interestRate'] as double,
        );
      default:
        throw Exception('Unknown asset type: $type');
    }
  }

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
