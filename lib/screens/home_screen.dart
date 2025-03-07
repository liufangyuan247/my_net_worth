import 'package:flutter/material.dart';
import '../services/portfolio_service.dart';
import '../widgets/asset_list.dart';
import '../main.dart';
import 'asset_detail_screen.dart';
import 'add_asset_screen.dart';
import 'add_owner_screen.dart';
import 'add_transaction_screen.dart';
import 'transaction_screen.dart';
import 'settings_screen.dart';
import '../models/owner.dart';
import '../models/transaction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PortfolioService _portfolioService = PortfolioService();
  int _selectedIndex = 0;
  bool _isLoading = true;

  // 订阅数据变更
  late Stream<DataChangeEvent> _dataChangeStream;

  @override
  void initState() {
    super.initState();

    // 订阅数据变更事件
    _dataChangeStream = _portfolioService.onDataChanged;
    _dataChangeStream.listen(_handleDataChange);

    // 初次加载数据
    _initializeData();
  }

  // 处理数据变更事件
  void _handleDataChange(DataChangeEvent event) {
    if (mounted) {
      setState(() {
        // 数据已更新，更新UI
        print("数据已变更，更新UI: ${event.type}");
      });
    }
  }

  // 初始化数据
  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    // 初次加载时，可以直接使用服务的loadData方法
    // 因为服务构造时已经调用了loadData，这里只是确保数据已加载完成
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });
  }

  // 手动刷新数据
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    await _portfolioService.refreshData();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('资产净值管理')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('资产净值管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: '刷新数据',
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              MyNetWorthApp.of(context).toggleTheme();
            },
            tooltip: '切换主题',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      portfolioService: _portfolioService,
                    ),
                  ),
                );
                // 数据变更会通过Stream自动通知，不需要手动刷新
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('设置'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '概览',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: '资产',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '持有人',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '交易',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    // Only show FAB for tabs where adding makes sense
    if (_selectedIndex == 0) {
      return const SizedBox.shrink(); // No FAB for overview
    }

    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              switch (_selectedIndex) {
                case 1:
                  return AddAssetScreen(portfolioService: _portfolioService);
                case 2:
                  return AddOwnerScreen(portfolioService: _portfolioService);
                case 3:
                  return AddTransactionScreen(
                      portfolioService: _portfolioService);
                default:
                  return AddAssetScreen(portfolioService: _portfolioService);
              }
            },
          ),
        );
        // 数据变更会通过Stream自动通知，不需要手动刷新
      },
      tooltip: _getFloatingActionButtonTooltip(),
      child: const Icon(Icons.add),
    );
  }

  String _getFloatingActionButtonTooltip() {
    switch (_selectedIndex) {
      case 1:
        return '添加资产';
      case 2:
        return '添加持有人';
      case 3:
        return '添加交易';
      default:
        return '添加';
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildAssetList();
      case 2:
        return _buildOwnersList();
      case 3:
        return _buildTransactionHistory();
      default:
        return const Center(child: Text('页面不存在'));
    }
  }

  Widget _buildAssetList() {
    if (_portfolioService.assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('暂无资产数据'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddAssetScreen(portfolioService: _portfolioService),
                  ),
                );
                // 数据变更会通过Stream自动通知，不需要手动刷新
              },
              child: const Text('添加第一个资产'),
            ),
          ],
        ),
      );
    }

    return AssetList(
      assets: _portfolioService.assets,
      onTap: (asset) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssetDetailScreen(
              asset: asset,
              portfolioService: _portfolioService,
            ),
          ),
        );
        // 数据变更会通过Stream自动通知，不需要手动刷新
      },
    );
  }

  Widget _buildOverview() {
    double netValue = _portfolioService.calculateNetValue();
    double totalAssets = _portfolioService.getTotalAssetValue();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '当前净值',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    netValue.toStringAsFixed(4),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '总资产: ¥${totalAssets.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '总份额: ${_portfolioService.getTotalShares().toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '资产分布',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildAssetDistributionChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetDistributionChart() {
    if (_portfolioService.assets.isEmpty) {
      return const Center(child: Text('暂无资产数据，请添加一些资产'));
    }

    // This is a placeholder for the chart implementation
    // In a real application, you would use a charting library like fl_chart
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pie_chart, size: 100, color: Colors.blue),
          const SizedBox(height: 16),
          const Text('资产分布图表将显示在这里'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddAssetScreen(portfolioService: _portfolioService),
                ),
              );
              // 数据变更会通过Stream自动通知，不需要手动刷新
            },
            child: const Text('添加新资产'),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnersList() {
    if (_portfolioService.owners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('暂无持有人数据'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddOwnerScreen(portfolioService: _portfolioService),
                  ),
                );
                // 数据变更会通过Stream自动通知，不需要手动刷新
              },
              child: const Text('添加第一个持有人'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _portfolioService.owners.length,
      itemBuilder: (context, index) {
        final owner = _portfolioService.owners[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(
              owner.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('份额: ${owner.shares.toStringAsFixed(4)}'),
                Text(
                    '价值: ¥${owner.shares * _portfolioService.calculateNetValue()}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionScreen(
                      owner: owner,
                      portfolioService: _portfolioService,
                    ),
                  ),
                );
                // 数据变更会通过Stream自动通知，不需要手动刷新
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionHistory() {
    final transactions = _portfolioService.transactions;

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('暂无交易记录'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTransactionScreen(
                        portfolioService: _portfolioService),
                  ),
                );
                // 数据变更会通过Stream自动通知，不需要手动刷新
              },
              child: const Text('添加第一笔交易'),
            ),
          ],
        ),
      );
    }

    // Sort transactions by date, most recent first
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView.builder(
      itemCount: sortedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = sortedTransactions[index];
        final owner = _portfolioService.owners.firstWhere(
          (o) => o.id == transaction.ownerId,
          orElse: () => Owner(id: '', name: '未知'),
        );

        final dateString = _formatDateTime(transaction.timestamp);
        final isDeposit = transaction.type == TransactionType.deposit;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isDeposit ? Colors.green : Colors.red,
              child: Icon(
                isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
            title: Text(
              isDeposit ? '存入' : '提取',
              style: TextStyle(
                color: isDeposit ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('持有人: ${owner.name}'),
                Text('金额: ¥${transaction.amount.toStringAsFixed(2)}'),
                Text('时间: $dateString'),
                if (transaction.notes.isNotEmpty)
                  Text('备注: ${transaction.notes}'),
              ],
            ),
            trailing: Text(
              '${isDeposit ? '+' : '-'}${transaction.shares.toStringAsFixed(4)} 份',
              style: TextStyle(
                color: isDeposit ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
