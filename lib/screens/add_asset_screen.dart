import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/asset.dart';
import '../models/owner.dart';
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
  final _nameController = TextEditingController();
  final _currentValueController = TextEditingController();
  String _assetType = 'stock'; // 默认资产类型
  String? _selectedOwnerId;
  bool _isProxyManaged = false;

  // 股票特有字段
  final _tickerController = TextEditingController();
  final _sharesController = TextEditingController();
  final _stockPurchasePriceController = TextEditingController();

  // 加密货币特有字段
  final _symbolController = TextEditingController();
  final _amountController = TextEditingController();
  final _cryptoPurchasePriceController = TextEditingController();

  // 现金特有字段
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _interestRateController = TextEditingController(text: '0.0');

  @override
  void dispose() {
    _nameController.dispose();
    _currentValueController.dispose();
    _tickerController.dispose();
    _sharesController.dispose();
    _stockPurchasePriceController.dispose();
    _symbolController.dispose();
    _amountController.dispose();
    _cryptoPurchasePriceController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _interestRateController.dispose();
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
              _buildOwnershipFields(),
              const SizedBox(height: 24),
              _buildAssetTypeSpecificFields(),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _saveAsset,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text('保存资产'),
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
          controller: _currentValueController,
          decoration: const InputDecoration(
            labelText: '当前单价',
            hintText: '输入当前市场价格',
            border: OutlineInputBorder(),
            prefixText: '¥ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入当前价格';
            }
            if (double.tryParse(value) == null) {
              return '请输入有效的数字';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOwnershipFields() {
    final owners = widget.portfolioService.owners;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '所有权信息',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (owners.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              '没有持有人记录，请在持有人页面添加',
              style: TextStyle(color: Colors.red),
            ),
          ),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: '所有人',
            border: OutlineInputBorder(),
          ),
          value: _selectedOwnerId,
          items: [
            ...owners.map((owner) => DropdownMenuItem(
                  value: owner.id,
                  child: Text(owner.name),
                )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedOwnerId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请选择所有人';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        TextFormField(
          controller: _sharesController,
          decoration: const InputDecoration(
            labelText: '持有股数',
            hintText: '输入持有的股数',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (_assetType == 'stock' && (value == null || value.isEmpty)) {
              return '请输入持有股数';
            }
            if (_assetType == 'stock' && double.tryParse(value!) == null) {
              return '请输入有效的数字';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _stockPurchasePriceController,
          decoration: const InputDecoration(
            labelText: '买入价格',
            hintText: '输入买入时的单价',
            border: OutlineInputBorder(),
            prefixText: '¥ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (_assetType == 'stock' && (value == null || value.isEmpty)) {
              return '请输入买入价格';
            }
            if (_assetType == 'stock' && double.tryParse(value!) == null) {
              return '请输入有效的数字';
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
        const SizedBox(height: 16),
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(
            labelText: '持有数量',
            hintText: '输入持有的币数量',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (_assetType == 'crypto' && (value == null || value.isEmpty)) {
              return '请输入持有数量';
            }
            if (_assetType == 'crypto' && double.tryParse(value!) == null) {
              return '请输入有效的数字';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cryptoPurchasePriceController,
          decoration: const InputDecoration(
            labelText: '买入价格',
            hintText: '输入买入时的单价',
            border: OutlineInputBorder(),
            prefixText: '¥ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (_assetType == 'crypto' && (value == null || value.isEmpty)) {
              return '请输入买入价格';
            }
            if (_assetType == 'crypto' && double.tryParse(value!) == null) {
              return '请输入有效的数字';
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
        const SizedBox(height: 16),
        TextFormField(
          controller: _interestRateController,
          decoration: const InputDecoration(
            labelText: '年利率',
            hintText: '例如：0.03 表示 3%',
            border: OutlineInputBorder(),
            suffixText: '%',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (_assetType == 'cash' && (value == null || value.isEmpty)) {
              return '请输入年利率';
            }
            if (_assetType == 'cash' && double.tryParse(value!) == null) {
              return '请输入有效的数字';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _saveAsset() {
    if (_formKey.currentState!.validate() && _selectedOwnerId != null) {
      final assetId = const Uuid().v4();
      final name = _nameController.text;
      final currentValue = double.parse(_currentValueController.text);
      final ownerId = _selectedOwnerId!;
      final now = DateTime.now();

      Asset newAsset;

      switch (_assetType) {
        case 'stock':
          newAsset = StockAsset(
            id: assetId,
            name: name,
            currentValue: currentValue,
            ownerId: ownerId,
            isProxyManaged: _isProxyManaged,
            lastUpdated: now,
            ticker: _tickerController.text,
            shares: double.parse(_sharesController.text),
            purchasePrice: double.parse(_stockPurchasePriceController.text),
          );
          break;

        case 'crypto':
          newAsset = CryptoAsset(
            id: assetId,
            name: name,
            currentValue: currentValue,
            ownerId: ownerId,
            isProxyManaged: _isProxyManaged,
            lastUpdated: now,
            symbol: _symbolController.text,
            amount: double.parse(_amountController.text),
            purchasePrice: double.parse(_cryptoPurchasePriceController.text),
          );
          break;

        case 'cash':
          newAsset = CashAsset(
            id: assetId,
            name: name,
            currentValue: currentValue, // 现金的当前价值就是存入的金额
            ownerId: ownerId,
            isProxyManaged: _isProxyManaged,
            lastUpdated: now,
            bankName: _bankNameController.text,
            accountNumber: _accountNumberController.text,
            interestRate:
                double.parse(_interestRateController.text) / 100, // 转换为小数
          );
          break;

        default:
          return;
      }

      widget.portfolioService.addAsset(newAsset);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('资产添加成功')),
      );

      Navigator.pop(context, true); // 返回并传递更新标志
    } else if (_selectedOwnerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在持有人页面添加持有人')),
      );
    }
  }
}
