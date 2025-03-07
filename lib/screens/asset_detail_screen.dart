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
            onPressed: _showDeleteConfirmationDialog,
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

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除资产'),
        content: Text('确定要删除 ${widget.asset.name} 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              widget.portfolioService.deleteAsset(widget.asset.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return to previous screen
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
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
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '¥${widget.asset.totalValue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            _buildAssetTypeSpecificInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetDetailsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '资产详情',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildDetailRow(
                '管理方式', widget.asset.isProxyManaged ? '代理管理' : '自我管理'),
            _buildDetailRow(
                '最后更新',
                DateFormat('yyyy-MM-dd HH:mm')
                    .format(widget.asset.lastUpdated)),
            _buildDetailRow('资产类型', _getAssetTypeName()),
          ],
        ),
      ),
    );
  }

  String _getAssetTypeName() {
    if (widget.asset is StockAsset) {
      return '股票';
    } else if (widget.asset is CryptoAsset) {
      return '加密货币';
    } else if (widget.asset is CashAsset) {
      return '现金';
    }
    return '其他资产';
  }

  Widget _buildAssetTypeSpecificInfo() {
    if (widget.asset is StockAsset) {
      final stockAsset = widget.asset as StockAsset;
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('股票代码: ${stockAsset.ticker}'),
        ],
      );
    } else if (widget.asset is CryptoAsset) {
      final cryptoAsset = widget.asset as CryptoAsset;
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('代币符号: ${cryptoAsset.symbol}'),
        ],
      );
    } else if (widget.asset is CashAsset) {
      final cashAsset = widget.asset as CashAsset;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('银行: ${cashAsset.bankName}'),
          const SizedBox(height: 4),
          Text('账号: ${_maskAccountNumber(cashAsset.accountNumber)}'),
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
              style: Theme.of(context).textTheme.titleLarge,
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
                              style: Theme.of(context).textTheme.bodySmall,
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

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 8) return accountNumber;
    return '${accountNumber.substring(0, 4)}****${accountNumber.substring(accountNumber.length - 4)}';
  }
}
