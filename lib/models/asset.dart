import 'dart:convert';

enum AssetType { stock, crypto, cash, realEstate, other }

abstract class Asset {
  final String id;
  final String name;
  final AssetType type;
  double totalValue;
  DateTime lastUpdated;

  Asset({
    required this.id,
    required this.name,
    required this.type,
    required this.totalValue,
    required this.lastUpdated,
  });

  // 获取资产价值
  double getValue() {
    return totalValue;
  }

  // 更新资产价值
  void updateValue(double newValue) {
    totalValue = newValue;
    lastUpdated = DateTime.now();
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'totalValue': totalValue,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  // 从JSON创建
  static Asset fromJson(Map<String, dynamic> json) {
    final AssetType type = _assetTypeFromString(json['type']);

    switch (type) {
      case AssetType.stock:
        return StockAsset(
          id: json['id'],
          name: json['name'],
          totalValue: json['totalValue'].toDouble(),
          lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']),
        );
      case AssetType.crypto:
        return CryptoAsset(
          id: json['id'],
          name: json['name'],
          totalValue: json['totalValue'].toDouble(),
          lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']),
        );
      case AssetType.cash:
        return CashAsset(
          id: json['id'],
          name: json['name'],
          totalValue: json['totalValue'].toDouble(),
          lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']),
        );
      case AssetType.realEstate:
        return RealEstateAsset(
          id: json['id'],
          name: json['name'],
          totalValue: json['totalValue'].toDouble(),
          lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']),
        );
      case AssetType.other:
      default:
        return OtherAsset(
          id: json['id'],
          name: json['name'],
          totalValue: json['totalValue'].toDouble(),
          lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated']),
        );
    }
  }

  // 将字符串转换为AssetType枚举
  static AssetType _assetTypeFromString(String typeStr) {
    switch (typeStr) {
      case 'stock':
        return AssetType.stock;
      case 'crypto':
        return AssetType.crypto;
      case 'cash':
        return AssetType.cash;
      case 'realEstate':
        return AssetType.realEstate;
      default:
        return AssetType.other;
    }
  }
}

class StockAsset extends Asset {
  StockAsset({
    required String id,
    required String name,
    required double totalValue,
    required DateTime lastUpdated,
  }) : super(
          id: id,
          name: name,
          type: AssetType.stock,
          totalValue: totalValue,
          lastUpdated: lastUpdated,
        );
}

class CryptoAsset extends Asset {
  CryptoAsset({
    required String id,
    required String name,
    required double totalValue,
    required DateTime lastUpdated,
  }) : super(
          id: id,
          name: name,
          type: AssetType.crypto,
          totalValue: totalValue,
          lastUpdated: lastUpdated,
        );
}

class CashAsset extends Asset {
  CashAsset({
    required String id,
    required String name,
    required double totalValue,
    required DateTime lastUpdated,
  }) : super(
          id: id,
          name: name,
          type: AssetType.cash,
          totalValue: totalValue,
          lastUpdated: lastUpdated,
        );
}

class RealEstateAsset extends Asset {
  RealEstateAsset({
    required String id,
    required String name,
    required double totalValue,
    required DateTime lastUpdated,
  }) : super(
          id: id,
          name: name,
          type: AssetType.realEstate,
          totalValue: totalValue,
          lastUpdated: lastUpdated,
        );
}

class OtherAsset extends Asset {
  OtherAsset({
    required String id,
    required String name,
    required double totalValue,
    required DateTime lastUpdated,
  }) : super(
          id: id,
          name: name,
          type: AssetType.other,
          totalValue: totalValue,
          lastUpdated: lastUpdated,
        );
}
