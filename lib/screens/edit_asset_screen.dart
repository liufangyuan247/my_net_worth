import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../models/owner.dart';
import '../services/portfolio_service.dart';

class EditAssetScreen extends StatefulWidget {
  final Asset asset;
  final PortfolioService portfolioService;

  const EditAssetScreen({
    Key? key,
    required this.asset,
    required this.portfolioService,
  }) : super(key: key);

  @override
  State<EditAssetScreen> createState() => _EditAssetScreenState();
}

class _EditAssetScreenState extends State<EditAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _currentValueController;
  late String _selectedOwnerId;
  late bool _isProxyManaged;

  // 股票特有字段
  late TextEditingController _tickerController;
  late TextEditingController _sharesController;
  late TextEditingController _stockPurchasePriceController;

  // 加密货币特有字段
  late TextEditingController _symbolController;
  late TextEditingController _amountController;
  late TextEditingController _cryptoPurchasePriceController;

  // 现金特有字段
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _interestRateController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // 基本信息初始化
    _nameController = TextEditingController(text: widget.asset.name);
    _currentValueController =
        TextEditingController(text: widget.asset.currentValue.toString());
    _selectedOwnerId = widget.asset.ownerId;
    _isProxyManaged = widget.asset.isProxyManaged;

    // 根据资产类型初始化特定控制器
    if (widget.asset is StockAsset) {
      final stockAsset = widget.asset as StockAsset;
      _tickerController = TextEditingController(text: stockAsset.ticker);
      _sharesController =
          TextEditingController(text: stockAsset.shares.toString());
      _stockPurchasePriceController =
          TextEditingController(text: stockAsset.purchasePrice.toString());
    } else {
      _tickerController = TextEditingController();
      _sharesController = TextEditingController();
      _stockPurchasePriceController = TextEditingController();
    }

    if (widget.asset is CryptoAsset) {
      final cryptoAsset = widget.asset as CryptoAsset;
      _symbolController = TextEditingController(text: cryptoAsset.symbol);
      _amountController =
          TextEditingController(text: cryptoAsset.amount.toString());
      _cryptoPurchasePriceController =
          TextEditingController(text: cryptoAsset.purchasePrice.toString());
    } else {
      _symbolController = TextEditingController();
      _amountController = TextEditingController();
      _cryptoPurchasePriceController = TextEditingController();
    }

    if (widget.asset is CashAsset) {
      final cashAsset = widget.asset as CashAsset;
      _bankNameController = TextEditingController(text: cashAsset.bankName);
      _accountNumberController =
          TextEditingController(text: cashAsset.accountNumber);
      _interestRateController = TextEditingController(
          text: (cashAsset.interestRate * 100).toString());
    } else {
      _bankNameController = TextEditingController();
      _accountNumberController = TextEditingController();
      _interestRateController = TextEditingController();
    }
  }

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
        title: const Text('编辑资产'),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAssetTypeIndicator(),
              const SizedBox(height: 24),
              _buildBasicInfoFields(),
              const SizedBox(height: 24),
              _buildOwnershipFields(),
              const SizedBox(height: 24),
              _buildAssetTypeSpecificFields(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetTypeIndicator() {
    String assetType;
    Color backgroundColor;
    IconData icon;

    if (widget.asset is StockAsset) {
      assetType = '股票';
      backgroundColor = Colors.blue.shade100;
      icon = Icons.show_chart;
    } else if (widget.asset is CryptoAsset) {
      assetType = '加密货币';
      backgroundColor = Colors.orange.shade100;
      icon = Icons.currency_bitcoin;
    } else if (widget.asset is CashAsset) {
      assetType = '现金';
      backgroundColor = Colors.green.shade100;
      icon = Icons.account_balance;
    } else {
      assetType = '未知资产类型';
      backgroundColor = Colors.grey.shade100;
      icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8.0),
          Text(
            assetType,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
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
            if (value != null) {
              setState(() {
                _selectedOwnerId = value;
              });
            }
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
    if (widget.asset is StockAsset) {
      return _buildStockFields();
    } else if (widget.asset is CryptoAsset) {
      return _buildCryptoFields();
    } else if (widget.asset is CashAsset) {
      return _buildCashFields();
    }
    return const SizedBox.shrink();
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
            if (value == null || value.isEmpty) {
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
            if (value == null || value.isEmpty) {
              return '请输入持有股数';
            }
            if (double.tryParse(value) == null) {
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
            if (value == null || value.isEmpty) {
              return '请输入买入价格';
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
            if (value == null || value.isEmpty) {
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
            if (value == null || value.isEmpty) {
              return '请输入持有数量';
            }
            if (double.tryParse(value) == null) {
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
            if (value == null || value.isEmpty) {
              return '请输入买入价格';
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
            if (value == null || value.isEmpty) {
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
            if (value == null || value.isEmpty) {
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
            if (value == null || value.isEmpty) {
              return '请输入年利率';
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

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final currentValue = double.parse(_currentValueController.text);

      if (widget.asset is StockAsset) {
        final stockAsset = widget.asset as StockAsset;
        stockAsset.name = name;
        stockAsset.currentValue = currentValue;
        stockAsset.ownerId = _selectedOwnerId;
        stockAsset.isProxyManaged = _isProxyManaged;
        stockAsset.lastUpdated = DateTime.now();
        stockAsset.ticker = _tickerController.text;
        stockAsset.shares = double.parse(_sharesController.text);
        stockAsset.purchasePrice =
            double.parse(_stockPurchasePriceController.text);
      } else if (widget.asset is CryptoAsset) {
        final cryptoAsset = widget.asset as CryptoAsset;
        cryptoAsset.name = name;
        cryptoAsset.currentValue = currentValue;
        cryptoAsset.ownerId = _selectedOwnerId;
        cryptoAsset.isProxyManaged = _isProxyManaged;
        cryptoAsset.lastUpdated = DateTime.now();
        cryptoAsset.symbol = _symbolController.text;
        cryptoAsset.amount = double.parse(_amountController.text);
        cryptoAsset.purchasePrice =
            double.parse(_cryptoPurchasePriceController.text);
      } else if (widget.asset is CashAsset) {
        final cashAsset = widget.asset as CashAsset;
        cashAsset.name = name;
        cashAsset.currentValue = currentValue;
        cashAsset.ownerId = _selectedOwnerId;
        cashAsset.isProxyManaged = _isProxyManaged;
        cashAsset.lastUpdated = DateTime.now();
        cashAsset.bankName = _bankNameController.text;
        cashAsset.accountNumber = _accountNumberController.text;
        cashAsset.interestRate =
            double.parse(_interestRateController.text) / 100;
      }

      widget.portfolioService.updateAsset(widget.asset);
      Navigator.pop(context, true); // 返回并传递更新标志
    }
  }
}
