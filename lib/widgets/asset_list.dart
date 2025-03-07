import 'package:flutter/material.dart';
import '../models/asset.dart';

class AssetList extends StatelessWidget {
  final List<Asset> assets;
  final Function(Asset) onTap;
  final bool showOwner;

  const AssetList({
    Key? key,
    required this.assets,
    required this.onTap,
    this.showOwner = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const Center(
        child: Text('暂无资产记录，请点击右下角 + 按钮添加'),
      );
    }

    return ListView.builder(
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return AssetListItem(
          asset: asset,
          onTap: () => onTap(asset),
        );
      },
    );
  }
}

class AssetListItem extends StatelessWidget {
  final Asset asset;
  final VoidCallback onTap;

  const AssetListItem({
    Key? key,
    required this.asset,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: _buildAssetIcon(context),
        title: Text(
          asset.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Text(
              '价值: ¥${asset.getValue().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 2.0),
            Text(
              '最后更新: ${_formatDate(asset.lastUpdated)}',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).primaryColor,
          size: 16.0,
        ),
        onTap: onTap,
      ),
    );
  }

  Color getAssetTypeColor(BuildContext context, String type) {
    switch (type) {
      case 'stock':
        return Theme.of(context).primaryColor;
      case 'crypto':
        return Colors.purple;
      case 'cash':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAssetIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    if (asset is StockAsset) {
      iconData = Icons.show_chart;
      iconColor = getAssetTypeColor(context, 'stock');
    } else if (asset is CryptoAsset) {
      iconData = Icons.currency_bitcoin;
      iconColor = getAssetTypeColor(context, 'crypto');
    } else if (asset is CashAsset) {
      iconData = Icons.account_balance;
      iconColor = getAssetTypeColor(context, 'cash');
    } else {
      iconData = Icons.attach_money;
      iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.2),
      child: Icon(
        iconData,
        color: iconColor,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}

class AssetTypeFilter extends StatelessWidget {
  final String? selectedType;
  final Function(String?) onTypeSelected;

  const AssetTypeFilter({
    Key? key,
    this.selectedType,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('全部', null),
          const SizedBox(width: 8.0),
          _buildFilterChip('股票', 'stock'),
          const SizedBox(width: 8.0),
          _buildFilterChip('加密货币', 'crypto'),
          const SizedBox(width: 8.0),
          _buildFilterChip('现金', 'cash'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = selectedType == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTypeSelected(value),
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue,
    );
  }
}
