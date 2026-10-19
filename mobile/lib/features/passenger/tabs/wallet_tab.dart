import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';

class WalletTab extends StatefulWidget {
  final PassengerModel passenger;
  final Function(double) onTopUp;

  const WalletTab({
    super.key,
    required this.passenger,
    required this.onTopUp,
  });

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  String _selectedFilter = 'ALL'; // 'ALL', 'RECHARGE', 'WALLET', 'UPI', 'CASH'

  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TX-9041',
      'title': 'Bus Ticket: Aluva ➔ Kizhakkambalam',
      'bus': 'KL 07 CD 4589',
      'amount': -18.0,
      'type': 'WALLET',
      'date': 'Today, 09:40 AM',
      'status': 'SUCCESS',
    },
    {
      'id': 'TX-9032',
      'title': 'Demo Wallet Top-Up',
      'bus': 'Net Banking / UPI Ref #89123',
      'amount': 200.0,
      'type': 'RECHARGE',
      'date': 'Today, 09:00 AM',
      'status': 'SUCCESS',
    },
    {
      'id': 'TX-8911',
      'title': 'Bus Ticket: Perumbavoor ➔ Pattimattom',
      'bus': 'KL 07 CE 1204',
      'amount': -12.0,
      'type': 'UPI',
      'date': 'Yesterday, 05:15 PM',
      'status': 'SUCCESS',
    },
    {
      'id': 'TX-8740',
      'title': 'Bus Ticket: Aluva ➔ Pump Junction',
      'bus': 'KL 07 BQ 9981',
      'amount': -10.0,
      'type': 'CASH',
      'date': '16 Oct, 11:20 AM',
      'status': 'SUCCESS',
    },
    {
      'id': 'TX-8600',
      'title': 'Initial Signup Bonus Credit',
      'bus': 'SmartBus Kerala Promotion',
      'amount': 250.0,
      'type': 'RECHARGE',
      'date': '15 Oct, 08:30 AM',
      'status': 'SUCCESS',
    },
  ];

  void _showAddMoneyModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Money to Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Select a demo recharge amount:', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [50.0, 100.0, 200.0, 500.0].map((amt) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      widget.onTopUp(amt);
                      Navigator.pop(context);
                    },
                    child: Text('₹${amt.toInt()}'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    // Filter transactions
    final filtered = _transactions.where((tx) {
      if (_selectedFilter == 'ALL') return true;
      return tx['type'] == _selectedFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Wallet Balance Header
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppTheme.busGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AVAILABLE WALLET BALANCE',
                  style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  currency.format(widget.passenger.walletBalance),
                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _showAddMoneyModal,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Top Up Balance'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Transaction Category Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All History', 'ALL'),
                _filterChip('Recharges', 'RECHARGE'),
                _filterChip('Wallet Tickets', 'WALLET'),
                _filterChip('UPI Paid', 'UPI'),
                _filterChip('Cash Paid', 'CASH'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Transactions List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Transaction & Travel Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${filtered.length} entries', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),

          ...filtered.map((tx) {
            final isCredit = (tx['amount'] as double) > 0;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCredit
                            ? Colors.green.withValues(alpha: 0.1)
                            : (tx['type'] == 'UPI' ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isCredit
                            ? Icons.account_balance_wallet
                            : (tx['type'] == 'UPI' ? Icons.qr_code : Icons.directions_bus),
                        color: isCredit
                            ? Colors.green
                            : (tx['type'] == 'UPI' ? Colors.blue : AppTheme.primaryGreen),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 3),
                          Text('${tx['bus']} • ${tx['date']}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'METHOD: ${tx['type']}',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isCredit ? '+' : ''}₹${(tx['amount'] as double).abs().toStringAsFixed(1)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isCredit ? Colors.green : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String key) {
    final isSelected = _selectedFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryGreen : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (val) => setState(() => _selectedFilter = key),
      ),
    );
  }
}
