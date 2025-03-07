import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asset.dart';
import '../models/owner.dart';
import '../models/transaction.dart';
import '../models/price_update.dart';

// 数据变更事件类型
enum DataChangeType { assets, owners, transactions, priceUpdates, all }

// 数据变更事件
class DataChangeEvent {
  final DataChangeType type;
  DataChangeEvent(this.type);
}

class PortfolioService {
  // 单例模式实现
  static final PortfolioService _instance = PortfolioService._internal();

  factory PortfolioService() {
    return _instance;
  }

  PortfolioService._internal() {
    // 初始化时加载数据
    loadData();
  }

  // 私有数据存储
  final List<Asset> _assets = [];
  final List<Owner> _owners = [];
  final List<Transaction> _transactions = [];
  final List<PriceUpdate> _priceUpdates = [];

  // 防止重复加载/保存的标志
  bool _isLoading = false;
  bool _isSaving = false;

  // 数据变更通知流
  final _dataChangeController = StreamController<DataChangeEvent>.broadcast();

  // 获取变更通知流
  Stream<DataChangeEvent> get onDataChanged => _dataChangeController.stream;

  // Getters - 返回不可变的数据副本，防止外部修改
  List<Asset> get assets => List.unmodifiable(_assets);
  List<Owner> get owners => List.unmodifiable(_owners);
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<PriceUpdate> get priceUpdates => List.unmodifiable(_priceUpdates);

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
  Future<void> addAsset(Asset asset) async {
    _assets.add(asset);
    await saveData();
    _notifyDataChanged(DataChangeType.assets);
  }

