import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _paymentMethods = <Map<String, dynamic>>[
    {
      'id': '1',
      'type': 'UPI',
      'name': 'Google Pay',
      'detail': 'arun@okicici',
      'icon': Icons.account_balance,
      'isDefault': true,
    },
    {
      'id': '2',
      'type': 'Card',
      'name': 'HDFC Credit Card',
      'detail': '**** **** **** 4532',
      'icon': Icons.credit_card,
      'isDefault': false,
    },
    {
      'id': '3',
      'type': 'Wallet',
      'name': 'HushRyd Wallet',
      'detail': 'Balance: \u20B91,250',
      'icon': Icons.account_balance_wallet,
      'isDefault': false,
    },
  ];

  final _transactions = [
    {
      'id': 'txn1',
      'description': 'Ride: Hyderabad \u2192 Vijayawada',
      'amount': -450,
      'date': '06 Apr 2026',
      'status': 'Completed',
      'method': 'UPI',
    },
    {
      'id': 'txn2',
      'description': 'Wallet Recharge',
      'amount': 1000,
      'date': '04 Apr 2026',
      'status': 'Completed',
      'method': 'Card',
    },
    {
      'id': 'txn3',
      'description': 'Ride: Hyderabad \u2192 Chennai',
      'amount': -1200,
      'date': '02 Apr 2026',
      'status': 'Completed',
      'method': 'UPI',
    },
    {
      'id': 'txn4',
      'description': 'Refund: Cancelled Ride',
      'amount': 350,
      'date': '28 Mar 2026',
      'status': 'Refunded',
      'method': 'Wallet',
    },
    {
      'id': 'txn5',
      'description': 'Ride: Hyderabad \u2192 Warangal',
      'amount': -350,
      'date': '25 Mar 2026',
      'status': 'Failed',
      'method': 'Card',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Payment Methods'),
            Tab(text: 'Transactions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMethodsTab(),
          _buildTransactionsTab(),
        ],
      ),
    );
  }

  Widget _buildMethodsTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _paymentMethods.length,
            itemBuilder: (_, i) {
              final method = _paymentMethods[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: method['isDefault'] as bool
                        ? AppColors.primary
                        : Colors.grey.shade200,
                    width: method['isDefault'] as bool ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(method['icon'] as IconData,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(method['name'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              if (method['isDefault'] as bool) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text('Default',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(method['detail'] as String,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'default') {
                          setState(() {
                            for (var m in _paymentMethods) {
                              m['isDefault'] = false;
                            }
                            method['isDefault'] = true;
                          });
                        } else if (value == 'remove') {
                          setState(() => _paymentMethods.remove(method));
                        }
                      },
                      itemBuilder: (_) => [
                        if (!(method['isDefault'] as bool))
                          const PopupMenuItem(
                              value: 'default',
                              child: Text('Set as Default')),
                        const PopupMenuItem(
                            value: 'remove',
                            child: Text('Remove',
                                style: TextStyle(color: AppColors.error))),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddPaymentSheet,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Payment Method'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddPaymentSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _addOption(Icons.account_balance, 'UPI', 'Link your UPI ID'),
            _addOption(Icons.credit_card, 'Credit/Debit Card', 'Add a new card'),
            _addOption(Icons.account_balance_wallet, 'Net Banking',
                'Link your bank account'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _addOption(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _paymentMethods.add({
            'id': 'new_${_paymentMethods.length + 1}',
            'type': title,
            'name': title,
            'detail': 'Newly added',
            'icon': icon,
            'isDefault': false,
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title added successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (_, i) {
        final txn = _transactions[i];
        final amount = txn['amount'] as int;
        final isCredit = amount > 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isCredit ? AppColors.success : AppColors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? AppColors.success : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(txn['description'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(txn['date'] as String,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500])),
                        const SizedBox(width: 8),
                        Text('\u2022 ${txn['method']}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isCredit ? '+' : ''}\u20B9${amount.abs()}',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isCredit ? AppColors.success : Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  _transactionBadge(txn['status'] as String),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _transactionBadge(String status) {
    Color color;
    switch (status) {
      case 'Completed':
        color = AppColors.success;
      case 'Refunded':
        color = AppColors.warning;
      case 'Failed':
        color = AppColors.error;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
