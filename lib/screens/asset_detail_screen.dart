import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../models/price_update.dart';
import '../services/portfolio_service.dart';
import 'update_asset_value_screen.dart';
import 'package:intl/intl.dart';

class AssetDetailScreen extends StatefulWidget {
  final Asset asset;
  final PortfolioService portfolioService;

  const AssetDetailScreen({
    Key? key,
    required this.asset,
    required this.portfolioService,
  }) : super(key: key);

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  late List<PriceUpdate> valueUpdates;

  @override
  void initState() {
    super.initState();
    _loadValueUpdates();
  }

  void _loadValueUpdates() {
    setState(() {
      valueUpdates =
          widget.portfolioService.getValueUpdatesForAsset(widget.asset.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.asset.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 编辑资产的逻辑
            },
            tooltip: '编辑资产',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // 删除资产的逻辑
            },
            tooltip: '删除资产',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAssetInfoCard(),
              const SizedBox(height: 16),
              _buildAssetDetailsCard(),
              const SizedBox(height: 16),
              _buildValueUpdateHistoryCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateAssetValueScreen(
                asset: widget.asset,
                portfolioService: widget.portfolioService,
              ),
            ),
          ).then((updated) {
            if (updated == true) {
              setState(() {
                _loadValueUpdates();
              });
            }
          });
        },
        child: const Icon(Icons.update),
        tooltip: '更新价值',
      ),
    );
  }

  Widget _buildAssetInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.asset.name,
                  style: Theme.of(context).textTheme.headline5,
                ),
                Text(
                  '¥${widget.asset.totalValue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
            const Divider(),
            _buildAssetSpecificInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetDetailsCard() {
    String ownerName = _findOwnerName() ?? '未知';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '资产详情',
              style: Theme.of(context).textTheme.headline6,
            ),
            const Divider(),
            _buildDetailRow('所有人', ownerName),
            _buildDetailRow(
                '管理方式', widget.asset.isProxyManaged ? '代理管理' : '自我管理'),
            _buildDetailRow(
                '最后更新',
                DateFormat('yyyy-MM-dd HH:mm')
                    .format(widget.asset.lastUpdated)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetSpecificInfo() {
    if (widget.asset is StockAsset) {
      final stockAsset = widget.asset as StockAsset;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('股票代码: ${stockAsset.ticker}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('购买价格: ¥${stockAsset.purchasePrice.toStringAsFixed(2)}'),
              Text(
                '收益率: ${_calculateProfitPercentage(stockAsset.totalValue, stockAsset.purchasePrice)}%',
                style: TextStyle(
                  color: stockAsset.totalValue >= stockAsset.purchasePrice
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (widget.asset is CryptoAsset) {
      final cryptoAsset = widget.asset as CryptoAsset;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('代币符号: ${cryptoAsset.symbol}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('购买价格: ¥${cryptoAsset.purchasePrice.toStringAsFixed(2)}'),
              Text(
                '收益率: ${_calculateProfitPercentage(cryptoAsset.totalValue, cryptoAsset.purchasePrice)}%',
                style: TextStyle(
                  color: cryptoAsset.totalValue >= cryptoAsset.purchasePrice
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (widget.asset is CashAsset) {
      final cashAsset = widget.asset as CashAsset;
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('银行: ${cashAsset.bankName}'),
              Text('账号: ${_maskAccountNumber(cashAsset.accountNumber)}'),
            ],
          ),
          if (cashAsset.interestRate > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('利率: ${cashAsset.interestRate}%'),
            ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildValueUpdateHistoryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '价值更新历史',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8),
            valueUpdates.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('暂无价值更新记录'),
                    ),
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: valueUpdates.length,
                    itemBuilder: (context, index) {
                      final update = valueUpdates[index];
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('¥${update.value.toStringAsFixed(2)}'),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm')
                                  .format(update.timestamp),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        ),
                        subtitle:
                            update.note != null ? Text(update.note!) : null,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _calculateProfitPercentage(double currentValue, double purchasePrice) {
    if (purchasePrice == 0) return '0.00';
    double percentage = ((currentValue - purchasePrice) / purchasePrice) * 100;
    return percentage.toStringAsFixed(2);
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 8) return accountNumber;
    return '${accountNumber.substring(0, 4)}****${accountNumber.substring(accountNumber.length - 4)}';
  }

  String? _findOwnerName() {
    try {
      final owner = widget.portfolioService.owners
          .firstWhere((o) => o.id == widget.asset.ownerId);
      return owner.name;
    } catch (e) {
      return null;
    }
  }
}
