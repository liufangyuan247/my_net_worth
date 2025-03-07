import 'package:flutter/material.dart';
import '../services/portfolio_service.dart';
import '../models/owner.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final PortfolioService portfolioService;
  final Owner? owner; // Made optional

  const AddTransactionScreen({
    Key? key,
    required this.portfolioService,
    this.owner,
  }) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  TransactionType _transactionType = TransactionType.deposit;
  String _transactionNotes = '';
  Owner? _selectedOwner;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedOwner = widget.owner;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addTransaction() async {
    if (_selectedOwner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择持有人'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      try {
        final amount = double.parse(_amountController.text);

        // Create the transaction
        widget.portfolioService.processTransaction(
          _selectedOwner!.id,
          amount,
          _transactionType,
          _transactionNotes,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('交易记录已添加'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('添加交易记录失败: ${e.toString()}'),
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
    final owners = widget.portfolioService.owners;

    return Scaffold(
      appBar: AppBar(
        title: const Text('添加交易记录'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Owner selection dropdown
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('选择持有人:'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Owner>(
                        value: _selectedOwner,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: owners.map((Owner owner) {
                          return DropdownMenuItem<Owner>(
                            value: owner,
                            child: Text(
                                '${owner.name} (${owner.shares.toStringAsFixed(4)} 份)'),
                          );
                        }).toList(),
                        onChanged: (Owner? newValue) {
                          setState(() {
                            _selectedOwner = newValue;
                          });
                        },
                        isExpanded: true,
                        hint: const Text('选择持有人'),
                        validator: (owner) {
                          if (owner == null) {
                            return '请选择持有人';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Owner information if selected
              if (_selectedOwner != null)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '持有人: ${_selectedOwner!.name}',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '当前份额: ${_selectedOwner!.shares.toStringAsFixed(4)}',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Transaction type selection
              Row(
                children: [
                  const Text('交易类型:'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SegmentedButton<TransactionType>(
                      segments: const [
                        ButtonSegment<TransactionType>(
                          value: TransactionType.deposit,
                          label: Text('存入'),
                          icon: Icon(Icons.arrow_downward),
                        ),
                        ButtonSegment<TransactionType>(
                          value: TransactionType.withdrawal,
                          label: Text('提取'),
                          icon: Icon(Icons.arrow_upward),
                        ),
                      ],
                      selected: {_transactionType},
                      onSelectionChanged: (Set<TransactionType> newSelection) {
                        setState(() {
                          _transactionType = newSelection.first;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount input
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: '金额 (¥)',
                  hintText: '请输入交易金额',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入金额';
                  }
                  try {
                    double amount = double.parse(value);
                    if (amount <= 0) {
                      return '金额必须大于0';
                    }
                  } catch (e) {
                    return '请输入有效的数字';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes input
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '备注 (可选)',
                  hintText: '请输入备注',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                onChanged: (value) {
                  _transactionNotes = value;
                },
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isProcessing ? null : _addTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : Text(_transactionType == TransactionType.deposit
                        ? '添加存入记录'
                        : '添加提取记录'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
