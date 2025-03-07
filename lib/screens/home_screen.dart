import 'package:flutter/material.dart';
import '../services/portfolio_service.dart';
import '../widgets/asset_list.dart';
import 'asset_detail_screen.dart';
import 'add_asset_screen.dart';
import 'transaction_screen.dart';
import '../models/owner.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PortfolioService _portfolioService = PortfolioService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _portfolioService.loadData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('资产净值管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              // MyApp.of(context).toggleTheme();
            },
            tooltip: '切换主题',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddAssetScreen(portfolioService: _portfolioService),
            ),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
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
            ).then((_) => setState(() {}));
          },
        );
      case 2:
        return _buildOwnersList();
      case 3:
        return _buildTransactionHistory();
      default:
        return const Center(child: Text('页面不存在'));
    }
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
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    netValue.toStringAsFixed(4),
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '总资产: ¥${totalAssets.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '资产分布',
            style: Theme.of(context).textTheme.headline6,
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
    // 这里可以实现资产分布图表
    // 可以使用fl_chart或其他图表库
    return const Center(
      child: Text('资产分布图表将显示在这里'),
    );
  }

  Widget _buildOwnersList() {
    return ListView.builder(
      itemCount: _portfolioService.owners.length,
      itemBuilder: (context, index) {
        final owner = _portfolioService.owners[index];
        return ListTile(
          title: Text(owner.name),
          subtitle: Text('份额: ${owner.shares.toStringAsFixed(4)}'),
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
              ).then((_) => setState(() {}));
            },
          ),
        );
      },
    );
  }

  Widget _buildTransactionHistory() {
    final transactions = _portfolioService.transactions;
    transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final owner = _portfolioService.owners.firstWhere(
          (o) => o.id == transaction.ownerId,
          orElse: () => Owner(id: '', name: 'Unknown'),
        );

        return ListTile(
          title: Text(
            transaction.type == TransactionType.deposit ? '存入' : '提取',
          ),
          subtitle: Text(
            '${owner.name} - ¥${transaction.amount.toStringAsFixed(2)} - ${transaction.timestamp.toString().substring(0, 16)}',
          ),
          trailing: Text(
            '${transaction.type == TransactionType.deposit ? '+' : '-'}${transaction.shares.toStringAsFixed(4)} 份',
          ),
        );
      },
    );
  }
}
