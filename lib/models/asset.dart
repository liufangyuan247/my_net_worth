abstract class Asset {
  String id;
  String name;
  double currentValue;
  String ownerId; // 可以是自己或其他人的ID
  bool isProxyManaged; // 是否代理管理
  DateTime lastUpdated;

  Asset({
    required this.id,
    required this.name,
    required this.currentValue,
    required this.ownerId,
    this.isProxyManaged = false,
    required this.lastUpdated,
  });

  // 获取当前资产价值
  double getValue();

  // 更新资产价值
  void updateValue(double newValue);

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return 'Asset{id: $id, name: $name, value: $currentValue, owner: $ownerId, proxy: $isProxyManaged}';
  }
}

class StockAsset extends Asset {
  String ticker;
  double shares;
  double purchasePrice;

  StockAsset({
    required super.id,
    required super.name,
    required super.currentValue,
    required super.ownerId,
    super.isProxyManaged,
    required super.lastUpdated,
    required this.ticker,
    required this.shares,
    required this.purchasePrice,
  });

  @override
  double getValue() => currentValue * shares;

  @override
  void updateValue(double newPrice) {
    currentValue = newPrice;
    lastUpdated = DateTime.now();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currentValue': currentValue,
      'ownerId': ownerId,
      'isProxyManaged': isProxyManaged,
      'lastUpdated': lastUpdated.toIso8601String(),
      'type': 'stock',
      'ticker': ticker,
      'shares': shares,
      'purchasePrice': purchasePrice,
    };
  }
}

class CryptoAsset extends Asset {
  String symbol;
  double amount;
  double purchasePrice;

  CryptoAsset({
    required super.id,
    required super.name,
    required super.currentValue,
    required super.ownerId,
    super.isProxyManaged,
    required super.lastUpdated,
    required this.symbol,
    required this.amount,
    required this.purchasePrice,
  });

  @override
  double getValue() => currentValue * amount;

  @override
  void updateValue(double newPrice) {
    currentValue = newPrice;
    lastUpdated = DateTime.now();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currentValue': currentValue,
      'ownerId': ownerId,
      'isProxyManaged': isProxyManaged,
      'lastUpdated': lastUpdated.toIso8601String(),
      'type': 'crypto',
      'symbol': symbol,
      'amount': amount,
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
    required super.currentValue,
    required super.ownerId,
    super.isProxyManaged,
    required super.lastUpdated,
    required this.bankName,
    required this.accountNumber,
    this.interestRate = 0.0,
  });

  @override
  double getValue() => currentValue;

  @override
  void updateValue(double newValue) {
    currentValue = newValue;
    lastUpdated = DateTime.now();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currentValue': currentValue,
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
