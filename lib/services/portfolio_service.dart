import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asset.dart';
import '../models/owner.dart';
import '../models/transaction.dart';

class PortfolioService {
  List<Asset> _assets = [];
  List<Owner> _owners = [];
  List<Transaction> _transactions = [];

  // 获取所有资产
  List<Asset> get assets => _assets;

  // 获取所有持有人
  List<Owner> get owners => _owners;

  // 获取所有交易记录
  List<Transaction> get transactions => _transactions;

  // 计算总资产价值
  double getTotalAssetValue() {
    return _assets.fold(0, (sum, asset) => sum + asset.getValue());
  }

  // 计算总份额
  double getTotalShares() {
    return _owners.fold(0, (sum, owner) => sum + owner.shares);
  }

  // 计算当前净值
  double calculateNetValue() {
    double totalValue = getTotalAssetValue();
    double totalShares = getTotalShares();

    if (totalShares <= 0) return 1.0; // 默认初始净值
    return totalValue / totalShares;
  }

  // 添加资产
  void addAsset(Asset asset) {
    _assets.add(asset);
    saveData();
  }

  // 更新资产
  void updateAsset(Asset asset) {
    int index = _assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      _assets[index] = asset;
      saveData();
    }
  }

  // 删除资产
  void deleteAsset(String assetId) {
    _assets.removeWhere((asset) => asset.id == assetId);
    saveData();
  }

  // 添加持有人
  void addOwner(Owner owner) {
    _owners.add(owner);
    saveData();
  }

  // 处理存款（买入份额）
  void processDeposit(String ownerId, double amount, {String notes = ''}) {
    double currentNetValue = calculateNetValue();
    double sharesAdded = amount / currentNetValue;

    // 更新持有人份额
    Owner? owner = _owners.firstWhere((o) => o.id == ownerId);
    owner.addShares(sharesAdded);

    // 记录交易
    _transactions.add(Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: ownerId,
      amount: amount,
      shares: sharesAdded,
      netValueAtTransaction: currentNetValue,
      type: TransactionType.deposit,
      timestamp: DateTime.now(),
      notes: notes,
    ));

    saveData();
  }

  // 处理提款（卖出份额）
  void processWithdrawal(String ownerId, double amount, {String notes = ''}) {
    double currentNetValue = calculateNetValue();
    double sharesToWithdraw = amount / currentNetValue;

    // 更新持有人份额
    Owner owner = _owners.firstWhere((o) => o.id == ownerId);
    owner.subtractShares(sharesToWithdraw);

    // 记录交易
    _transactions.add(Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: ownerId,
      amount: amount,
      shares: sharesToWithdraw,
      netValueAtTransaction: currentNetValue,
      type: TransactionType.withdrawal,
      timestamp: DateTime.now(),
      notes: notes,
    ));

    saveData();
  }

  // 获取代理管理的资产
  List<Asset> getProxyManagedAssets() {
    return _assets.where((asset) => asset.isProxyManaged).toList();
  }

  // 获取特定持有人的资产
  List<Asset> getAssetsByOwner(String ownerId) {
    return _assets.where((asset) => asset.ownerId == ownerId).toList();
  }

  // 保存数据到本地存储
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    // 实际应用中应处理序列化问题，此处简化处理
    // ...
  }

  // 从本地存储加载数据
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    // 实际应用中应处理反序列化问题，此处简化处理
    // ...
  }
}
