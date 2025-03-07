import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/owner.dart';
import '../models/transaction.dart';
import '../services/portfolio_service.dart';

class TransactionScreen extends StatefulWidget {
  final Owner owner;
  final PortfolioService portfolioService;

  const TransactionScreen({
    Key? key,
    required this.owner,
    required this.portfolioService,
  }) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // 当前净值和份额信息
  late double _currentNetValue;
  late double _currentShares;

  // 交易历史
  late List<Transaction> _ownerTransactions;

  // 订阅数据变更
  late Stream<DataChangeEvent> _dataChangeStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 初始化数据
    _currentNetValue = widget.portfolioService.calculateNetValue();
    _currentShares = widget.owner.shares;
    _updateTransactionsList();

    // 订阅数据变更事件
    _dataChangeStream = widget.portfolioService.onDataChanged;
    _dataChangeStream.listen(_handleDataChange);
  }

  void _handleDataChange(DataChangeEvent event) {
    // 只有当相关的数据变更时才更新UI
    if (event.type == DataChangeType.all ||
        event.type == DataChangeType.transactions ||
        event.type == DataChangeType.owners) {
      if (mounted) {
        setState(() {
          _currentNetValue = widget.portfolioService.calculateNetValue();
          _currentShares = widget.owner.shares;
          _updateTransactionsList();
        });
      }
    }
  }

  void _updateTransactionsList() {
    // 获取当前持有人的交易记录
    _ownerTransactions = widget.portfolioService.transactions
        .where((transaction) => transaction.ownerId == widget.owner.id)
        .toList();

    // 按时间倒序排列
    _ownerTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取应用的主题数据
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.owner.name} 的交易'),
      ),
      body: Column(
        children: [
          // 替换原来在AppBar中的TabBar，使用自定义TabBar，增强视觉对比
          Material(
            color: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
            elevation: 4,
            child: TabBar(
              controller: _tabController,
              // 使用更鲜明的颜色对比
              labelColor: Colors.white,
              unselectedLabelColor:
                  isDarkMode ? Colors.white60 : Colors.white70,
              // 增加选中标签的字体粗细
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              // 添加选中标签下方的指示器，使其更加明显
              indicator: BoxDecoration(
                color: isDarkMode ? Colors.blue[700] : Colors.blue[800],
                border: const Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
              ),
              indicatorWeight: 4,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(
                  icon: Icon(Icons.swap_horiz),
                  text: '购买/赎回',
                  // 增加标签内边距，让Tab更加明显
                  iconMargin: EdgeInsets.only(bottom: 4),
                ),
                Tab(
                  icon: Icon(Icons.history),
                  text: '交易历史',
                  iconMargin: EdgeInsets.only(bottom: 4),
                ),
              ],
            ),
          ),
          // 使用Expanded包裹TabBarView，确保它能够填充剩余空间
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionForm(),
                _buildTransactionHistory(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildTransactionInputs(),
          const SizedBox(height: 16),
          _buildTransactionActions(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '当前净值',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _currentNetValue.toStringAsFixed(4),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '持有份额',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _currentShares.toStringAsFixed(4),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '当前市值',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '¥${(_currentNetValue * _currentShares).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '交易信息',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(
            labelText: '金额',
            hintText: '输入交易金额',
            prefixText: '¥ ',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入金额';
            }
            if (double.tryParse(value) == null || double.parse(value) <= 0) {
              return '请输入有效的金额';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildSharesPreview(),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: '备注',
            hintText: '可选：输入交易备注',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildSharesPreview() {
    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      return const SizedBox.shrink();
    }

    double shares = amount / _currentNetValue;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '预计份额变动:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            shares.toStringAsFixed(4),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionActions() {
    bool isAmountValid = _amountController.text.isNotEmpty &&
        double.tryParse(_amountController.text) != null &&
        double.parse(_amountController.text) > 0;

    double? amount =
        isAmountValid ? double.parse(_amountController.text) : null;
    bool canWithdraw =
        isAmountValid && amount! <= (_currentNetValue * _currentShares);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isAmountValid
                ? () => _handleTransaction(TransactionType.deposit)
                : null,
            icon: const Icon(Icons.add_circle),
            label: const Text('购买份额'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canWithdraw
                ? () => _handleTransaction(TransactionType.withdrawal)
                : null,
            icon: const Icon(Icons.remove_circle),
            label: const Text('赎回份额'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    if (_ownerTransactions.isEmpty) {
      return const Center(
        child: Text('暂无交易记录'),
      );
    }

    return ListView.builder(
      itemCount: _ownerTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _ownerTransactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isDeposit = transaction.type == TransactionType.deposit;
    final formattedDate =
        DateFormat('yyyy-MM-dd HH:mm').format(transaction.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDeposit ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isDeposit ? Icons.add_circle : Icons.remove_circle,
                    color: isDeposit ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDeposit ? '购买份额' : '赎回份额',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '¥${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDeposit ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${isDeposit ? '+' : '-'}${transaction.shares.toStringAsFixed(4)} 份',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (transaction.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 4),
              Text(
                '备注: ${transaction.notes}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '交易净值: ${transaction.netValueAtTransaction.toStringAsFixed(4)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTransaction(TransactionType type) async {
    // 验证输入
    if (_amountController.text.isEmpty) {
      _showError('请输入金额');
      return;
    }

    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('请输入有效的金额');
      return;
    }

    // 检查提款金额是否超过可用金额
    if (type == TransactionType.withdrawal) {
      double currentValue = _currentNetValue * _currentShares;
      if (amount > currentValue) {
        _showError('提款金额超过当前市值');
        return;
      }
    }

    // 显示加载对话框
    final loadingDialog = _showLoadingDialog();

    // 执行交易
    try {
      print("开始执行交易");
      if (type == TransactionType.deposit) {
        await widget.portfolioService.processTransaction(
          widget.owner.id,
          amount,
          TransactionType.deposit,
          _notesController.text,
        );
        _showSuccess('购买份额成功');
      } else {
        await widget.portfolioService.processTransaction(
          widget.owner.id,
          amount,
          TransactionType.withdrawal,
          _notesController.text,
        );
        _showSuccess('赎回份额成功');
      }

      // 关闭加载对话框
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // 清除输入
      _amountController.clear();
      _notesController.clear();

      // 切换到交易历史标签页 - 不需要手动更新数据，因为会通过数据流监听更新
      _tabController.animateTo(1);
    } catch (e) {
      // 关闭加载对话框
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showError('交易失败: ${e.toString()}');
    }
  }

  // Show a loading dialog while processing transaction
  AlertDialog _showLoadingDialog() {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
            margin: const EdgeInsets.only(left: 16),
            child: const Text("处理交易中..."),
          ),
        ],
      ),
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return alert;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
