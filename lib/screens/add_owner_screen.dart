import 'package:flutter/material.dart';
import '../services/portfolio_service.dart';
import '../models/owner.dart';

class AddOwnerScreen extends StatefulWidget {
  final PortfolioService portfolioService;

  const AddOwnerScreen({
    Key? key,
    required this.portfolioService,
  }) : super(key: key);

  @override
  State<AddOwnerScreen> createState() => _AddOwnerScreenState();
}

class _AddOwnerScreenState extends State<AddOwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _initialSharesController =
      TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _initialSharesController.dispose();
    super.dispose();
  }

  Future<void> _addOwner() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      try {
        final name = _nameController.text.trim();
        final initialShares = _initialSharesController.text.isNotEmpty
            ? double.parse(_initialSharesController.text)
            : 0.0;

        // Create a new owner
        final newOwner = Owner(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          shares: initialShares,
        );

        // Add the owner to the portfolio
        widget.portfolioService.addOwner(newOwner);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('持有人添加成功'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('添加持有人失败: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加持有人'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '持有人姓名',
                  hintText: '请输入持有人姓名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入持有人姓名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _initialSharesController,
                decoration: const InputDecoration(
                  labelText: '初始份额（可选）',
                  hintText: '请输入初始份额，默认为0',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    try {
                      double shares = double.parse(value);
                      if (shares < 0) {
                        return '份额不能为负数';
                      }
                    } catch (e) {
                      return '请输入有效的数字';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isProcessing ? null : _addOwner,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text('添加持有人'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
