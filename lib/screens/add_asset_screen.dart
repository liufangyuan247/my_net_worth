import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../services/portfolio_service.dart';

class AddAssetScreen extends StatefulWidget {
  final PortfolioService portfolioService;

  const AddAssetScreen({
    Key? key,
    required this.portfolioService,
  }) : super(key: key);

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();

  // General asset fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalValueController = TextEditingController();

  // Stock specific fields
  final TextEditingController _tickerController = TextEditingController();

  // Crypto specific fields
  final TextEditingController _symbolController = TextEditingController();

  // Cash specific fields
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();

  String _assetType = 'stock'; // Default asset type
  bool _isProxyManaged = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _totalValueController.dispose();
    _tickerController.dispose();
    _symbolController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加资产'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAssetTypeSelector(),
              const SizedBox(height: 24),
              _buildBasicInfoFields(),
              const SizedBox(height: 24),
              _buildManagementFields(),
              const SizedBox(height: 24),
              _buildAssetTypeSpecificFields(),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _saveAsset,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator()
                      : const Text('保存资产'),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '资产类型',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: 'stock',
              label: Text('股票'),
              icon: Icon(Icons.show_chart),
            ),
            ButtonSegment<String>(
              value: 'crypto',
              label: Text('加密货币'),
              icon: Icon(Icons.currency_bitcoin),
            ),
            ButtonSegment<String>(
              value: 'cash',
              label: Text('现金'),
              icon: Icon(Icons.account_balance),
            ),
          ],
          selected: {_assetType},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _assetType = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBasicInfoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '基本信息',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '资产名称',
            hintText: '输入资产名称',
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
          controller: _totalValueController,
          decoration: const InputDecoration(
            labelText: '当前总价值',
            hintText: '输入资产当前总价值',
            border: OutlineInputBorder(),
            prefixText: '¥ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入当前总价值';
            }
            if (double.tryParse(value) == null) {
              return '请输入有效的数字';
            }
            if (double.parse(value) < 0) {
              return '价值不能为负数';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildManagementFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '管理信息',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('代理管理'),
          subtitle: const Text('此资产是否为代表他人管理'),
          value: _isProxyManaged,
          onChanged: (value) {
            setState(() {
              _isProxyManaged = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAssetTypeSpecificFields() {
    switch (_assetType) {
      case 'stock':
        return _buildStockFields();
      case 'crypto':
        return _buildCryptoFields();
      case 'cash':
        return _buildCashFields();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStockFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '股票详情',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _tickerController,
          decoration: const InputDecoration(
            labelText: '股票代码',
            hintText: '例如：AAPL、600000',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (_assetType == 'stock' && (value == null || value.isEmpty)) {
              return '请输入股票代码';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCryptoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '加密货币详情',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _symbolController,
          decoration: const InputDecoration(
            labelText: '币种符号',
            hintText: '例如：BTC、ETH',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (_assetType == 'crypto' && (value == null || value.isEmpty)) {
              return '请输入币种符号';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCashFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '现金详情',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bankNameController,
          decoration: const InputDecoration(
            labelText: '银行名称',
            hintText: '例如：工商银行、中国银行',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (_assetType == 'cash' && (value == null || value.isEmpty)) {
              return '请输入银行名称';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountNumberController,
          decoration: const InputDecoration(
            labelText: '账号',
            hintText: '输入银行账号',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (_assetType == 'cash' && (value == null || value.isEmpty)) {
              return '请输入账号';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _saveAsset() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      try {
        final assetId = DateTime.now().millisecondsSinceEpoch.toString();
        final name = _nameController.text;
        final totalValue = double.parse(_totalValueController.text);
        final now = DateTime.now();

        Asset newAsset;

        switch (_assetType) {
          case 'stock':
            newAsset = StockAsset(
              id: assetId,
              name: name,
              totalValue: totalValue,
              isProxyManaged: _isProxyManaged,
              lastUpdated: now,
              ticker: _tickerController.text,
            );
            break;

          case 'crypto':
            newAsset = CryptoAsset(
              id: assetId,
              name: name,
              totalValue: totalValue,
              isProxyManaged: _isProxyManaged,
              lastUpdated: now,
              symbol: _symbolController.text,
            );
            break;

          case 'cash':
            newAsset = CashAsset(
              id: assetId,
              name: name,
              totalValue: totalValue,
              isProxyManaged: _isProxyManaged,
              lastUpdated: now,
              bankName: _bankNameController.text,
              accountNumber: _accountNumberController.text,
            );
            break;

          default:
            throw Exception("Unknown asset type");
        }

        widget.portfolioService.addAsset(newAsset);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('资产添加成功'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // 返回并传递更新标志
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('添加资产失败: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }
}
