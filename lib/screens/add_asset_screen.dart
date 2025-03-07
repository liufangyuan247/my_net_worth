import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../services/portfolio_service.dart';

class AddAssetScreen extends StatefulWidget {
  final PortfolioService portfolioService;
  final Asset? assetToEdit;

  const AddAssetScreen({
    Key? key,
    required this.portfolioService,
    this.assetToEdit,
  }) : super(key: key);

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  AssetType _selectedType = AssetType.other;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.assetToEdit != null) {
      // 编辑模式 - 填充现有数据
      _nameController.text = widget.assetToEdit!.name;
      _valueController.text = widget.assetToEdit!.totalValue.toString();
      _selectedType = widget.assetToEdit!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assetToEdit == null ? '添加资产' : '编辑资产'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '资产名称',
                        hintText: '例如：中国银行股票、比特币、建设银行存款等',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入资产名称';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _valueController,
                      decoration: const InputDecoration(
                        labelText: '资产价值',
                        hintText: '当前市值或估值',
                        prefixText: '¥ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入资产价值';
                        }
                        if (double.tryParse(value) == null) {
                          return '请输入有效的数值';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '资产类型',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAssetTypeSelector(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveAsset,
                        child: Text(
                          widget.assetToEdit == null ? '添加资产' : '保存修改',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAssetTypeSelector() {
    return Column(
      children: [
        _buildAssetTypeOption(AssetType.stock, '股票', Icons.trending_up),
        _buildAssetTypeOption(AssetType.crypto, '加密货币', Icons.currency_bitcoin),
        _buildAssetTypeOption(AssetType.cash, '现金/存款', Icons.account_balance),
        _buildAssetTypeOption(AssetType.realEstate, '房地产', Icons.home),
        _buildAssetTypeOption(AssetType.other, '其他', Icons.category),
      ],
    );
  }

  Widget _buildAssetTypeOption(AssetType type, String label, IconData icon) {
    return RadioListTile<AssetType>(
      title: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
      value: type,
      groupValue: _selectedType,
      onChanged: (AssetType? value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
          });
        }
      },
    );
  }

  void _saveAsset() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final double value = double.parse(_valueController.text);
        final String name = _nameController.text.trim();
        final now = DateTime.now();

        Asset asset;
        switch (_selectedType) {
          case AssetType.stock:
            asset = StockAsset(
              id: widget.assetToEdit?.id ??
                  now.millisecondsSinceEpoch.toString(),
              name: name,
              totalValue: value,
              lastUpdated: now,
            );
            break;
          case AssetType.crypto:
            asset = CryptoAsset(
              id: widget.assetToEdit?.id ??
                  now.millisecondsSinceEpoch.toString(),
              name: name,
              totalValue: value,
              lastUpdated: now,
            );
            break;
          case AssetType.cash:
            asset = CashAsset(
              id: widget.assetToEdit?.id ??
                  now.millisecondsSinceEpoch.toString(),
              name: name,
              totalValue: value,
              lastUpdated: now,
            );
            break;
          case AssetType.realEstate:
            asset = RealEstateAsset(
              id: widget.assetToEdit?.id ??
                  now.millisecondsSinceEpoch.toString(),
              name: name,
              totalValue: value,
              lastUpdated: now,
            );
            break;
          case AssetType.other:
          default:
            asset = OtherAsset(
              id: widget.assetToEdit?.id ??
                  now.millisecondsSinceEpoch.toString(),
              name: name,
              totalValue: value,
              lastUpdated: now,
            );
        }

        if (widget.assetToEdit == null) {
          // 添加新资产
          await widget.portfolioService.addAsset(asset);
        } else {
          // 更新现有资产
          await widget.portfolioService.updateAsset(asset);
        }

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
