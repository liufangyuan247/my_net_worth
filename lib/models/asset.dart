abstract class Asset {
  String id;
  String name;
  double totalValue;
  bool
      isProxyManaged; // Whether this asset is managed on behalf of someone else
  DateTime lastUpdated;

  Asset({
    required this.id,
    required this.name,
    required this.totalValue,
    this.isProxyManaged = false,
    required this.lastUpdated,
  });

  // Get the current total value of the asset
  double getValue() {
    return totalValue;
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
          isProxyManaged: json['isProxyManaged'] as bool,
          lastUpdated: DateTime.parse(json['lastUpdated'] as String),
          ticker: json['ticker'] as String,
        );
      case 'crypto':
        return CryptoAsset(
          id: json['id'] as String,
          name: json['name'] as String,
          totalValue: json['totalValue'] as double,
          isProxyManaged: json['isProxyManaged'] as bool,
          lastUpdated: DateTime.parse(json['lastUpdated'] as String),
          symbol: json['symbol'] as String,
        );
      case 'cash':
        return CashAsset(
          id: json['id'] as String,
          name: json['name'] as String,
          totalValue: json['totalValue'] as double,
          isProxyManaged: json['isProxyManaged'] as bool,
          lastUpdated: DateTime.parse(json['lastUpdated'] as String),
          bankName: json['bankName'] as String,
          accountNumber: json['accountNumber'] as String,
        );
      default:
        throw Exception('Unknown asset type: $type');
    }
  }

  @override
  String toString() {
    return 'Asset{id: $id, name: $name, totalValue: $totalValue, proxy: $isProxyManaged}';
  }
}

class StockAsset extends Asset {
  String ticker;

  StockAsset({
    required super.id,
    required super.name,
    required super.totalValue,
    super.isProxyManaged,
    required super.lastUpdated,
    required this.ticker,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalValue': totalValue,
      'isProxyManaged': isProxyManaged,
      'lastUpdated': lastUpdated.toIso8601String(),
      'type': 'stock',
      'ticker': ticker,
    };
  }
}

class CryptoAsset extends Asset {
  String symbol;

  CryptoAsset({
    required super.id,
    required super.name,
    required super.totalValue,
    super.isProxyManaged,
    required super.lastUpdated,
    required this.symbol,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalValue': totalValue,
      'isProxyManaged': isProxyManaged,
      'lastUpdated': lastUpdated.toIso8601String(),
      'type': 'crypto',
      'symbol': symbol,
    };
  }
}

class CashAsset extends Asset {
  String bankName;
  String accountNumber;

  CashAsset({
    required super.id,
    required super.name,
    required super.totalValue,
    super.isProxyManaged,
    required super.lastUpdated,
    required this.bankName,
    required this.accountNumber,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalValue': totalValue,
      'isProxyManaged': isProxyManaged,
      'lastUpdated': lastUpdated.toIso8601String(),
      'type': 'cash',
      'bankName': bankName,
      'accountNumber': accountNumber,
    };
  }
}
