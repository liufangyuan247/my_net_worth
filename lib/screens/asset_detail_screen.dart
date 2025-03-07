import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../services/portfolio_service.dart';
import 'edit_asset_screen.dart';

class AssetDetailScreen extends StatelessWidget {
  final Asset asset;
  final PortfolioService portfolioService;

  const AssetDetailScreen({
    Key? key,
    required this.asset,
    required this.portfolioService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('资产详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditScreen(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24.0),
            _buildAssetDetailsCard(context),
            const SizedBox(height: 24.0),
            _buildTypeSpecificDetails(),
            const SizedBox(height: 24.0),
            _buildOwnershipDetails(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUpdateValueDialog(context),
        child: const Icon(Icons.refresh),
        tooltip: '更新当前价值',
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildAssetTypeIcon(),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    _getAssetTypeName(),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetDetailsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '资产价值',
              style: Theme.of(context).textTheme.headline6,
            ),
            const Divider(),
            _buildDetailRow(
                '当前单价', '¥${asset.currentValue.toStringAsFixed(2)}'),
            _buildDetailRow('总价值', '¥${asset.getValue().toStringAsFixed(2)}'),
            _buildDetailRow('最后更新', _formatDateTime(asset.lastUpdated)),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSpecificDetails() {
    if (asset is StockAsset) {
      final stockAsset = asset as StockAsset;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '股票详情',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _buildDetailRow('股票代码', stockAsset.ticker),
              _buildDetailRow('持有股数', stockAsset.shares.toString()),
              _buildDetailRow(
                  '买入价', '¥${stockAsset.purchasePrice.toStringAsFixed(2)}'),
              _buildDetailRow('盈亏比例',
                  '${_calculateProfitPercentage(stockAsset.currentValue, stockAsset.purchasePrice)}%'),
            ],
          ),
        ),
      );
    } else if (asset is CryptoAsset) {
      final cryptoAsset = asset as CryptoAsset;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '加密货币详情',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _buildDetailRow('币种符号', cryptoAsset.symbol),
              _buildDetailRow('持有数量', cryptoAsset.amount.toString()),
              _buildDetailRow(
                  '买入价', '¥${cryptoAsset.purchasePrice.toStringAsFixed(2)}'),
              _buildDetailRow('盈亏比例',
                  '${_calculateProfitPercentage(cryptoAsset.currentValue, cryptoAsset.purchasePrice)}%'),
            ],
          ),
        ),
      );
    } else if (asset is CashAsset) {
      final cashAsset = asset as CashAsset;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '现金详情',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _buildDetailRow('银行', cashAsset.bankName),
              _buildDetailRow(
                  '账户号码', _maskAccountNumber(cashAsset.accountNumber)),
              _buildDetailRow('利率',
                  '${(cashAsset.interestRate * 100).toStringAsFixed(2)}%'),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildOwnershipDetails(BuildContext context) {
    final ownerName = _findOwnerName();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '所有权信息',
              style: Theme.of(context).textTheme.headline6,
            ),
            const Divider(),
            _buildDetailRow('所有人ID', asset.ownerId),
            _buildDetailRow('所有人姓名', ownerName ?? '未知'),
            _buildDetailRow(
              '管理方式',
              asset.isProxyManaged ? '代理管理' : '自我管理',
              valueColor: asset.isProxyManaged ? Colors.orange : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetTypeIcon() {
    IconData iconData;
    Color iconColor;

    if (asset is StockAsset) {
      iconData = Icons.show_chart;
      iconColor = Colors.blue;
    } else if (asset is CryptoAsset) {
      iconData = Icons.currency_bitcoin;
      iconColor = Colors.orange;
    } else if (asset is CashAsset) {
      iconData = Icons.account_balance;
      iconColor = Colors.green;
    } else {
      iconData = Icons.attach_money;
      iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(
        iconData,
        size: 32.0,
        color: iconColor,
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAssetScreen(
          asset: asset,
          portfolioService: portfolioService,
        ),
      ),
    ).then((updated) {
      if (updated == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('资产信息已更新')),
        );
        Navigator.pop(context, true); // 返回并刷新前一页面
      }
    });
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除资产'),
        content: Text('确定要删除 ${asset.name} 吗？这个操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              portfolioService.deleteAsset(asset.id);
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context, true); // 返回并刷新前一页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('资产已删除')),
              );
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUpdateValueDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: asset.currentValue.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更新资产价值'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '新的价值',
            hintText: '请输入最新单价',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text);
              if (newValue != null) {
                asset.updateValue(newValue);
                portfolioService.updateAsset(asset);
                Navigator.pop(context);
                Navigator.pop(context, true); // 返回并刷新前一页面
              }
            },
            child: const Text('更新'),
          ),
        ],
      ),
    );
  }

  String _getAssetTypeName() {
    if (asset is StockAsset) {
      return '股票';
    } else if (asset is CryptoAsset) {
      return '加密货币';
    } else if (asset is CashAsset) {
      return '现金';
    }
    return '其他资产';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _calculateProfitPercentage(double currentPrice, double purchasePrice) {
    if (purchasePrice == 0) return '0.00';
    double percentage = ((currentPrice - purchasePrice) / purchasePrice) * 100;
    return percentage.toStringAsFixed(2);
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 8) return accountNumber;
    return '${accountNumber.substring(0, 4)}****${accountNumber.substring(accountNumber.length - 4)}';
  }

  String? _findOwnerName() {
    try {
      final owner =
          portfolioService.owners.firstWhere((o) => o.id == asset.ownerId);
      return owner.name;
    } catch (e) {
      return null;
    }
  }
}
