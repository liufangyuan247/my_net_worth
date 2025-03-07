import 'package:flutter/material.dart';
import '../services/portfolio_service.dart';

class SettingsScreen extends StatefulWidget {
  final PortfolioService portfolioService;

  const SettingsScreen({
    Key? key,
    required this.portfolioService,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isProcessing = false;

  Future<void> _exportData() async {
    // Implementation for data export would go here
    // This could save data to a file or cloud service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据导出功能尚未实现')),
    );
  }

  Future<void> _importData() async {
    // Implementation for data import would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据导入功能尚未实现')),
    );
  }

  Future<void> _resetData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置所有数据'),
        content: const Text('此操作将删除所有资产、持有人和交易记录数据。此操作不可撤销，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isProcessing = true;
              });

              await widget.portfolioService.resetData();

              if (mounted) {
                setState(() {
                  _isProcessing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('所有数据已重置')),
                );
              }
            },
            child: const Text('重置', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSampleData() async {
    setState(() {
      _isProcessing = true;
    });

    await widget.portfolioService.initializeWithSampleData();

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('示例数据已加载')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('关于'),
                  subtitle: const Text('查看应用信息'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: '资产净值管理',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2023 Your Name',
                      children: const [
                        Text('一个简单的资产净值跟踪应用'),
                      ],
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('导出数据'),
                  subtitle: const Text('保存所有数据'),
                  onTap: _exportData,
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('导入数据'),
                  subtitle: const Text('从备份中恢复数据'),
                  onTap: _importData,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.library_add),
                  title: const Text('加载示例数据'),
                  subtitle: const Text('添加一些示例数据用于测试'),
                  onTap: _loadSampleData,
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title:
                      const Text('重置所有数据', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('删除所有资产、持有人和交易记录',
                      style: TextStyle(color: Colors.red)),
                  onTap: _resetData,
                ),
              ],
            ),
    );
  }
}