  // 更新资产
  Future<void> updateAsset(Asset asset) async {
    int index = _assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      _assets[index] = asset;
      await saveData();
      _notifyDataChanged(DataChangeType.assets);
    }
  }

  // 删除资产
  Future<void> deleteAsset(String assetId) async {
    _assets.removeWhere((asset) => asset.id == assetId);
    _priceUpdates
        .removeWhere((update) => update.assetId == assetId); // 清理相关价格更新
    await saveData();
    _notifyDataChanged(DataChangeType.assets);
    _notifyDataChanged(DataChangeType.priceUpdates);
  }

  // 添加持有人
  Future<void> addOwner(Owner owner) async {
    _owners.add(owner);
    await saveData();
    _notifyDataChanged(DataChangeType.owners);
  }

  // 处理交易
  Future<void> processTransaction(String ownerId, double amount,
      TransactionType transactionType, String notes) async {
    print("开始处理交易 - 当前交易数: ${_transactions.length}");

    double currentNetValue = calculateNetValue();
    double sharesChange = amount / currentNetValue;

    // 查找持有人
    int ownerIndex = _owners.indexWhere((o) => o.id == ownerId);
    if (ownerIndex == -1) {
      throw Exception('未找到持有人');
    }

    Owner owner = _owners[ownerIndex];

    if (transactionType == TransactionType.deposit) {
      // 添加份额
      owner.shares += sharesChange;
    } else {
      // 减少份额
      if (owner.shares < sharesChange) {
        throw Exception('赎回份额不足');
      }
      owner.shares -= sharesChange;
    }

    // 创建新交易
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: ownerId,
      amount: amount,
      shares: sharesChange,
      netValueAtTransaction: currentNetValue,
      type: transactionType,
      timestamp: DateTime.now(),
      notes: notes,
    );

    print("添加交易到列表: $transaction");

    // 添加到交易列表
    _transactions.add(transaction);

    print("保存前 - 交易数量: ${_transactions.length}");

    // 保存并通知
    await saveData();
    _notifyDataChanged(DataChangeType.transactions);
    _notifyDataChanged(DataChangeType.owners);

    print("保存后 - 交易数量: ${_transactions.length}");
  }

  // 记录资产价值更新
  Future<void> recordAssetValueUpdate(String assetId, double newValue,
      {String? note}) async {
    final asset = _assets.firstWhere(
      (a) => a.id == assetId,
      orElse: () => throw Exception('未找到资产'),
    );

    // 创建价格更新记录
    final priceUpdate = PriceUpdate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      assetId: assetId,
      value: newValue,
      timestamp: DateTime.now(),
      note: note,
    );

    // 更新资产当前价值
    asset.updateValue(newValue);

    // 添加价格更新到列表
    _priceUpdates.add(priceUpdate);

    // 保存并通知
    await saveData();
    _notifyDataChanged(DataChangeType.assets);
    _notifyDataChanged(DataChangeType.priceUpdates);
  }

  // 获取资产的价格更新历史
  List<PriceUpdate> getValueUpdatesForAsset(String assetId) {
    return _priceUpdates.where((update) => update.assetId == assetId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // 获取代理管理的资产
  List<Asset> getProxyManagedAssets() {
    return _assets.where((asset) => asset.isProxyManaged).toList();
  }

  // 获取自管理资产
  List<Asset> getSelfManagedAssets() {
    return _assets.where((asset) => !asset.isProxyManaged).toList();
  }

  // 保存数据到本地存储
  Future<void> saveData() async {
    // 如果已经在保存，直接返回
    if (_isSaving) {
      print("保存进行中，跳过重复保存");
      return;
    }

    _isSaving = true;
    print("开始保存数据 - 交易数量: ${_transactions.length}");

    try {
      final prefs = await SharedPreferences.getInstance();

      // 保存资产
      final assetsJson =
          _assets.map((asset) => jsonEncode(asset.toJson())).toList();
      await prefs.setStringList('assets', assetsJson);

      // 保存持有人
      final ownersJson =
          _owners.map((owner) => jsonEncode(owner.toJson())).toList();
      await prefs.setStringList('owners', ownersJson);

      // 保存交易
      if (_transactions.isEmpty) {
        print("没有交易需要保存");
        await prefs.setStringList('transactions', []);
      } else {
        print("保存 ${_transactions.length} 条交易");
        final List<String> transactionsJsonList = _transactions
            .map((transaction) => jsonEncode(transaction.toJson()))
            .toList();
        await prefs.setStringList('transactions', transactionsJsonList);

        // 验证保存是否成功
        final savedList = prefs.getStringList('transactions') ?? [];
        print("验证 - 已保存 ${savedList.length} 条交易");
      }

      // 保存价格更新
      final priceUpdatesJson =
          _priceUpdates.map((update) => jsonEncode(update.toJson())).toList();
      await prefs.setStringList('priceUpdates', priceUpdatesJson);

      print("保存数据完成");
    } catch (e) {
      print('保存数据出错: $e');
      rethrow;
    } finally {
      _isSaving = false;
    }
  }

  // 从本地存储加载数据
  Future<void> loadData() async {
    // 如果已经在加载或保存中，跳过
    if (_isLoading || _isSaving) {
      print("数据加载或保存进行中，跳过重复加载");
      return;
    }

    _isLoading = true;
    print("开始加载数据");

    try {
      final prefs = await SharedPreferences.getInstance();

      // 清空当前数据
      _assets.clear();
      _owners.clear();
      _transactions.clear();
      _priceUpdates.clear();

      // 加载资产
      final assetsJson = prefs.getStringList('assets') ?? [];
      _assets
          .addAll(assetsJson.map((json) => Asset.fromJson(jsonDecode(json))));

      // 加载持有人
      final ownersJson = prefs.getStringList('owners') ?? [];
      _owners
          .addAll(ownersJson.map((json) => Owner.fromJson(jsonDecode(json))));

      // 加载交易
      final transactionsJson = prefs.getStringList('transactions') ?? [];
      print("从SharedPreferences找到 ${transactionsJson.length} 条交易");

      for (String json in transactionsJson) {
        try {
          Map<String, dynamic> transactionMap = jsonDecode(json);
          Transaction transaction = Transaction.fromJson(transactionMap);
          _transactions.add(transaction);
        } catch (e) {
          print("解析交易数据出错: $e");
        }
      }

      print("成功加载 ${_transactions.length} 条交易");

      // 加载价格更新
      final priceUpdatesJson = prefs.getStringList('priceUpdates') ?? [];
      _priceUpdates.addAll(priceUpdatesJson
          .map((json) => PriceUpdate.fromJson(jsonDecode(json))));

      // 通知所有数据已变更
      _notifyDataChanged(DataChangeType.all);

      print("数据加载完成");
    } catch (e) {
      print('加载数据出错: $e');
    } finally {
      _isLoading = false;
    }
  }

  // 手动刷新数据
  Future<void> refreshData() async {
    await loadData();
  }

  // 重置所有数据
  Future<void> resetData() async {
    _assets.clear();
    _owners.clear();
    _transactions.clear();
    _priceUpdates.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _notifyDataChanged(DataChangeType.all);
  }

  // 用示例数据初始化
  Future<void> initializeWithSampleData() async {
    if (_assets.isNotEmpty || _owners.isNotEmpty) {
      return; // 如果已有数据则不初始化
    }

    // 创建示例持有人
    final owner = Owner(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '默认用户',
      shares: 100.0, // 初始份额
    );
    _owners.add(owner);

    final now = DateTime.now();

    // 创建示例资产
    final stockAsset = StockAsset(
      id: '${DateTime.now().millisecondsSinceEpoch}_1',
      name: '示例股票',
      totalValue: 10000.0,
      isProxyManaged: false,
      lastUpdated: now,
      ticker: '600000',
    );
    _assets.add(stockAsset);

    final cryptoAsset = CryptoAsset(
      id: '${DateTime.now().millisecondsSinceEpoch}_2',
      name: '示例加密货币',
      totalValue: 5000.0,
      isProxyManaged: false,
      lastUpdated: now,
      symbol: 'BTC',
    );
    _assets.add(cryptoAsset);

    final cashAsset = CashAsset(
      id: '${DateTime.now().millisecondsSinceEpoch}_3',
      name: '示例银行存款',
      totalValue: 20000.0,
      isProxyManaged: false,
      lastUpdated: now,
      bankName: '建设银行',
      accountNumber: '6217********1234',
    );
    _assets.add(cashAsset);

    // 创建示例价格更新
    _priceUpdates.add(PriceUpdate(
      id: '${DateTime.now().millisecondsSinceEpoch}_1',
      assetId: stockAsset.id,
      value: 9500.0,
      timestamp: now.subtract(const Duration(days: 30)),
      note: '初始记录',
    ));

    _priceUpdates.add(PriceUpdate(
      id: '${DateTime.now().millisecondsSinceEpoch}_2',
      assetId: stockAsset.id,
      value: 10000.0,
      timestamp: now,
      note: '最新价格',
    ));

    // 保存示例数据
    await saveData();
    _notifyDataChanged(DataChangeType.all);
  }

  // 获取所有资产
  List<Asset> getAllAssets() {
    return List.unmodifiable(_assets);
  }

  // 通知数据变更
  void _notifyDataChanged(DataChangeType type) {
    _dataChangeController.add(DataChangeEvent(type));
  }

  // 销毁服务时释放资源
  void dispose() {
    _dataChangeController.close();
  }
}
