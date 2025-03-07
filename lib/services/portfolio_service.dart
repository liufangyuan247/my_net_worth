import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asset.dart';
import '../models/owner.dart';
import '../models/transaction.dart';
import '../models/price_update.dart';

class PortfolioService {
  List<Asset> _assets = [];
  List<Owner> _owners = [];
  List<Transaction> _transactions = [];
  List<PriceUpdate> _priceUpdates = [];

  // Getters for lists
  List<Asset> get assets => _assets;
  List<Owner> get owners => _owners;
  List<Transaction> get transactions => _transactions;
  List<PriceUpdate> get priceUpdates => _priceUpdates;

  // Calculate total asset value
  double getTotalAssetValue() {
    return _assets.fold(0, (sum, asset) => sum + asset.getValue());
  }

  // Calculate total shares
  double getTotalShares() {
    return _owners.fold(0, (sum, owner) => sum + owner.shares);
  }

  // Calculate current net value
  double calculateNetValue() {
    double totalValue = getTotalAssetValue();
    double totalShares = getTotalShares();

    if (totalShares <= 0) return 1.0; // Default initial net value
    return totalValue / totalShares;
  }

  // Add asset
  void addAsset(Asset asset) {
    _assets.add(asset);
    saveData();
  }

  // Update asset
  void updateAsset(Asset asset) {
    int index = _assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      _assets[index] = asset;
      saveData();
    }
  }

  // Delete asset
  void deleteAsset(String assetId) {
    _assets.removeWhere((asset) => asset.id == assetId);
    _priceUpdates.removeWhere((update) =>
        update.assetId == assetId); // Clean up related price updates
    saveData();
  }

  // Add owner
  void addOwner(Owner owner) {
    _owners.add(owner);
    saveData();
  }

  // Process transaction
  void processTransaction(String ownerId, double amount,
      TransactionType transactionType, String notes) {
    double currentNetValue = calculateNetValue();
    double sharesChange = amount / currentNetValue;

    // Find owner
    int ownerIndex = _owners.indexWhere((o) => o.id == ownerId);
    if (ownerIndex == -1) {
      throw Exception('Owner not found');
    }

    Owner owner = _owners[ownerIndex];

    if (transactionType == TransactionType.deposit) {
      // Add shares for deposit
      owner.shares += sharesChange;
    } else {
      // Remove shares for withdrawal
      if (owner.shares < sharesChange) {
        throw Exception('Insufficient shares for withdrawal');
      }
      owner.shares -= sharesChange;
    }

    // Record transaction
    _transactions.add(Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: ownerId,
      amount: amount,
      shares: sharesChange,
      netValueAtTransaction: currentNetValue,
      type: transactionType,
      timestamp: DateTime.now(),
      notes: notes,
    ));

    saveData();
  }

  // Record asset value update
  Future<void> recordAssetValueUpdate(String assetId, double newValue,
      {String? note}) async {
    final asset = _assets.firstWhere(
      (a) => a.id == assetId,
      orElse: () => throw Exception('Asset not found'),
    );

    // Create a new value update record
    final priceUpdate = PriceUpdate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      assetId: assetId,
      value: newValue,
      timestamp: DateTime.now(),
      note: note,
    );

    // Update the asset's current value
    asset.updateValue(newValue);

    // Add the price update to the list
    _priceUpdates.add(priceUpdate);

    // Save the data
    await saveData();
  }

  // Get price updates for an asset
  List<PriceUpdate> getValueUpdatesForAsset(String assetId) {
    return _priceUpdates.where((update) => update.assetId == assetId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get proxy managed assets
  List<Asset> getProxyManagedAssets() {
    return _assets.where((asset) => asset.isProxyManaged).toList();
  }

  // Get assets by owner
  List<Asset> getAssetsByOwner(String ownerId) {
    return _assets.where((asset) => asset.ownerId == ownerId).toList();
  }

  // Save data to local storage
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save assets
    final assetsJson =
        _assets.map((asset) => jsonEncode(asset.toJson())).toList();
    await prefs.setStringList('assets', assetsJson);

    // Save owners
    final ownersJson =
        _owners.map((owner) => jsonEncode(owner.toJson())).toList();
    await prefs.setStringList('owners', ownersJson);

    // Save transactions
    final transactionsJson = _transactions
        .map((transaction) => jsonEncode(transaction.toJson()))
        .toList();
    await prefs.setStringList('transactions', transactionsJson);

    // Save price updates
    final priceUpdatesJson =
        _priceUpdates.map((update) => jsonEncode(update.toJson())).toList();
    await prefs.setStringList('priceUpdates', priceUpdatesJson);
  }

  // Load data from local storage
  Future<void> loadData() async {
    // Implement loading data from SharedPreferences
    // ...
  }
}
